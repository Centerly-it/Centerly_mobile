-- Owning teachers can restore application access; Auth and history are untouched.
create function public.reactivate_secretary(p_secretary_id uuid) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid := private.require_actor('teacher'); v_status text; v_seats integer;
begin
  -- Serialize seat allocation across different secretary reactivations.
  select secretary_seats into v_seats from public.teachers where id=v_tenant for update;
  select status into v_status from public.secretaries
    where id=p_secretary_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if v_status='active' then return p_secretary_id; end if;
  if (select count(*) from public.secretaries where teacher_id=v_tenant and status='active') >= v_seats
    then raise exception 'CONFLICT'; end if;
  update public.secretaries set status='active'
    where id=p_secretary_id and teacher_id=v_tenant;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action)
    values(v_tenant,auth.uid(),'secretary',p_secretary_id,'reactivated');
  return p_secretary_id;
end $$;
revoke all on function public.reactivate_secretary(uuid) from public,anon,authenticated;
grant execute on function public.reactivate_secretary(uuid) to authenticated;
