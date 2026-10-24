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
