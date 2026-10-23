create or replace function public.secretary_enroll(p_group_id uuid,p_student_id uuid,p_enrollment_id uuid default null) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); v uuid;
begin
 if p_enrollment_id is null then
 insert into public.group_enrollments(teacher_id,group_id,student_id) values(t,p_group_id,p_student_id) returning id into v;
 insert into public.attendance(teacher_id,session_id,student_id)
 select t,id,p_student_id from public.sessions where teacher_id=t and group_id=p_group_id and status<>'cancelled' and ends_at>=statement_timestamp()
 on conflict(session_id,student_id) do nothing;
 else
 if not exists(select 1 from public.group_enrollments where id=p_enrollment_id and teacher_id=t and student_id=p_student_id and group_id=p_group_id and status='active') then raise exception 'CONFLICT';end if;
 if exists(select 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null) and exists(select 1 from public.students where id=p_student_id and teacher_id=t and archived_at is null) then
 perform private.bill_group_month(p_group_id,p_student_id,false);end if;
 update public.group_enrollments set status='inactive',left_at=clock_timestamp() where teacher_id=t and id=p_enrollment_id and group_id=p_group_id and student_id=p_student_id and status='active' returning id into v;
 if v is null then raise exception 'CONFLICT'; end if;
 end if;
 return v;
end $$;

create or replace function public.secretary_archive(p_entity text,p_id uuid) returns timestamptz
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');stamp timestamptz;e record;
begin
 if p_entity not in ('students','groups') then raise exception 'VALIDATION_ERROR';end if;
 for e in select en.group_id,en.student_id from public.group_enrollments en
  join public.groups g on g.id=en.group_id join public.students st on st.id=en.student_id
  where en.teacher_id=t and en.status='active' and g.archived_at is null and st.archived_at is null
  and ((p_entity='students' and en.student_id=p_id) or (p_entity='groups' and en.group_id=p_id))
  order by en.group_id,en.student_id loop
  perform private.bill_group_month(e.group_id,e.student_id,false);
 end loop;
 execute format('update public.%I set archived_at=coalesce(archived_at,clock_timestamp()) where id=$1 and teacher_id=$2 returning archived_at',p_entity) into stamp using p_id,t;
 if stamp is null then raise exception 'NOT_FOUND';end if;
 return stamp;
end $$;

-- Move and both groups' billing are one transaction; a failed target leaves the old membership intact.
create function public.secretary_transfer(p_enrollment_id uuid,p_group_id uuid) returns uuid
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');e public.group_enrollments;v uuid;
begin
 select * into e from public.group_enrollments where id=p_enrollment_id and teacher_id=t;
 if not found or e.status<>'active' or e.group_id=p_group_id then raise exception 'CONFLICT';end if;
 perform id from public.groups where teacher_id=t and id in(e.group_id,p_group_id) order by id for update;
 select * into e from public.group_enrollments where id=p_enrollment_id and teacher_id=t for update;
 if e.status<>'active' then raise exception 'CONFLICT';end if;
 v:=public.secretary_enroll(p_group_id,e.student_id);
 perform public.secretary_enroll(e.group_id,e.student_id,e.id);
 return v;
end $$;
revoke all on function public.secretary_transfer(uuid,uuid) from public,anon;
grant execute on function public.secretary_transfer(uuid,uuid) to authenticated;
