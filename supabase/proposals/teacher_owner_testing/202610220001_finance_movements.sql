-- LOCAL REVIEW ONLY. Additive teacher-only read; no money writes or grant broadening.
create function public.list_teacher_finance_movements(
 p_from date,p_to date,p_search text default '',p_method text default null,
 p_kind text default null,p_secretary_id uuid default null,p_student_id uuid default null,
 p_group_id uuid default null,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint;
begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_search is null or length(p_search)>100
  or (p_method is not null and p_method not in ('cash','transfer','other'))
  or (p_kind is not null and p_kind not in ('collections','corrections'))
 then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null then perform private.require_teacher_student(p_student_id); end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_secretary_id is not null and not exists(select 1 from public.secretaries where id=p_secretary_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with filtered as materialized (
  select p.id,p.invoice_id,i.invoice_number,i.student_id,s.full_name student_name,
   p.amount_egp,(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end) signed_amount_egp,
   p.receipt_number,p.collected_at,p.method,p.reversal_of,p.reason,p.collected_by,a.name collected_by_name,
   o.receipt_number original_receipt_number,oa.name original_collected_by_name,
   rev.receipt_number correction_receipt_number
  from public.payments p
  join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
  join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  left join public.payments o on o.id=p.reversal_of and o.teacher_id=t and o.invoice_id=i.id
  left join public.secretaries oa on oa.id=o.collected_by and oa.teacher_id=t
  left join public.payments rev on rev.reversal_of=p.id and rev.teacher_id=t and rev.invoice_id=i.id
  where p.teacher_id=t
   and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_secretary_id is null or p.collected_by=p_secretary_id)
   and (p_student_id is null or i.student_id=p_student_id)
   and (p_group_id is null or i.group_id=p_group_id)
   and (p_method is null or p.method=p_method)
   and (p_kind is null or (p_kind='corrections')=(p.reversal_of is not null))
   and (p_search='' or strpos(lower(s.full_name),lower(p_search))>0
    or strpos(lower(i.invoice_number),lower(p_search))>0 or strpos(lower(p.receipt_number::text),lower(p_search))>0)
 ), page as (
  select id,invoice_id,invoice_number,student_id,student_name,
   amount_egp::numeric(20,2)::text amount_egp,signed_amount_egp::numeric(20,2)::text signed_amount_egp,
   receipt_number,collected_at,method,reversal_of,reason,collected_by,collected_by_name,
   original_receipt_number,original_collected_by_name,correction_receipt_number
  from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1
 ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),
  jsonb_build_object('net_egp',coalesce(sum(signed_amount_egp),0)::numeric(20,2)::text,
   'gross_egp',coalesce(sum(amount_egp) filter(where reversal_of is null),0)::numeric(20,2)::text,
   'corrections_egp',coalesce(sum(amount_egp) filter(where reversal_of is not null),0)::numeric(20,2)::text),count(*)
 into result,stats,n from filtered;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;
revoke all on function public.list_teacher_finance_movements(date,date,text,text,text,uuid,uuid,uuid,uuid,integer) from public,anon;
grant execute on function public.list_teacher_finance_movements(date,date,text,text,text,uuid,uuid,uuid,uuid,integer) to authenticated;
