create table public.grade_levels (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  name text not null, sort_order integer not null default 0, unique(teacher_id,id)
);
create table public.groups (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  grade_level_id uuid not null, name text not null, subject_name text not null,
  capacity integer not null check(capacity>0), archived_at timestamptz,
  unique(teacher_id,id), foreign key(teacher_id,grade_level_id) references public.grade_levels(teacher_id,id)
);
create table public.students (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  full_name text not null check(length(trim(full_name))>0), phone text, guardian_phone text,
  level_tag text, qr_code_value uuid not null unique default gen_random_uuid(), archived_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(teacher_id,id)
);
create table public.group_enrollments (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  group_id uuid not null, student_id uuid not null,
  status text not null default 'active' check(status in ('active','inactive')),
  joined_at timestamptz not null default now(), left_at timestamptz,
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id),
  foreign key(teacher_id,student_id) references public.students(teacher_id,id)
);
create unique index enrollment_active on public.group_enrollments(group_id,student_id) where status='active';
create table public.group_schedules (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  group_id uuid not null, weekday integer not null check(weekday between 0 and 6),
  local_start_time time not null, local_end_time time not null,
  effective_from date not null, effective_to date,
  unique(teacher_id,group_id,id), check(local_start_time<>local_end_time),
  check(effective_to is null or effective_to>=effective_from),
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id)
);
create table public.sessions (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  group_id uuid not null, schedule_id uuid, local_date date not null,
  starts_at timestamptz not null, ends_at timestamptz not null check(ends_at>starts_at),
  status text not null default 'upcoming' check(status in ('upcoming','ongoing','completed','cancelled')),
  cancelled_by uuid references auth.users(id), cancel_reason text, cancelled_at timestamptz,
  attendance_finalized_at timestamptz, attendance_finalized_by uuid references auth.users(id),
  created_at timestamptz not null default now(), unique(teacher_id,id), unique(schedule_id,local_date),
  foreign key(teacher_id,group_id) references public.groups(teacher_id,id),
  foreign key(teacher_id,group_id,schedule_id) references public.group_schedules(teacher_id,group_id,id),
  check(status<>'cancelled' or (cancelled_by is not null and cancelled_at is not null and length(trim(cancel_reason))>0))
);
create table public.attendance (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references public.teachers(id),
  session_id uuid not null, student_id uuid not null,
  status text not null default 'not_marked' check(status in ('not_marked','present','absent','excused')),
  marked_by uuid references auth.users(id), marked_at timestamptz, updated_at timestamptz not null default now(),
  unique(session_id,student_id), unique(teacher_id,id),
  foreign key(teacher_id,session_id) references public.sessions(teacher_id,id),
  foreign key(teacher_id,student_id) references public.students(teacher_id,id)
);
