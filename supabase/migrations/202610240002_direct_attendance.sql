create or replace function public.set_attendance(p_session_id uuid,p_student_id uuid,p_status text,p_reason text default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); s public.sessions; a public.attendance; v_previous text;
begin
  if p_status is null or p_status not in ('not_marked','present','absent','excused') then raise exception 'VALIDATION_ERROR'; end if;
  select * into s from public.sessions where id=p_session_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if s.status='cancelled' then raise exception 'CONFLICT'; end if;
  select * into a from public.attendance where session_id=s.id and student_id=p_student_id;
  if not found then
    if not exists(select 1 from public.group_enrollments where teacher_id=v_tenant
      and group_id=s.group_id and student_id=p_student_id and status='active') then raise exception 'NOT_FOUND'; end if;
    insert into public.attendance(teacher_id,session_id,student_id) values(v_tenant,s.id,p_student_id) returning * into a;
  end if;
  if a.status=p_status then return a.id; end if;
  v_previous:=a.status;
  update public.attendance set status=p_status,marked_by=auth.uid(),marked_at=clock_timestamp(),updated_at=clock_timestamp() where id=a.id;
  insert into public.attendance_change_log(teacher_id,attendance_id,actor_id,previous_status,next_status,reason)
    values(v_tenant,a.id,auth.uid(),v_previous,p_status,nullif(trim(p_reason),''));
  return a.id;
end $$;

-- Retain historical finalization metadata and audit rows; retire the workflow.
revoke execute on function public.finalize_attendance(uuid) from authenticated,anon,public;
