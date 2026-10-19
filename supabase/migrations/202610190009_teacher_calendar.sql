-- PACKAGE PROPOSAL ONLY. Derive display status from authoritative server time.
create function public.get_teacher_calendar(p_from date,p_to date,p_group_id uuid default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; begin
 if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR'; end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 select coalesce(jsonb_agg(to_jsonb(r) order by r.starts_at,r.id),'[]') into result from (
  select s.id,s.group_id,s.local_date,s.starts_at,s.ends_at,s.attendance_finalized_at,
   s.status as stored_status,case when s.status='cancelled' then 'cancelled'
    when statement_timestamp()<s.starts_at then 'upcoming'
    when statement_timestamp()<s.ends_at then 'ongoing' else 'completed' end as status,
   g.name as group_name,g.subject_name
  from public.sessions s join public.groups g on g.id=s.group_id and g.teacher_id=s.teacher_id
  where s.teacher_id=t and s.local_date between p_from and p_to and (p_group_id is null or s.group_id=p_group_id)) r;
 return jsonb_build_object('sessions',result,'synced_at',statement_timestamp(),
  'server_date',(statement_timestamp() at time zone 'Africa/Cairo')::date);
end $$;
revoke all on function public.get_teacher_calendar(date,date,uuid) from public,anon;
grant execute on function public.get_teacher_calendar(date,date,uuid) to authenticated;
