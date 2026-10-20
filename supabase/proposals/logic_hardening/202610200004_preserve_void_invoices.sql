-- LOCAL PROPOSAL ONLY. Preserve a trusted void decision during ledger correction.
create or replace function private.reconcile_invoice(p_id uuid) returns void
language plpgsql set search_path='' as $$
declare v_paid numeric;
begin
 select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)
 into v_paid from public.payments where invoice_id=p_id;
 update public.invoices set status=case when v_paid=0 then 'due'
  when v_paid=amount_egp then 'paid' else 'partially_paid' end
 where id=p_id and status<>'void';
end $$;
revoke all on function private.reconcile_invoice(uuid) from public,anon,authenticated;
