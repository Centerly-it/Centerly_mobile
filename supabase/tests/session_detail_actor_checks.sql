-- Read-only operator checks; role impersonation does not prove password Auth/SDK acceptance.
begin read only;
select set_config('centerly.ta',(select id::text from auth.users where email='teacher-a@centerly.test'),true);
select set_config('centerly.tb',(select id::text from auth.users where email='teacher-b@centerly.test'),true);
select set_config('centerly.sa',(select id::text from auth.users where email='secretary-a@centerly.test'),true);
select set_config('centerly.sb',(select id::text from auth.users where email='secretary-b@centerly.test'),true);
select set_config('centerly.sid',(select min(id::text) from public.sessions where teacher_id=current_setting('centerly.ta')::uuid),true);
select set_config('centerly.metadata',(select jsonb_build_object('definer',prosecdef,'config',proconfig,
 'anon',has_function_privilege('anon',oid,'EXECUTE'),'authenticated',has_function_privilege('authenticated',oid,'EXECUTE'),
 'public_execute',exists(select 1 from aclexplode(proacl) where grantee=0 and privilege_type='EXECUTE'))::text
 from pg_proc where oid='public.get_teacher_session_detail(uuid,text,uuid,integer)'::regprocedure),true);
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('centerly.ta'),true);
do $$ declare s record; d jsonb; p jsonb; expected jsonb; n integer:=0; cancelled integer:=0; pending integer:=0; begin
 for s in select * from public.sessions loop
  d:=public.get_teacher_session_detail(s.id);
  select jsonb_build_object('present',count(*) filter(where status='present'),'absent',count(*) filter(where status='absent'),
    'excused',count(*) filter(where status='excused'),'not_marked',count(*) filter(where status='not_marked')) into expected
    from public.attendance where session_id=s.id;
  if d->'attendance_counts'<>expected then raise exception 'COUNTS_DIFFER'; end if;
  if (d->>'filtered_count')::int<>(select count(*) from public.attendance where session_id=s.id) then raise exception 'COUNT_DIFFER'; end if;
  p:=public.get_teacher_session_detail(s.id,null,null,1);
  if jsonb_array_length(p->'attendance')>1 then raise exception 'PAGE_UNBOUNDED'; end if;
  if p->>'next_cursor' is not null then
    if jsonb_array_length(public.get_teacher_session_detail(s.id,null,(p->>'next_cursor')::uuid,1)->'attendance')=0 then raise exception 'EMPTY_NEXT_PAGE'; end if;
  end if;
  p:=public.get_teacher_session_detail(s.id,'not_marked');
  if jsonb_array_length(p->'attendance')<>(expected->>'not_marked')::int then raise exception 'PENDING_INFERRED'; end if;
  pending:=pending+(expected->>'not_marked')::int;
  if s.status='cancelled' then cancelled:=cancelled+(d->>'filtered_count')::int; end if;
  n:=n+1;
 end loop;
 if n=0 then raise exception 'NO_TEACHER_FIXTURES'; end if;
 perform set_config('centerly.results',jsonb_build_object('teacher_sessions_checked',n,'counts_match',true,
   'bounded_pages',true,'not_marked_filter_matches_persisted',true,'positive_not_marked_rows',pending,
   'positive_cancelled_history_rows',cancelled)::text,true);
 begin perform public.get_teacher_session_detail('00000000-0000-0000-0000-000000000000'); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.tb'),true);
do $$ begin
 begin perform public.get_teacher_session_detail(current_setting('centerly.sid')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.sa'),true);
do $$ begin
 begin perform public.get_teacher_session_detail(current_setting('centerly.sid')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.sb'),true);
do $$ begin
 begin perform public.get_teacher_session_detail(current_setting('centerly.sid')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
end $$;
-- No row is created: this checks unprovisioned denial, not a real inactive fixture.
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000000',true);
do $$ begin
 begin perform public.get_teacher_session_detail(current_setting('centerly.sid')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'ACCOUNT_INACTIVE' then raise; end if; end;
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform public.get_teacher_session_detail(current_setting('centerly.sid')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when insufficient_privilege then null; end;
end $$;
select jsonb_build_object('metadata',current_setting('centerly.metadata')::jsonb,'fixture_checks',current_setting('centerly.results')::jsonb,
 'tenant_denial',true,'both_secretaries_denied',true,'anonymous_denied',true,'missing_session_denied',true,
 'unprovisioned_denied',true,'inactive_existing_fixture_tested',false) as session_detail_checks;
rollback;
