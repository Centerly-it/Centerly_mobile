create function public.set_attendance(p_session_id uuid,p_student_id uuid,p_status text,p_reason text default null)
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
  if s.attendance_finalized_at is not null and nullif(trim(p_reason),'') is null then
    raise exception 'ATTENDANCE_CORRECTION_REASON_REQUIRED'; end if;
  v_previous:=a.status;
  update public.attendance set status=p_status,marked_by=auth.uid(),marked_at=clock_timestamp(),updated_at=clock_timestamp() where id=a.id;
  insert into public.attendance_change_log(teacher_id,attendance_id,actor_id,previous_status,next_status,reason)
    values(v_tenant,a.id,auth.uid(),v_previous,p_status,nullif(trim(p_reason),''));
  return a.id;
end $$;
create function public.finalize_attendance(p_session_id uuid) returns void
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); s public.sessions;
begin
  select * into s from public.sessions where id=p_session_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if s.status='cancelled' then raise exception 'CONFLICT'; end if;
  if s.attendance_finalized_at is not null then return; end if;
  update public.sessions set attendance_finalized_at=clock_timestamp(),attendance_finalized_by=auth.uid() where id=s.id;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action)
    values(v_tenant,auth.uid(),'session',s.id,'attendance_finalized');
end $$;
create function public.cancel_session(p_session_id uuid,p_reason text) returns void
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor(); s public.sessions;
begin
  if nullif(trim(p_reason),'') is null then raise exception 'VALIDATION_ERROR'; end if;
  select * into s from public.sessions where id=p_session_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if s.status='cancelled' then raise exception 'ALREADY_CANCELLED'; end if;
  if s.ends_at<=now() then raise exception 'CONFLICT'; end if;
  update public.sessions set status='cancelled',cancel_reason=trim(p_reason),cancelled_by=auth.uid(),cancelled_at=clock_timestamp() where id=s.id;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
    values(v_tenant,auth.uid(),'session',s.id,'cancelled',jsonb_build_object('reason',trim(p_reason)));
  insert into public.notifications(teacher_id,recipient_id,type,payload)
    select v_tenant,id,'session_cancelled',jsonb_build_object('session_id',s.id)
    from (select id from public.secretaries where teacher_id=v_tenant and status='active'
      union select v_tenant) recipients where id<>auth.uid();
end $$;
