alter table public.group_schedules add column retired_at timestamptz;
alter table public.sessions add column fee_egp numeric(12,2) not null default 0
 check(fee_egp>=0 and fee_egp<=9999999999.99);
alter table public.invoices add column session_id uuid;
alter table public.invoices add constraint invoice_session_tenant foreign key(teacher_id,session_id)
 references public.sessions(teacher_id,id);
create unique index invoice_session_student on public.invoices(teacher_id,session_id,student_id) where session_id is not null;

create function public.secretary_set_group_timetable(p_group_id uuid,p_weekdays integer[],p_start time,p_end time,p_request_id uuid)
returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');d integer;a public.audit_events;days integer[];request jsonb;
begin
 if p_group_id is null or p_request_id is null or p_weekdays is null or cardinality(p_weekdays) not between 1 and 7
  or array_ndims(p_weekdays)<>1 or exists(select 1 from unnest(p_weekdays) x where x is null or x not between 0 and 6)
  or p_start is null or p_end is null or p_start=p_end then raise exception 'VALIDATION_ERROR';end if;
 select array_agg(distinct x order by x) into days from unnest(p_weekdays) x;
 if cardinality(days)<>cardinality(p_weekdays) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('group',p_group_id,'days',days,'start',p_start,'end',p_end);
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 select * into a from public.audit_events where teacher_id=t and entity_type='group_timetable' and entity_id=p_request_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_group_id;
 end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 update public.group_schedules set retired_at=clock_timestamp() where teacher_id=t and group_id=p_group_id
  and retired_at is null and (effective_to is null or effective_to>=(now() at time zone 'Africa/Cairo')::date);
 foreach d in array days loop
  perform public.add_schedule(p_group_id,d,p_start,p_end,(now() at time zone 'Africa/Cairo')::date);
 end loop;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'group_timetable',p_request_id,'edited',jsonb_build_object('request',request));
 return p_group_id;
end $$;
revoke all on function public.secretary_set_group_timetable(uuid,integer[],time,time,uuid) from public,anon;
grant execute on function public.secretary_set_group_timetable(uuid,integer[],time,time,uuid) to authenticated;

create or replace function private.schedule_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.groups where id=new.group_id and teacher_id=new.teacher_id and archived_at is null for update;
 if not found then raise exception 'CONFLICT'; end if;
 if exists(select 1 from public.group_schedules s where s.group_id=new.group_id and s.retired_at is null and s.id<>new.id
 and exists(select 1 from generate_series(-1,1) shift where numrange(s.weekday*86400+extract(epoch from s.local_start_time),s.weekday*86400+extract(epoch from s.local_end_time)+case when s.local_end_time<s.local_start_time then 86400 else 0 end,'[)') && numrange(new.weekday*86400+extract(epoch from new.local_start_time)+shift*604800,new.weekday*86400+extract(epoch from new.local_end_time)+case when new.local_end_time<new.local_start_time then 86400 else 0 end+shift*604800,'[)'))
 and daterange(s.effective_from,s.effective_to,'[]') && daterange(new.effective_from,new.effective_to,'[]')) then raise exception 'CONFLICT'; end if;
 return new;
end $$;

create function private.sync_manual_session(p_id uuid) returns void
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');s public.sessions;e record;v uuid;
begin
 select * into s from public.sessions where id=p_id and teacher_id=t and status<>'cancelled' for update;
 if not found then raise exception 'NOT_FOUND';end if;
 for e in select distinct en.student_id from public.group_enrollments en join public.students st
  on st.id=en.student_id and st.teacher_id=en.teacher_id where en.teacher_id=t and en.group_id=s.group_id
  and en.joined_at<=s.ends_at and (en.left_at is null or en.left_at>s.starts_at) and st.archived_at is null
  order by en.student_id loop
  insert into public.attendance(teacher_id,session_id,student_id) values(t,s.id,e.student_id)
   on conflict(session_id,student_id) do nothing;
  if s.fee_egp>0 and not exists(select 1 from public.invoices where teacher_id=t and session_id=s.id and student_id=e.student_id) then
   v:=public.create_invoice(e.student_id,s.fee_egp,s.local_date,'CLASS-'||s.id||'-'||e.student_id,s.group_id);
   update public.invoices set session_id=s.id where id=v and teacher_id=t;
  end if;
 end loop;
end $$;
revoke all on function private.sync_manual_session(uuid) from public,anon,authenticated;

