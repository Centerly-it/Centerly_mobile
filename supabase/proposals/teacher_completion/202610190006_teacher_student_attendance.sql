-- PACKAGE PROPOSAL ONLY. History includes cancelled; trend counts exclude them.
create function public.get_teacher_student_attendance(p_id uuid,p_from date,p_to date,
 p_group_id uuid default null,p_status text default null,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_teacher_student(p_id); result jsonb; stats jsonb; n bigint; begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_status is not null and p_status not in ('present','absent','excused','not_marked') then raise exception 'VALIDATION_ERROR'; end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
   then raise exception 'NOT_FOUND'; end if;
 select jsonb_build_object('present',count(*) filter(where a.status='present' and s.status<>'cancelled'),
  'absent',count(*) filter(where a.status='absent' and s.status<>'cancelled'),
  'excused',count(*) filter(where a.status='excused' and s.status<>'cancelled'),
  'not_marked',count(*) filter(where a.status='not_marked' and s.status<>'cancelled'),
  'marked_denominator',count(*) filter(where a.status<>'not_marked' and s.status<>'cancelled'),
  'cancelled_records',count(*) filter(where s.status='cancelled')),
  count(*) filter(where p_status is null or a.status=p_status) into stats,n
 from public.attendance a join public.sessions s on s.id=a.session_id and s.teacher_id=a.teacher_id
 where a.teacher_id=t and a.student_id=p_id and s.local_date between p_from and p_to
  and (p_group_id is null or s.group_id=p_group_id);
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
  select a.id,a.session_id,a.status,a.marked_at,a.updated_at,
   (select name from public.secretaries where id=a.marked_by and teacher_id=t) as marked_by_name,
   s.local_date,s.starts_at,s.ends_at,s.status as session_status,s.attendance_finalized_at,s.group_id,
   (select name from public.groups where id=s.group_id and teacher_id=t) as group_name
  from public.attendance a join public.sessions s on s.id=a.session_id and s.teacher_id=a.teacher_id
  where a.teacher_id=t and a.student_id=p_id and s.local_date between p_from and p_to
   and (p_group_id is null or s.group_id=p_group_id) and (p_status is null or a.status=p_status)
   and (p_cursor is null or a.id>p_cursor) order by a.id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;
revoke all on function public.get_teacher_student_attendance(uuid,date,date,uuid,text,uuid,integer) from public,anon;
grant execute on function public.get_teacher_student_attendance(uuid,date,date,uuid,text,uuid,integer) to authenticated;
