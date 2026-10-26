CREATE OR REPLACE FUNCTION public.secretary_edit_finance(p_kind text, p_id uuid, p_amount numeric, p_expected_amount numeric, p_change_id uuid, p_due_on date DEFAULT NULL::date, p_method text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');i public.invoices;p public.payments;a public.audit_events;
 request jsonb:=jsonb_build_object('kind',p_kind,'id',p_id,'amount',p_amount,'expected',p_expected_amount,'due',p_due_on,'method',p_method);
 paid numeric;balance numeric;total numeric;replacement uuid;result jsonb;before_value jsonb;
begin
 if p_kind is null or p_kind not in('due','payment') or p_id is null or p_change_id is null
  or p_amount is null or p_amount<0 or p_amount>9999999999.99 or p_amount<>round(p_amount,2)
  or p_expected_amount is null or p_expected_amount<0 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_change_id::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='finance_edit' and entity_id=p_change_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return a.metadata->'result';
 end if;
 if p_kind='payment' then
  select * into p from public.payments where id=p_id and teacher_id=t;
  if not found then raise exception 'NOT_FOUND';end if;
  select * into i from public.invoices where id=p.invoice_id and teacher_id=t for update;
 else
  select * into i from public.invoices where id=p_id and teacher_id=t for update;
 end if;
 if i.id is null then raise exception 'NOT_FOUND';end if;
 if i.status='void' or (p_kind='due' and not exists(select 1 from public.students where id=i.student_id and teacher_id=t and archived_at is null))
 then raise exception 'CONFLICT';end if;
 select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0) into paid from public.payments where teacher_id=t and invoice_id=i.id;
 if p_kind='due' then
  balance:=i.amount_egp-paid;total:=paid+p_amount;
  if p_due_on is null or balance<>p_expected_amount or total>9999999999.99 then raise exception 'CONFLICT';end if;
  before_value:=jsonb_build_object('amount',i.amount_egp,'balance',balance,'due',i.due_on);
  update public.invoices set amount_egp=total,due_on=p_due_on,
   initial_amount_egp=case when total<>i.amount_egp then coalesce(i.initial_amount_egp,i.amount_egp) else i.initial_amount_egp end,
   status=case when total=paid then 'paid' when paid=0 then 'due' else 'partially_paid' end where id=i.id;
 else
  if p.reversal_of is not null or p.amount_egp<>p_expected_amount or exists(select 1 from public.payments where reversal_of=p.id)
   or p_method is null or p_method not in('cash','transfer','other') then raise exception 'CONFLICT';end if;
  before_value:=jsonb_build_object('payment',p.id,'amount',p.amount_egp,'method',p.method);
  perform public.reverse_payment(p.id,'تعديل المدفوع');
  if p_amount>0 then replacement:=public.record_payment(i.id,p_amount,p_method,p_change_id);end if;
 end if;
 result:=jsonb_build_object('invoice_id',i.id,'payment_id',replacement);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'finance_edit',p_change_id,'edited',jsonb_build_object('request',request,'before',before_value,'result',result));
 return result;
end $function$;
