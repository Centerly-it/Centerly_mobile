-- Atomic multi-day group creation; start date is Cairo today, not a form field.
create function public.secretary_create_weekly_group(p_id uuid,p_name text,p_subject text,
 p_monthly numeric,p_materials numeric,p_weekdays integer[],p_start time,p_end time)
returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');days integer[];d integer;a public.audit_events;request jsonb;
begin
 if p_weekdays is null or cardinality(p_weekdays) not between 1 and 7
  or array_ndims(p_weekdays)<>1 or exists(select 1 from unnest(p_weekdays) x where x is null or x not between 0 and 6)
 then raise exception 'VALIDATION_ERROR';end if;
 select array_agg(distinct x order by x) into days from unnest(p_weekdays) x;
 if cardinality(days)<>cardinality(p_weekdays) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('name',trim(p_name),'subject',trim(p_subject),'monthly',p_monthly,
  'materials',p_materials,'days',days,'start',p_start,'end',p_end);
 perform pg_advisory_xact_lock(hashtextextended(t::text||'simple_group_creation',0));
 select * into a from public.audit_events where teacher_id=t and entity_type='weekly_group_creation' and entity_id=p_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_id;
 end if;
 perform public.secretary_create_scheduled_group(p_id,p_name,p_subject,p_monthly,p_materials,
  days[1],p_start,p_end,(now() at time zone 'Africa/Cairo')::date);
 foreach d in array days loop
  if d<>days[1] then perform public.add_schedule(p_id,d,p_start,p_end,(now() at time zone 'Africa/Cairo')::date);end if;
 end loop;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'weekly_group_creation',p_id,'created',jsonb_build_object('request',request));
 return p_id;
end $$;
revoke all on function public.secretary_create_weekly_group(uuid,text,text,numeric,numeric,integer[],time,time) from public,anon;
grant execute on function public.secretary_create_weekly_group(uuid,text,text,numeric,numeric,integer[],time,time) to authenticated;
