-- LOCAL REVIEW ONLY. Archive is a read-only boundary, not deletion.
create function private.archived_student_write_guard() returns trigger
language plpgsql security definer set search_path='' as $$
declare student uuid; tenant uuid; stamp timestamptz;
begin
 if tg_table_name='students' then
  if old.archived_at is not null then raise exception 'CONFLICT'; end if;
  return new;
 end if;
 tenant:=new.teacher_id;
 if tg_table_name='payments' then
  -- Existing reversal workflow preserves correction/audit history.
  if new.reversal_of is not null then return new; end if;
  select student_id into student from public.invoices where id=new.invoice_id and teacher_id=tenant;
 else student:=new.student_id;
 end if;
 select archived_at into stamp from public.students
  where id=student and teacher_id=tenant for share;
 if not found then raise exception 'NOT_FOUND'; end if;
 if stamp is not null then raise exception 'CONFLICT'; end if;
 if tg_op='UPDATE' then
  if new.student_id<>old.student_id or new.teacher_id<>old.teacher_id then raise exception 'CONFLICT'; end if;
 end if;
 return new;
end $$;
revoke all on function private.archived_student_write_guard() from public,anon,authenticated;
create trigger archived_student_record before update on public.students
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_note before insert or update on public.teacher_notes
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_exam before insert or update on public.exams
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_assignment before insert or update on public.assignments
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_invoice before insert on public.invoices
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_collection before insert on public.payments
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_attendance before insert or update on public.attendance
 for each row execute function private.archived_student_write_guard();
