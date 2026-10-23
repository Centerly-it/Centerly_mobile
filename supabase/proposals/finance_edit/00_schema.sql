-- Local review only: preserve issued value while allowing explicit balance edits.
alter table public.invoices add column initial_amount_egp numeric(12,2);
alter table public.invoices drop constraint invoices_amount_egp_check;
alter table public.invoices add constraint invoices_amount_egp_check check(amount_egp>=0 and amount_egp<=9999999999.99);
alter table public.invoices add constraint invoice_initial_amount_check check(initial_amount_egp>=0 and initial_amount_egp<=9999999999.99);
alter table public.invoices drop constraint group_bill_components;
alter table public.invoices add constraint group_bill_components check(billing_period_start is null or
 (group_id is not null and monthly_fee_egp is not null and materials_fee_egp is not null and monthly_fee_egp>=0 and materials_fee_egp>=0
 and coalesce(initial_amount_egp,amount_egp)=monthly_fee_egp+materials_fee_egp));
create or replace function private.group_bill_snapshot_guard() returns trigger language plpgsql set search_path='' as $$
begin
 if (new.billing_period_start,new.monthly_fee_egp,new.materials_fee_egp,new.student_id,new.group_id,new.teacher_id)
 is distinct from (old.billing_period_start,old.monthly_fee_egp,old.materials_fee_egp,old.student_id,old.group_id,old.teacher_id)
 then raise exception 'CONFLICT';end if;
 if new.initial_amount_egp is distinct from old.initial_amount_egp and not
  (old.initial_amount_egp is null and new.initial_amount_egp=old.amount_egp and new.amount_egp<>old.amount_egp)
 then raise exception 'CONFLICT';end if;
 if new.amount_egp<>old.amount_egp and new.initial_amount_egp is null then raise exception 'CONFLICT';end if;
 return new;
end $$;
