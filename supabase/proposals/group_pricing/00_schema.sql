-- Owner review: enrollment-anniversary group pricing. Apply only after review approval.
-- Existing invoices and receipts are unchanged. Billing begins with each active enrollment.
alter table public.groups
 add column monthly_fee_egp numeric(12,2) not null default 0 check(monthly_fee_egp>=0),
 add column materials_fee_egp numeric(12,2) not null default 0 check(materials_fee_egp>=0);
alter table public.group_enrollments add column last_billed_on date;
-- Billing cursor is server-owned, including zero-price cycles. Membership edits use the RPC.
revoke update on public.group_enrollments from authenticated;
alter table public.invoices
 add column billing_period_start date,
 add column monthly_fee_egp numeric(12,2),
 add column materials_fee_egp numeric(12,2),
 add constraint group_bill_components check(billing_period_start is null or
  (group_id is not null and monthly_fee_egp is not null and materials_fee_egp is not null
   and monthly_fee_egp>=0 and materials_fee_egp>=0
   and amount_egp=monthly_fee_egp+materials_fee_egp
   and billing_period_start is not null));
create unique index one_group_bill_per_period on public.invoices(student_id,group_id,billing_period_start)
 where billing_period_start is not null;

