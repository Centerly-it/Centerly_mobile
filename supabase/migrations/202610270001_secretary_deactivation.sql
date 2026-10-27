-- Stop application access without deleting Auth identities or historical records.
create function public.deactivate_secretary(p_secretary_id uuid) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid := private.require_actor('teacher'); v_status text;
begin
  select status into v_status from public.secretaries
    where id=p_secretary_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if v_status='inactive' then return p_secretary_id; end if;
  update public.secretaries set status='inactive'
    where id=p_secretary_id and teacher_id=v_tenant;
  update public.secretary_removal_requests set status='handled',handled_at=clock_timestamp()
    where teacher_id=v_tenant and secretary_id=p_secretary_id and status='pending';
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action)
    values(v_tenant,auth.uid(),'secretary',p_secretary_id,'deactivated');
  return p_secretary_id;
end $$;
revoke all on function public.deactivate_secretary(uuid) from public,anon,authenticated;
grant execute on function public.deactivate_secretary(uuid) to authenticated;
