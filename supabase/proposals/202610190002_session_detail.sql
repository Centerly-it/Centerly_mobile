-- PROPOSAL ONLY: not a managed/deployed migration. Requires separate approval.
-- Reads persisted manual attendance; does not backfill or infer absent students.
create function public.get_teacher_session_detail(p_id uuid,p_status text default null,
  p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); v_session public.sessions;
  v_rows jsonb; v_next uuid; v_counts jsonb; v_filtered bigint;
begin
  if p_id is null or p_limit is null or p_limit not between 1 and 100
    or (p_status is not null and p_status not in ('present','absent','excused','not_marked'))
    then raise exception 'VALIDATION_ERROR'; end if;
  select * into v_session from public.sessions where id=p_id and teacher_id=v_tenant;
  if not found then raise exception 'NOT_FOUND'; end if;
  select jsonb_build_object('present',count(*) filter(where status='present'),
    'absent',count(*) filter(where status='absent'),'excused',count(*) filter(where status='excused'),
    'not_marked',count(*) filter(where status='not_marked')),
    count(*) filter(where p_status is null or status=p_status)
    into v_counts,v_filtered from public.attendance where teacher_id=v_tenant and session_id=p_id;
  with page as materialized (
    select a.id,a.student_id,s.full_name,a.status,a.marked_at,a.updated_at,
      coalesce((select name from public.secretaries where id=a.marked_by and teacher_id=v_tenant),
        (select name from public.teachers where id=a.marked_by and id=v_tenant)) as marked_by_name
    from public.attendance a join public.students s on s.id=a.student_id and s.teacher_id=a.teacher_id
    where a.teacher_id=v_tenant and a.session_id=p_id and (p_status is null or a.status=p_status)
      and (p_cursor is null or a.id>p_cursor) order by a.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]'::jsonb)
      from (select * from page order by id limit p_limit) r),
    case when (select count(*) from page)>p_limit
      then (select id from page order by id offset p_limit-1 limit 1) else null end
    into v_rows,v_next;
  return jsonb_build_object('session',to_jsonb(v_session)||jsonb_build_object(
    'group_name',(select name from public.groups where id=v_session.group_id and teacher_id=v_tenant),
    'subject_name',(select subject_name from public.groups where id=v_session.group_id and teacher_id=v_tenant),
    'cancelled_by_name',coalesce(
      (select name from public.secretaries where id=v_session.cancelled_by and teacher_id=v_tenant),
      (select name from public.teachers where id=v_session.cancelled_by and id=v_tenant))),
    'attendance_counts',v_counts,'filtered_count',v_filtered,'attendance',v_rows,'next_cursor',v_next,
    'synced_at',statement_timestamp());
end $$;
revoke all on function public.get_teacher_session_detail(uuid,text,uuid,integer) from public,anon;
grant execute on function public.get_teacher_session_detail(uuid,text,uuid,integer) to authenticated;
