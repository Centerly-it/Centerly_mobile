-- PACKAGE PROPOSAL ONLY. Scores are decimal strings; missing scores remain null.
create function public.get_teacher_student_academics(p_id uuid,p_kind text,p_from date,p_to date,
 p_group_id uuid default null,p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_teacher_student(p_id); result jsonb; stats jsonb; n bigint; begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_kind is null or p_kind not in ('exams','assignments') then raise exception 'VALIDATION_ERROR'; end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
   then raise exception 'NOT_FOUND'; end if;
 if p_kind='exams' then
  select count(*),jsonb_build_object('scored',count(score_percent),'missing',count(*)-count(score_percent),
    'average_percent',round(avg(score_percent),2)::text,
    'below_50',count(*) filter(where score_percent<50),'from_50_to_64',count(*) filter(where score_percent>=50 and score_percent<65),
    'from_65_to_79',count(*) filter(where score_percent>=65 and score_percent<80),'from_80_to_100',count(*) filter(where score_percent>=80))
   into n,stats from public.exams where teacher_id=t and student_id=p_id and held_on between p_from and p_to
    and (p_group_id is null or group_id=p_group_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select e.id,e.title,e.held_on as date,e.score_percent::text as score_percent,e.updated_at,
    e.group_id,(select name from public.groups where id=e.group_id and teacher_id=t) as group_name,
    (select name from public.secretaries where id=e.entered_by and teacher_id=t) as entered_by_name
   from public.exams e where e.teacher_id=t and e.student_id=p_id and e.held_on between p_from and p_to
    and (p_group_id is null or e.group_id=p_group_id) and (p_cursor is null or e.id>p_cursor) order by e.id limit p_limit+1) r;
 else
  select count(*),jsonb_build_object('pending',count(*) filter(where status='pending'),
    'submitted',count(*) filter(where status='submitted'),'late',count(*) filter(where status='late'))
   into n,stats from public.assignments where teacher_id=t and student_id=p_id and due_on between p_from and p_to
    and (p_group_id is null or group_id=p_group_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select a.id,a.title,a.due_on as date,a.status,a.updated_at,a.group_id,
    (select name from public.groups where id=a.group_id and teacher_id=t) as group_name,
    (select name from public.secretaries where id=a.entered_by and teacher_id=t) as entered_by_name
   from public.assignments a where a.teacher_id=t and a.student_id=p_id and a.due_on between p_from and p_to
    and (p_group_id is null or a.group_id=p_group_id) and (p_cursor is null or a.id>p_cursor) order by a.id limit p_limit+1) r;
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;
revoke all on function public.get_teacher_student_academics(uuid,text,date,date,uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_student_academics(uuid,text,date,date,uuid,uuid,integer) to authenticated;
