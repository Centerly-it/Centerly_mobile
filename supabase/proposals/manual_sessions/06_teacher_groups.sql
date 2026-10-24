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
