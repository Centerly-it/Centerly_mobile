-- LOCAL REVIEW ONLY. Not deployed. Baseline 27 migrations remain immutable.
-- PACKAGE PROPOSAL ONLY: no managed migration or hosted change authorized.
create or replace function private.require_teacher_student(p_id uuid) returns uuid
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); begin
  if p_id is null then raise exception 'VALIDATION_ERROR'; end if;
  if not exists(select 1 from public.students where id=p_id and teacher_id=t)
    then raise exception 'NOT_FOUND'; end if;
  return t;
end $$;

revoke all on function private.require_teacher_student(uuid) from public,anon,authenticated;