create function private.enrollment_manual_sessions() returns trigger
language plpgsql security definer set search_path='' as $$
declare s record;
begin
 for s in select id from public.sessions where teacher_id=new.teacher_id and group_id=new.group_id
  and schedule_id is null and status<>'cancelled' and ends_at>=clock_timestamp() order by id loop
  perform private.sync_manual_session(s.id);
 end loop;
 return new;
end $$;
revoke all on function private.enrollment_manual_sessions() from public,anon,authenticated;
create trigger enrollment_manual_sessions after insert on public.group_enrollments
 for each row when(new.status='active') execute function private.enrollment_manual_sessions();

create function public.secretary_create_session(p_id uuid,p_group_id uuid,p_date date,p_start time,p_end time,p_amount numeric default 0)
returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');a public.audit_events;begins timestamptz;ends timestamptz;
 request jsonb:=jsonb_build_object('group',p_group_id,'date',p_date,'start',p_start,'end',p_end,'amount',p_amount);
begin
 if p_id is null or p_group_id is null or p_date is null or p_start is null or p_end is null or p_start=p_end
  or p_amount is null or p_amount<0 or p_amount>9999999999.99 or p_amount<>round(p_amount,2)
 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_id::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='manual_session' and entity_id=p_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_id;
 end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 begins:=(p_date+p_start) at time zone 'Africa/Cairo';
 ends:=(p_date+case when p_end<p_start then 1 else 0 end+p_end) at time zone 'Africa/Cairo';
 if ends<=begins or (begins at time zone 'Africa/Cairo')::time<>p_start or (ends at time zone 'Africa/Cairo')::time<>p_end
 then raise exception 'VALIDATION_ERROR';end if;
 if exists(select 1 from public.sessions where teacher_id=t and group_id=p_group_id and status<>'cancelled'
  and starts_at<ends and ends_at>begins) then raise exception 'CONFLICT';end if;
 insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at,fee_egp)
 values(p_id,t,p_group_id,p_date,begins,ends,p_amount);
 perform private.sync_manual_session(p_id);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'manual_session',p_id,'created',jsonb_build_object('request',request));
 return p_id;
end $$;
revoke all on function public.secretary_create_session(uuid,uuid,date,time,time,numeric) from public,anon;
grant execute on function public.secretary_create_session(uuid,uuid,date,time,time,numeric) to authenticated;

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

create or replace function public.list_teacher_groups(p_search text default null,
  p_grade_level_id uuid default null,p_cursor uuid default null,p_limit integer default 30)
returns setof jsonb language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher');
begin
  if p_limit is null or p_limit not between 1 and 100 or length(coalesce(p_search,''))>200
    then raise exception 'VALIDATION_ERROR'; end if;
  return query select jsonb_build_object(
    'id',g.id,'name',g.name,'subject_name',g.subject_name,'capacity',g.capacity,
    'grade_level_id',g.grade_level_id,'grade_name',l.name,
    'students_count',(select count(*) from public.group_enrollments e
      join public.students s on s.id=e.student_id and s.teacher_id=e.teacher_id
      where e.teacher_id=v_tenant and e.group_id=g.id and e.status='active' and s.archived_at is null),
    'roster_preview',(select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]'::jsonb)
      from (select s.id,s.full_name from public.group_enrollments e
        join public.students s on s.id=e.student_id and s.teacher_id=e.teacher_id
        where e.teacher_id=v_tenant and e.group_id=g.id and e.status='active' and s.archived_at is null
        order by s.id limit 5) r),
    'schedules_truncated',(select count(*)>32 from public.group_schedules q where q.teacher_id=v_tenant and q.group_id=g.id and q.retired_at is null),
    'schedules',(select coalesce(jsonb_agg(to_jsonb(r) order by r.weekday,r.local_start_time,r.id),'[]'::jsonb)
      from (select q.id,q.weekday,q.local_start_time,q.local_end_time,q.effective_from,q.effective_to
        from public.group_schedules q where q.teacher_id=v_tenant and q.group_id=g.id and q.retired_at is null
        order by q.weekday,q.local_start_time,q.id limit 32) r))
  from public.groups g join public.grade_levels l on l.id=g.grade_level_id and l.teacher_id=g.teacher_id
  where g.teacher_id=v_tenant and g.archived_at is null and (p_cursor is null or g.id>p_cursor)
    and (p_grade_level_id is null or g.grade_level_id=p_grade_level_id)
    and (nullif(trim(p_search),'') is null or g.name ilike '%'||trim(p_search)||'%'
      or g.subject_name ilike '%'||trim(p_search)||'%')
  order by g.id limit p_limit;
end $$;
