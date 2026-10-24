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
