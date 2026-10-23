-- Simplified creation: an internal reference year and an internal unbounded UI capacity.
create function public.secretary_create_group(p_id uuid,p_name text,p_subject text,
 p_monthly numeric default 0,p_materials numeric default 0) returns uuid
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g public.groups;grade uuid;
begin
 if p_id is null or nullif(trim(p_name),'') is null or nullif(trim(p_subject),'') is null
  or length(p_name)>200 or length(p_subject)>200 or p_monthly is null or p_materials is null
  or p_monthly<0 or p_materials<0 or p_monthly<>round(p_monthly,2) or p_materials<>round(p_materials,2)
  or p_monthly+p_materials>9999999999.99 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||'simple_group_creation',0));
 select * into g from public.groups where id=p_id and teacher_id=t;
 if found then
  if g.name<>trim(p_name) or g.subject_name<>trim(p_subject) or g.monthly_fee_egp<>p_monthly
   or g.materials_fee_egp<>p_materials or g.archived_at is not null then raise exception 'CONFLICT';end if;
  return g.id;
 end if;
 select id into grade from public.grade_levels where teacher_id=t and name='عام' order by id limit 1;
 if grade is null then insert into public.grade_levels(teacher_id,name) values(t,'عام') returning id into grade;end if;
 insert into public.groups(id,teacher_id,grade_level_id,name,subject_name,capacity,monthly_fee_egp,materials_fee_egp)
 values(p_id,t,grade,trim(p_name),trim(p_subject),2147483647,p_monthly,p_materials);
 return p_id;
end $$;
revoke all on function public.secretary_create_group(uuid,text,text,numeric,numeric) from public,anon;
grant execute on function public.secretary_create_group(uuid,text,text,numeric,numeric) to authenticated;

create function public.secretary_create_student(p_id uuid,p_group_id uuid,p_name text,
 p_phone text default null,p_guardian_phone text default null,p_level text default null) returns uuid
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');s public.students;
begin
 if p_id is null or p_group_id is null or nullif(trim(p_name),'') is null or length(p_name)>200
  or length(p_phone)>200 or length(p_guardian_phone)>200 or length(p_level)>200 then raise exception 'VALIDATION_ERROR';end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_id::text,0));
 select * into s from public.students where id=p_id and teacher_id=t;
 if found then
  if (s.full_name,s.phone,s.guardian_phone,s.level_tag) is distinct from
   (trim(p_name),nullif(trim(p_phone),''),nullif(trim(p_guardian_phone),''),nullif(trim(p_level),''))
   or s.archived_at is not null or not exists(select 1 from public.group_enrollments
    where teacher_id=t and student_id=p_id and group_id=p_group_id and status='active') then raise exception 'CONFLICT';end if;
  return s.id;
 end if;
 insert into public.students(id,teacher_id,full_name,phone,guardian_phone,level_tag)
 values(p_id,t,trim(p_name),nullif(trim(p_phone),''),nullif(trim(p_guardian_phone),''),nullif(trim(p_level),''));
 perform public.secretary_enroll(p_group_id,p_id);
 return p_id;
end $$;
revoke all on function public.secretary_create_student(uuid,uuid,text,text,text,text) from public,anon;
grant execute on function public.secretary_create_student(uuid,uuid,text,text,text,text) to authenticated;
