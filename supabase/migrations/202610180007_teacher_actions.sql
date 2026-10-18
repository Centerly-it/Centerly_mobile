create function public.save_teacher_note(p_student_id uuid,p_content text,p_expected_updated_at timestamptz default null)
returns timestamptz language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); n public.teacher_notes; v_time timestamptz:=clock_timestamp();
begin
  if p_content is null or length(p_content)>10000 then raise exception 'VALIDATION_ERROR'; end if;
  perform 1 from public.students where id=p_student_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  select * into n from public.teacher_notes where teacher_id=v_tenant and student_id=p_student_id;
  if (found and (p_expected_updated_at is null or n.updated_at<>p_expected_updated_at))
    or (not found and p_expected_updated_at is not null) then raise exception 'CONFLICT'; end if;
  insert into public.teacher_notes(teacher_id,student_id,content,updated_at) values(v_tenant,p_student_id,p_content,v_time)
    on conflict(teacher_id,student_id) do update set content=excluded.content,updated_at=excluded.updated_at;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action)
    values(v_tenant,auth.uid(),'student',p_student_id,'note_saved');
  return v_time;
end $$;
create function public.request_secretary_removal(p_secretary_id uuid) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); v_id uuid;
begin
  perform 1 from public.secretaries where id=p_secretary_id and teacher_id=v_tenant and status='active' for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  select id into v_id from public.secretary_removal_requests where teacher_id=v_tenant and secretary_id=p_secretary_id and status='pending';
  if found then return v_id; end if;
  insert into public.secretary_removal_requests(teacher_id,secretary_id) values(v_tenant,p_secretary_id) returning id into v_id;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action)
    values(v_tenant,auth.uid(),'secretary_removal_request',v_id,'requested');
  return v_id;
end $$;
create function public.mark_notification_read(p_id uuid) returns void
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor(); begin
  update public.notifications set read_at=coalesce(read_at,clock_timestamp())
    where id=p_id and teacher_id=v_tenant and recipient_id=auth.uid();
  if not found then raise exception 'NOT_FOUND'; end if;
end $$;
create function public.get_daily_collections(p_date date,p_secretary_id uuid default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor(); begin
  return (select jsonb_build_object('date',p_date,'net_collected_egp',coalesce(sum(
    case when reversal_of is null then amount_egp else -amount_egp end),0)) from public.payments
    where teacher_id=v_tenant and collected_at>=p_date::timestamp at time zone 'Africa/Cairo'
      and collected_at<(p_date+1)::timestamp at time zone 'Africa/Cairo'
      and (p_secretary_id is null or collected_by=p_secretary_id));
end $$;
