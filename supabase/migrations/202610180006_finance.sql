create function private.reconcile_invoice(p_id uuid) returns void
language plpgsql set search_path='' as $$
declare v_paid numeric; begin
  select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)
    into v_paid from public.payments where invoice_id=p_id;
  update public.invoices set status=case when v_paid=0 then 'due' when v_paid=amount_egp then 'paid' else 'partially_paid' end where id=p_id;
end $$;
create function public.create_invoice(p_student_id uuid,p_amount numeric,p_due_on date,p_invoice_number text,p_group_id uuid default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_id uuid;
begin
  if p_amount is null or p_amount<=0 or p_amount<>round(p_amount,2) or p_due_on is null
    or nullif(trim(p_invoice_number),'') is null then raise exception 'VALIDATION_ERROR'; end if;
  insert into public.invoices(teacher_id,student_id,group_id,amount_egp,due_on,invoice_number,created_by)
    values(v_tenant,p_student_id,p_group_id,p_amount,p_due_on,trim(p_invoice_number),auth.uid()) returning id into v_id;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action) values(v_tenant,auth.uid(),'invoice',v_id,'created');
  return v_id;
end $$;
create function public.record_payment(p_invoice_id uuid,p_amount numeric,p_method text,p_idempotency_key uuid)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); i public.invoices; p public.payments; v_paid numeric; v_id uuid;
begin
  if p_amount is null or p_amount<=0 or p_amount<>round(p_amount,2) or p_method is null
    or p_method not in ('cash','transfer','other') or p_idempotency_key is null then raise exception 'VALIDATION_ERROR'; end if;
  -- Serialize tenant-key reuse, including concurrent reuse against different invoices.
  perform pg_advisory_xact_lock(hashtextextended(v_tenant::text||p_idempotency_key::text,0));
  select * into p from public.payments where teacher_id=v_tenant and idempotency_key=p_idempotency_key;
  if found then
    if p.invoice_id<>p_invoice_id or p.amount_egp<>p_amount or p.method<>p_method or p.reversal_of is not null
      then raise exception 'CONFLICT'; end if;
    return p.id;
  end if;
  select * into i from public.invoices where id=p_invoice_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if i.status='void' then raise exception 'CONFLICT'; end if;
  select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)
    into v_paid from public.payments where invoice_id=i.id;
  if v_paid+p_amount>i.amount_egp then raise exception 'CONFLICT'; end if;
  insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key)
    values(v_tenant,i.id,p_amount,auth.uid(),p_method,p_idempotency_key) returning id into v_id;
  perform private.reconcile_invoice(i.id);
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action) values(v_tenant,auth.uid(),'payment',v_id,'collected');
  return v_id;
end $$;
create function public.reverse_payment(p_payment_id uuid,p_reason text) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); p public.payments; v_id uuid;
begin
  if nullif(trim(p_reason),'') is null then raise exception 'VALIDATION_ERROR'; end if;
  select * into p from public.payments where id=p_payment_id and teacher_id=v_tenant;
  if not found then raise exception 'NOT_FOUND'; end if;
  perform 1 from public.invoices where id=p.invoice_id for update;
  if p.reversal_of is not null then raise exception 'CONFLICT'; end if;
  select id into v_id from public.payments where reversal_of=p.id;
  if found then return v_id; end if;
  insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key,reversal_of,reason)
    values(v_tenant,p.invoice_id,p.amount_egp,auth.uid(),p.method,gen_random_uuid(),p.id,trim(p_reason)) returning id into v_id;
  perform private.reconcile_invoice(p.invoice_id);
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action) values(v_tenant,auth.uid(),'payment',v_id,'reversed');
  return v_id;
end $$;
