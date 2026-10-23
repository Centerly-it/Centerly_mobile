-- New authenticated groups require an atomic first weekly schedule.
revoke insert on public.groups from authenticated;
create or replace function public.secretary_create_group(p_id uuid,p_name text,p_subject text,
 p_monthly numeric default 0,p_materials numeric default 0) returns uuid
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g public.groups;
begin
 select * into g from public.groups where id=p_id and teacher_id=t;
 if found and g.archived_at is null and g.name=trim(p_name) and g.subject_name=trim(p_subject)
  and g.monthly_fee_egp=p_monthly and g.materials_fee_egp=p_materials then return g.id;end if;
 raise exception 'VALIDATION_ERROR';
end $$;

create function public.secretary_create_scheduled_group(p_id uuid,p_name text,p_subject text,
 p_monthly numeric,p_materials numeric,p_weekday integer,p_start time,p_end time,p_from date,p_to date default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');grade uuid;sid uuid;a public.audit_events;
 request jsonb:=jsonb_build_object('name',trim(p_name),'subject',trim(p_subject),'monthly',p_monthly,
 'materials',p_materials,'weekday',p_weekday,'start',p_start,'end',p_end,'from',p_from,'to',p_to);
begin
 if p_id is null or nullif(trim(p_name),'') is null or nullif(trim(p_subject),'') is null
  or length(p_name)>200 or length(p_subject)>200 or p_monthly is null or p_materials is null
  or p_monthly<0 or p_materials<0 or p_monthly<>round(p_monthly,2) or p_materials<>round(p_materials,2)
  or p_monthly+p_materials>9999999999.99 or p_weekday is null or p_weekday not between 0 and 6
  or p_start is null or p_end is null or p_start=p_end or p_from is null
  or (p_to is not null and (p_to<p_from or p_to<(now() at time zone 'Africa/Cairo')::date))
 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||'simple_group_creation',0));
 select * into a from public.audit_events where teacher_id=t and entity_type='scheduled_group_creation' and entity_id=p_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_id;
 end if;
 if exists(select 1 from public.groups where id=p_id) then raise exception 'CONFLICT';end if;
 select id into grade from public.grade_levels where teacher_id=t and name='عام' order by id limit 1;
 if grade is null then insert into public.grade_levels(teacher_id,name) values(t,'عام') returning id into grade;end if;
 insert into public.groups(id,teacher_id,grade_level_id,name,subject_name,capacity,monthly_fee_egp,materials_fee_egp)
 values(p_id,t,grade,trim(p_name),trim(p_subject),2147483647,p_monthly,p_materials);
 sid:=public.add_schedule(p_id,p_weekday,p_start,p_end,p_from,p_to);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'scheduled_group_creation',p_id,'created',jsonb_build_object('request',request,'schedule_id',sid));
 return p_id;
end $$;
revoke all on function public.secretary_create_scheduled_group(uuid,text,text,numeric,numeric,integer,time,time,date,date) from public,anon;
grant execute on function public.secretary_create_scheduled_group(uuid,text,text,numeric,numeric,integer,time,time,date,date) to authenticated;
