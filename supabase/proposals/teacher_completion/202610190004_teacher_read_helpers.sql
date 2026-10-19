-- PACKAGE PROPOSAL ONLY: no managed migration or hosted change authorized.
create function private.require_teacher_student(p_id uuid) returns uuid
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); begin
  if p_id is null then raise exception 'VALIDATION_ERROR'; end if;
  if not exists(select 1 from public.students where id=p_id and teacher_id=t and archived_at is null)
    then raise exception 'NOT_FOUND'; end if;
  return t;
end $$;
create function private.check_teacher_window(p_from date,p_to date,p_limit integer) returns void
language plpgsql immutable set search_path='' as $$ begin
  if p_from is null or p_to is null or p_to<p_from or p_to-p_from>365
    or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
end $$;
create function private.teacher_page(p_rows jsonb,p_limit integer) returns jsonb
language sql stable set search_path='' as $$
 select jsonb_build_object('rows',(select coalesce(jsonb_agg(value order by ord),'[]'::jsonb)
   from jsonb_array_elements(p_rows) with ordinality r(value,ord) where ord<=p_limit),
   'next_cursor',case when jsonb_array_length(p_rows)>p_limit then p_rows->(p_limit-1)->>'id' else null end,
   'synced_at',statement_timestamp())
$$;
revoke all on function private.require_teacher_student(uuid),private.check_teacher_window(date,date,integer),
 private.teacher_page(jsonb,integer) from public,anon,authenticated;
create index teacher_exam_history on public.exams(teacher_id,student_id,held_on,id);
create index teacher_assignment_history on public.assignments(teacher_id,student_id,due_on,id);
create index teacher_attendance_history on public.attendance(teacher_id,student_id,session_id,id);
create index teacher_invoice_history on public.invoices(teacher_id,due_on,id);
create index teacher_payment_history on public.payments(teacher_id,collected_at,id);
create index teacher_notification_page on public.notifications(teacher_id,recipient_id,id);
