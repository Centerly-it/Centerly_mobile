create table public.exams (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  student_id uuid not null, group_id uuid, title text not null, held_on date not null,
  score_percent numeric(5,2) check(score_percent between 0 and 100),
  entered_by uuid not null default auth.uid() references auth.users(id), updated_at timestamptz not null default now(),
  foreign key(teacher_id,student_id) references public.students(teacher_id,id),
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id)
);
create table public.assignments (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  student_id uuid not null, group_id uuid, title text not null, due_on date not null,
  status text not null default 'pending' check(status in ('pending','submitted','late')),
  entered_by uuid not null default auth.uid() references auth.users(id), updated_at timestamptz not null default now(),
  foreign key(teacher_id,student_id) references public.students(teacher_id,id),
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id)
);
create table public.invoices (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  student_id uuid not null, group_id uuid, invoice_number text not null,
  amount_egp numeric(12,2) not null check(amount_egp>0 and amount_egp<=9999999999.99), due_on date not null,
  status text not null default 'due' check(status in ('due','partially_paid','paid','void')),
  created_by uuid not null references auth.users(id), created_at timestamptz not null default now(), void_reason text,
  unique(teacher_id,id), unique(teacher_id,invoice_number),
  foreign key(teacher_id,student_id) references public.students(teacher_id,id),
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id)
);
create table public.payments (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  invoice_id uuid not null, amount_egp numeric(12,2) not null check(amount_egp>0 and amount_egp<=9999999999.99),
  collected_by uuid not null references auth.users(id), collected_at timestamptz not null default now(),
  method text not null check(method in ('cash','transfer','other')),
  idempotency_key uuid not null, receipt_number uuid not null unique default gen_random_uuid(),
  reversal_of uuid, reason text, created_at timestamptz not null default now(),
  unique(teacher_id,id), unique(teacher_id,idempotency_key), unique(reversal_of),
  foreign key(teacher_id,invoice_id) references public.invoices(teacher_id,id),
  foreign key(teacher_id,reversal_of) references public.payments(teacher_id,id)
);
create table public.teacher_notes (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  student_id uuid not null, content text not null, updated_at timestamptz not null default now(),
  unique(teacher_id,student_id), foreign key(teacher_id,student_id) references public.students(teacher_id,id)
);
create table public.notifications (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  recipient_id uuid not null references auth.users(id), type text not null, payload jsonb not null default '{}',
  read_at timestamptz, created_at timestamptz not null default now()
);
create table public.secretary_removal_requests (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  secretary_id uuid not null, status text not null default 'pending' check(status in ('pending','handled')),
  requested_at timestamptz not null default now(), handled_at timestamptz,
  foreign key(teacher_id,secretary_id) references public.secretaries(teacher_id,id)
);
create unique index one_pending_removal on public.secretary_removal_requests(teacher_id,secretary_id) where status='pending';
create table public.attendance_change_log (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  attendance_id uuid not null, actor_id uuid not null references auth.users(id),
  previous_status text not null, next_status text not null, reason text, changed_at timestamptz not null default now(),
  foreign key(teacher_id,attendance_id) references public.attendance(teacher_id,id)
);
create table public.audit_events (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  actor_id uuid not null references auth.users(id), entity_type text not null, entity_id uuid not null,
  action text not null, metadata jsonb not null default '{}', happened_at timestamptz not null default now()
);
