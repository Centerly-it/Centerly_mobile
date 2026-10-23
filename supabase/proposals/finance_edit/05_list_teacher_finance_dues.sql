create or replace function public.list_teacher_finance_dues(p_from date,p_to date,p_status text default 'all',
 p_search text default '',p_student_id uuid default null,p_group_id uuid default null,
 p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint;
 today date:=(statement_timestamp() at time zone 'Africa/Cairo')::date;
begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_status is null or p_status not in ('all','overdue','partial','not_late','paid')
  or p_search is null or length(p_search)>100 then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null and not exists(select 1 from public.students where id=p_student_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with scoped as materialized (
  select i.id,i.invoice_number,i.student_id,s.full_name student_name,i.group_id,g.name group_name,
   i.amount_egp,i.due_on,coalesce(p.paid,0) paid,i.amount_egp-coalesce(p.paid,0) remaining,
   i.created_by,a.name created_by_name
  from public.invoices i join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.groups g on g.id=i.group_id and g.teacher_id=t
  left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
  left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
   from public.payments where teacher_id=t and invoice_id=i.id) p on true
  where i.teacher_id=t and i.status<>'void' and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_search='' or strpos(lower(s.full_name),lower(p_search))>0
    or strpos(lower(i.invoice_number),lower(p_search))>0)
 ), filtered as materialized (
  select * from scoped where p_status='all'
   or (p_status='paid' and remaining=0)
   or (p_status='overdue' and remaining>0 and due_on<today)
   or (p_status='partial' and paid>0 and remaining>0)
   or (p_status='not_late' and remaining>0 and due_on>=today)
 ), page as (
  select id,invoice_number,student_id,student_name,group_id,group_name,due_on,created_by,created_by_name,
   amount_egp::numeric(20,2)::text amount_egp,paid::numeric(20,2)::text net_paid_egp,
   remaining::numeric(20,2)::text outstanding_egp
  from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1
 ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),
  jsonb_build_object('invoiced_egp',coalesce(sum(amount_egp),0)::numeric(20,2)::text,
   'net_paid_egp',coalesce(sum(paid),0)::numeric(20,2)::text,
   'outstanding_egp',coalesce(sum(remaining),0)::numeric(20,2)::text),count(*)
 into result,stats,n from filtered;
 if true then
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',coalesce((select initial_amount_egp::text from public.invoices where id=(v->>'id')::uuid and teacher_id=t),v->>'amount_egp'),'ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n,'as_of_date',today);
end $$;
