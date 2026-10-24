alter table public.group_schedules add column retired_at timestamptz;
alter table public.sessions add column fee_egp numeric(12,2) not null default 0
 check(fee_egp>=0 and fee_egp<=9999999999.99);
alter table public.invoices add column session_id uuid;
alter table public.invoices add constraint invoice_session_tenant foreign key(teacher_id,session_id)
 references public.sessions(teacher_id,id);
create unique index invoice_session_student on public.invoices(teacher_id,session_id,student_id) where session_id is not null;
