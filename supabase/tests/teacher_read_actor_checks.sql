-- Operator-only role impersonation in a READ ONLY transaction, not an Auth-login test.
-- Uses known synthetic account IDs resolved from email. Never reads passwords/hashes.
begin read only;
select set_config('centerly.check_teacher_a',(select id::text from auth.users where email='teacher-a@centerly.test'),true);
select set_config('centerly.check_teacher_b',(select id::text from auth.users where email='teacher-b@centerly.test'),true);
select set_config('centerly.check_secretary_a',(select id::text from auth.users where email='secretary-a@centerly.test'),true);
select set_config('centerly.check_secretary_b',(select id::text from auth.users where email='secretary-b@centerly.test'),true);
select set_config('centerly.check_other_group',(select min(id::text) from public.groups where teacher_id=current_setting('centerly.check_teacher_b')::uuid),true);
select set_config('centerly.check_other_grade',(select min(id::text) from public.grade_levels where teacher_id=current_setting('centerly.check_teacher_b')::uuid),true);
select set_config('centerly.check_date',(select min(local_date)::text from public.sessions where teacher_id=current_setting('centerly.check_teacher_a')::uuid),true);
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('centerly.check_teacher_a'),true);
select set_config('centerly.check_result_a',jsonb_build_object(
  'teacher_profile',public.get_current_profile()->>'role'='teacher',
  'groups_match_scoped_rls',not exists(select 1 from public.list_teacher_groups(p_limit=>100) g
    where not exists(select 1 from public.groups x where x.id=(g->>'id')::uuid)),
  'other_grade_hidden',not exists(select 1 from public.list_teacher_groups(p_grade_level_id=>current_setting('centerly.check_other_grade')::uuid)),
  'other_group_sessions_hidden',not exists(select 1 from public.list_teacher_sessions(current_setting('centerly.check_date')::date,
    current_setting('centerly.check_date')::date,current_setting('centerly.check_other_group')::uuid)),
  'session_names_match',not exists(select 1 from public.list_teacher_sessions(current_setting('centerly.check_date')::date,
    current_setting('centerly.check_date')::date) s join public.groups g on g.id=(s->>'group_id')::uuid
    where s->>'group_name'<>g.name or s->>'subject_name'<>g.subject_name),
  'attendance_counts_match',coalesce((select bool_and(
    public.get_teacher_overview(d.local_date)->'attendance_counts'=(select jsonb_build_object(
      'present',count(*) filter(where a.status='present'),'absent',count(*) filter(where a.status='absent'),
      'excused',count(*) filter(where a.status='excused'),'not_marked',count(*) filter(where a.status='not_marked'))
      from public.attendance a join public.sessions s on s.id=a.session_id and s.teacher_id=a.teacher_id
      where s.local_date=d.local_date and s.status<>'cancelled'))
    from (select distinct local_date from public.sessions) d),false),
  'fixture_session_count',(select count(*) from public.sessions),
  'positive_not_marked_rows',(select count(*) from public.attendance where status='not_marked'),
  'positive_cancelled_attendance_rows',(select count(*) from public.attendance a join public.sessions s on s.id=a.session_id where s.status='cancelled')
)::text,true);
select set_config('request.jwt.claim.sub',current_setting('centerly.check_teacher_b'),true);
select set_config('centerly.check_result_b',jsonb_build_object(
  'teacher_profile',public.get_current_profile()->>'role'='teacher',
  'teacher_a_groups_hidden',not exists(select 1 from public.groups where teacher_id=current_setting('centerly.check_teacher_a')::uuid),
  'teacher_a_sessions_hidden',not exists(select 1 from public.sessions where teacher_id=current_setting('centerly.check_teacher_a')::uuid),
  'groups_match_scoped_rls',not exists(select 1 from public.list_teacher_groups(p_limit=>100) g
    where not exists(select 1 from public.groups x where x.id=(g->>'id')::uuid)),
  'overview_counts_match',(public.get_teacher_overview(current_setting('centerly.check_date')::date)->'attendance_counts')=
    (select jsonb_build_object('present',count(*) filter(where a.status='present'),'absent',count(*) filter(where a.status='absent'),
      'excused',count(*) filter(where a.status='excused'),'not_marked',count(*) filter(where a.status='not_marked'))
    from public.attendance a join public.sessions s on s.id=a.session_id where s.local_date=current_setting('centerly.check_date')::date and s.status<>'cancelled')
)::text,true);
select set_config('request.jwt.claim.sub',current_setting('centerly.check_secretary_a'),true);
do $$ begin
  begin perform public.get_teacher_overview(); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
  begin perform public.list_teacher_groups(); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
  begin perform public.list_teacher_sessions(current_date,current_date); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.check_secretary_b'),true);
do $$ begin
  begin perform public.get_teacher_overview(); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
  begin perform public.list_teacher_groups(); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
  begin perform public.list_teacher_sessions(current_date,current_date); raise exception 'UNEXPECTED_ALLOW';
    exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
end $$;
select true as secretary_three_reads_denied;
reset role;
set local role anon;
do $$ begin
  begin perform public.get_teacher_overview(); raise exception 'UNEXPECTED_ALLOW'; exception when insufficient_privilege then null; end;
  begin perform public.list_teacher_groups(); raise exception 'UNEXPECTED_ALLOW'; exception when insufficient_privilege then null; end;
  begin perform public.list_teacher_sessions(current_date,current_date); raise exception 'UNEXPECTED_ALLOW'; exception when insufficient_privilege then null; end;
end $$;
select jsonb_build_object('teacher_a',current_setting('centerly.check_result_a')::jsonb,
  'teacher_b',current_setting('centerly.check_result_b')::jsonb,'secretary_three_reads_denied',true,
  'anonymous_three_reads_denied',true) as teacher_read_actor_checks;
rollback;
