create or replace function public.generate_sessions(p_from date,p_to date) returns integer
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_count integer;
begin
  perform pg_advisory_xact_lock(hashtextextended(v_tenant::text||'schedule_generation',0));
  if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR'; end if;
  insert into public.sessions(teacher_id,group_id,schedule_id,local_date,starts_at,ends_at)
    select v_tenant,s.group_id,s.id,d::date,
      (d::date+s.local_start_time) at time zone 'Africa/Cairo',
      (d::date+case when s.local_end_time<s.local_start_time then 1 else 0 end+s.local_end_time) at time zone 'Africa/Cairo'
    from public.group_schedules s cross join generate_series(p_from::timestamp,p_to::timestamp,interval '1 day') d
    join public.groups g on g.id=s.group_id and g.teacher_id=s.teacher_id
    where s.teacher_id=v_tenant and s.retired_at is null and g.archived_at is null and extract(dow from d)=s.weekday
      and d::date>=s.effective_from and (s.effective_to is null or d::date<=s.effective_to)
    on conflict(schedule_id,local_date) do nothing;
  get diagnostics v_count=row_count;
  insert into public.attendance(teacher_id,session_id,student_id)
    select v_tenant,s.id,e.student_id from public.sessions s
    join public.group_enrollments e on e.group_id=s.group_id and e.teacher_id=s.teacher_id
    join public.students pupil on pupil.id=e.student_id and pupil.teacher_id=e.teacher_id and pupil.archived_at is null
    where s.teacher_id=v_tenant and s.local_date between p_from and p_to and s.status<>'cancelled'
      and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
    on conflict(session_id,student_id) do nothing;
  return v_count;
end $$;
