-- Read-only operator checks. Not password Auth/SDK acceptance; no fixture writes.
begin read only;
select set_config('centerly.ta',(select id::text from auth.users where email='teacher-a@centerly.test'),true);
select set_config('centerly.tb',(select id::text from auth.users where email='teacher-b@centerly.test'),true);
select set_config('centerly.sa',(select id::text from auth.users where email='secretary-a@centerly.test'),true);
select set_config('centerly.sb',(select id::text from auth.users where email='secretary-b@centerly.test'),true);
select set_config('centerly.student',(select min(id::text) from public.students where teacher_id=current_setting('centerly.ta')::uuid and archived_at is null),true);
select set_config('centerly.metadata',(select jsonb_build_object('definer',prosecdef,'config',proconfig,
 'anon',has_function_privilege('anon',oid,'EXECUTE'),'authenticated',has_function_privilege('authenticated',oid,'EXECUTE'),
 'public_execute',exists(select 1 from aclexplode(proacl) where grantee=0 and privilege_type='EXECUTE'))::text
 from pg_proc where oid='public.get_teacher_student_profile(uuid,uuid,integer)'::regprocedure),true);
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('centerly.ta'),true);
do $$ declare s record; d jsonb; n integer:=0; begin
 for s in select * from public.students where archived_at is null loop
  d:=public.get_teacher_student_profile(s.id,null,1);
  if d->'student'->>'id'<>s.id::text or d->'student'->>'full_name'<>s.full_name
   or d->'student'->>'phone' is distinct from s.phone
   or d->'student'->>'guardian_phone' is distinct from s.guardian_phone then raise exception 'CONTACT_MISMATCH'; end if;
  if (d->>'membership_count')::int<>(select count(*) from public.group_enrollments where student_id=s.id)
   or jsonb_array_length(d->'memberships')>1 then raise exception 'PAGE_MISMATCH'; end if;
  if exists(select 1 from jsonb_array_elements(d->'memberships') m where not exists(
   select 1 from public.group_enrollments e where e.id=(m->>'id')::uuid and e.student_id=s.id)) then raise exception 'MEMBERSHIP_SCOPE'; end if;
  n:=n+1;
 end loop;
 if n=0 then raise exception 'NO_FIXTURES'; end if;
 perform set_config('centerly.checked',n::text,true);
 begin perform public.get_teacher_student_profile('00000000-0000-0000-0000-000000000000');raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if;end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.tb'),true);
do $$ begin
 begin perform public.get_teacher_student_profile(current_setting('centerly.student')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if;end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.sa'),true);
do $$ begin
 begin perform public.get_teacher_student_profile(current_setting('centerly.student')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if;end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.sb'),true);
do $$ begin
 begin perform public.get_teacher_student_profile(current_setting('centerly.student')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if;end;
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform public.get_teacher_student_profile(current_setting('centerly.student')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when insufficient_privilege then null;end;
end $$;
select jsonb_build_object('metadata',current_setting('centerly.metadata')::jsonb,'students_checked',current_setting('centerly.checked')::int,
 'contact_and_membership_match',true,'tenant_denial',true,'secretary_denials',true,'anonymous_denial',true,'missing_denial',true) as profile_checks;
rollback;
