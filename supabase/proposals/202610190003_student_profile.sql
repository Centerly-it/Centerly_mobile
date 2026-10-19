-- PROPOSAL ONLY. Not managed/deployed; separate owner approval required.
-- Teacher-only student contacts and bounded membership history; no mutation/QR.
create function public.get_teacher_student_profile(p_id uuid,p_cursor uuid default null,
  p_limit integer default 30) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); v_student jsonb;
  v_rows jsonb; v_next uuid; v_count bigint;
begin
  if p_id is null or p_limit is null or p_limit not between 1 and 100 then
    raise exception 'VALIDATION_ERROR'; end if;
  select jsonb_build_object('id',id,'full_name',full_name,'phone',phone,
    'guardian_phone',guardian_phone,'level_tag',level_tag,'created_at',created_at,'updated_at',updated_at)
    into v_student from public.students where id=p_id and teacher_id=v_tenant and archived_at is null;
  if not found then raise exception 'NOT_FOUND'; end if;
  select count(*) into v_count from public.group_enrollments where student_id=p_id and teacher_id=v_tenant;
  with page as materialized (
    select e.id,e.group_id,e.status,e.joined_at,e.left_at,g.name as group_name,
      g.subject_name,g.archived_at as group_archived_at,l.name as grade_name
    from public.group_enrollments e
    join public.groups g on g.id=e.group_id and g.teacher_id=e.teacher_id
    join public.grade_levels l on l.id=g.grade_level_id and l.teacher_id=g.teacher_id
    where e.student_id=p_id and e.teacher_id=v_tenant and (p_cursor is null or e.id>p_cursor)
    order by e.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]'::jsonb)
      from (select * from page order by id limit p_limit) r),
    case when (select count(*) from page)>p_limit
      then (select id from page order by id offset p_limit-1 limit 1) else null end
    into v_rows,v_next;
  return jsonb_build_object('student',v_student,'memberships',v_rows,
    'membership_count',v_count,'next_cursor',v_next,'synced_at',statement_timestamp());
end $$;
revoke all on function public.get_teacher_student_profile(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_student_profile(uuid,uuid,integer) to authenticated;
