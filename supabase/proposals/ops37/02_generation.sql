create or replace function public.generate_sessions(p_from date,p_to date) returns integer
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g record;r record;begins timestamptz;ends timestamptz;n integer:=0;
begin
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR';end if;
 -- Same group lock as dated manual creation: no duplicate/conflicting races.
 for g in select id from public.groups where teacher_id=t and archived_at is null order by id for update loop
  for r in select s.*,d::date as date from public.group_schedules s
    cross join generate_series(p_from::timestamp,p_to::timestamp,interval '1 day') d
    where s.teacher_id=t and s.group_id=g.id and s.retired_at is null and extract(dow from d)=s.weekday
     and d::date>=s.effective_from and (s.effective_to is null or d::date<=s.effective_to) order by d,s.id loop
   begins:=(r.date+r.local_start_time) at time zone 'Africa/Cairo';
   ends:=(r.date+case when r.local_end_time<r.local_start_time then 1 else 0 end+r.local_end_time) at time zone 'Africa/Cairo';
   if ends<=begins or (begins at time zone 'Africa/Cairo')::time<>r.local_start_time
    or (ends at time zone 'Africa/Cairo')::time<>r.local_end_time then raise exception 'VALIDATION_ERROR';end if;
   -- Existing exact dated sessions, including cancelled ones, are never recreated.
   if exists(select 1 from public.sessions where teacher_id=t and group_id=g.id and starts_at=begins and ends_at=ends) then continue;end if;
   if exists(select 1 from public.sessions where teacher_id=t and group_id=g.id and status<>'cancelled' and starts_at<ends and ends_at>begins)
    then raise exception 'CONFLICT';end if;
   insert into public.sessions(teacher_id,group_id,schedule_id,local_date,starts_at,ends_at)
    values(t,g.id,r.id,r.date,begins,ends) on conflict(schedule_id,local_date) do nothing;
   if found then n:=n+1;end if;
  end loop;
 end loop;
 insert into public.attendance(teacher_id,session_id,student_id)
  select t,s.id,e.student_id from public.sessions s
  join public.group_enrollments e on e.group_id=s.group_id and e.teacher_id=s.teacher_id
  join public.students st on st.id=e.student_id and st.teacher_id=e.teacher_id and st.archived_at is null
  where s.teacher_id=t and s.local_date between p_from and p_to and s.status<>'cancelled'
   and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
  on conflict(session_id,student_id) do nothing;
 return n;
end $$;
