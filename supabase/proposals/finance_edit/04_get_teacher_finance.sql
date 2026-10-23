create or replace function public.get_teacher_finance(p_from date,p_to date,p_kind text default 'invoices',
 p_student_id uuid default null,p_group_id uuid default null,p_secretary_id uuid default null,
 p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint; begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_kind is null or p_kind not in ('invoices','payments') then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null then perform private.require_teacher_student(p_student_id); end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_secretary_id is not null and not exists(select 1 from public.secretaries where id=p_secretary_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with scoped as (select i.*,coalesce((select sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)
   from public.payments p where p.teacher_id=t and p.invoice_id=i.id),0) as net_paid
  from public.invoices i where i.teacher_id=t and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id))
 select jsonb_build_object('invoiced_egp',coalesce(sum(amount_egp) filter(where status<>'void'),0)::numeric(20,2)::text,
  'paid_against_invoices_egp',coalesce(sum(net_paid) filter(where status<>'void'),0)::numeric(20,2)::text,
  'outstanding_egp',coalesce(sum(amount_egp-net_paid) filter(where status<>'void'),0)::numeric(20,2)::text) into stats from scoped;
 stats:=stats||jsonb_build_object('period_net_collected_egp',(select coalesce(sum(
   case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)::numeric(20,2)::text
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
  where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_secretary_id is null or p.collected_by=p_secretary_id)));
 stats:=stats||jsonb_build_object('daily_collections',(select coalesce(jsonb_agg(to_jsonb(d) order by d.date),'[]') from (
  select (p.collected_at at time zone 'Africa/Cairo')::date::text as date,
   sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text as net_egp
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
  where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_secretary_id is null or p.collected_by=p_secretary_id)
  group by (p.collected_at at time zone 'Africa/Cairo')::date) d));
 if p_kind='invoices' then
  select count(*) into n from public.invoices i where i.teacher_id=t and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select i.id,i.student_id,(select full_name from public.students where id=i.student_id and teacher_id=t) as student_name,
    i.group_id,(select name from public.groups where id=i.group_id and teacher_id=t) as group_name,
    i.invoice_number,i.amount_egp::text,i.due_on,i.status,i.void_reason,
    coalesce(p.net_paid,0)::numeric(20,2)::text as net_paid_egp,
    (case when i.status='void' then 0 else i.amount_egp-coalesce(p.net_paid,0) end)::numeric(20,2)::text as outstanding_egp
   from public.invoices i left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) as net_paid
    from public.payments where teacher_id=t and invoice_id=i.id) p on true
   where i.teacher_id=t and i.due_on between p_from and p_to and (p_student_id is null or i.student_id=p_student_id)
    and (p_group_id is null or i.group_id=p_group_id) and (p_cursor is null or i.id>p_cursor) order by i.id limit p_limit+1) r;
 else
  select count(*) into n from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
   where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
    and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
    and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
    and (p_secretary_id is null or p.collected_by=p_secretary_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select p.id,p.invoice_id,i.invoice_number,i.student_id,
    (select full_name from public.students where id=i.student_id and teacher_id=t) as student_name,
    p.amount_egp::text,(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text as signed_amount_egp,
    p.receipt_number,p.collected_at,p.method,p.reversal_of,p.reason,p.collected_by,
    (select name from public.secretaries where id=p.collected_by and teacher_id=t) as collected_by_name
   from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
   where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
    and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
    and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
    and (p_secretary_id is null or p.collected_by=p_secretary_id) and (p_cursor is null or p.id>p_cursor)
   order by p.id limit p_limit+1) r;
 end if;
 if p_kind='invoices' then
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',coalesce((select initial_amount_egp::text from public.invoices where id=(v->>'id')::uuid and teacher_id=t),v->>'amount_egp'),'ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;
