-- LOCAL PROPOSAL ONLY: teacher read-model, no hosted deployment authorized.
create index teacher_invoice_movements on public.payments(invoice_id,id) include(teacher_id,amount_egp,reversal_of);
create function public.get_teacher_finance_overview(p_from date,p_to date) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; breakdown jsonb;
 today date:=(statement_timestamp() at time zone 'Africa/Cairo')::date;
begin
 perform private.check_teacher_window(p_from,p_to,1);
 result:=(public.get_teacher_finance(p_from,p_to,'invoices',null,null,null,null,1))->'summary';
 with scoped as (
  select i.*,i.amount_egp-coalesce(p.paid,0) as remaining from public.invoices i
  left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
    from public.payments where teacher_id=t and invoice_id=i.id) p on true
  where i.teacher_id=t and i.status<>'void' and i.due_on between p_from and p_to
 ) select jsonb_build_object('invoice_count',count(*),
   'overdue_egp',coalesce(sum(remaining) filter(where due_on<today),0)::numeric(20,2)::text,
   'due_today_egp',coalesce(sum(remaining) filter(where due_on=today),0)::numeric(20,2)::text,
   'future_due_egp',coalesce(sum(remaining) filter(where due_on>today),0)::numeric(20,2)::text)
 into breakdown from scoped;
 with movements as materialized (
  select p.*,case when reversal_of is null then amount_egp else -amount_egp end signed
  from public.payments p where teacher_id=t
   and collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
 ), actors as (
  select m.collected_by as actor_id,s.name as actor_name,s.status as actor_status,
   count(*) filter(where reversal_of is null) as collection_count,
   count(*) filter(where reversal_of is not null) as correction_count,
   coalesce(sum(amount_egp) filter(where reversal_of is null),0)::numeric(20,2)::text gross_egp,
   coalesce(sum(amount_egp) filter(where reversal_of is not null),0)::numeric(20,2)::text corrections_egp,
   sum(signed)::numeric(20,2)::text net_egp
  from movements m left join public.secretaries s on s.id=m.collected_by and s.teacher_id=t
  group by m.collected_by,s.name,s.status
 ), methods as (
  select method,sum(signed)::numeric(20,2)::text net_egp from movements group by method
 ) select result||breakdown||jsonb_build_object(
  'gross_collected_egp',coalesce(sum(amount_egp) filter(where reversal_of is null),0)::numeric(20,2)::text,
  'corrections_egp',coalesce(sum(amount_egp) filter(where reversal_of is not null),0)::numeric(20,2)::text,
  'actors',(select coalesce(jsonb_agg(to_jsonb(a) order by actor_id),'[]') from actors a),
  'methods',(select coalesce(jsonb_agg(to_jsonb(m) order by method),'[]') from methods m),
  'as_of_date',today,'synced_at',statement_timestamp()) into result from movements;
 return result;
end $$;
revoke all on function public.get_teacher_finance_overview(date,date) from public,anon;
grant execute on function public.get_teacher_finance_overview(date,date) to authenticated;
