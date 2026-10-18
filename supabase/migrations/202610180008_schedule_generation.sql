-- On demand, bounded to 62 days. Never rewrite existing occurrences or attendance.
create function public.generate_sessions(p_from date,p_to date) returns integer
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_count integer;
begin
  if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR'; end if;
  insert into public.sessions(teacher_id,group_id,schedule_id,local_date,starts_at,ends_at)
    select v_tenant,s.group_id,s.id,d::date,
      (d::date+s.local_start_time) at time zone 'Africa/Cairo',
      (d::date+case when s.local_end_time<s.local_start_time then 1 else 0 end+s.local_end_time) at time zone 'Africa/Cairo'
    from public.group_schedules s cross join generate_series(p_from::timestamp,p_to::timestamp,interval '1 day') d
    join public.groups g on g.id=s.group_id and g.teacher_id=s.teacher_id
    where s.teacher_id=v_tenant and g.archived_at is null and extract(dow from d)=s.weekday
      and d::date>=s.effective_from and (s.effective_to is null or d::date<=s.effective_to)
    on conflict(schedule_id,local_date) do nothing;
  get diagnostics v_count=row_count;
  insert into public.attendance(teacher_id,session_id,student_id)
    select v_tenant,s.id,e.student_id from public.sessions s
    join public.group_enrollments e on e.group_id=s.group_id and e.teacher_id=s.teacher_id
    where s.teacher_id=v_tenant and s.local_date between p_from and p_to and s.status<>'cancelled'
      and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
    on conflict(session_id,student_id) do nothing;
  return v_count;
end $$;
-- Append schedule revisions; close the old effective range, preserve occurrences.
create function public.add_schedule(p_group_id uuid,p_weekday integer,p_start time,p_end time,p_from date,p_to date default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_id uuid;
begin
  perform 1 from public.groups where id=p_group_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  insert into public.group_schedules(teacher_id,group_id,weekday,local_start_time,local_end_time,effective_from,effective_to)
    values(v_tenant,p_group_id,p_weekday,p_start,p_end,p_from,p_to) returning id into v_id;
  return v_id;
end $$;
-- Explicit allowlist: new functions default to no client EXECUTE privileges.
revoke all on all functions in schema public from public, anon, authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
grant execute on function private.tenant_id(), private.actor_role() to authenticated;
grant execute on function public.get_current_profile(),
  public.set_attendance(uuid,uuid,text,text), public.finalize_attendance(uuid),
  public.cancel_session(uuid,text), public.create_invoice(uuid,numeric,date,text,uuid),
  public.record_payment(uuid,numeric,text,uuid), public.reverse_payment(uuid,text),
  public.save_teacher_note(uuid,text,timestamptz), public.request_secretary_removal(uuid),
  public.mark_notification_read(uuid), public.get_daily_collections(date,uuid),
  public.generate_sessions(date,date), public.add_schedule(uuid,integer,time,time,date,date) to authenticated;
alter default privileges in schema public revoke execute on functions from public;
alter default privileges in schema private revoke execute on functions from public;
