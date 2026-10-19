-- Operator inspection only. Never deploy from this file.
begin read only;
select jsonb_build_object(
  'migration_history',(select jsonb_agg(jsonb_build_object(
    'version',version,'name',name,'statements',statements) order by version)
    from supabase_migrations.schema_migrations),
  'application_tables',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r'),
  'policy_count',(select count(*) from pg_policies where schemaname='public'),
  'tables_without_forced_rls',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r' and (not c.relrowsecurity or not c.relforcerowsecurity)),
  'unsafe_definers',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname in ('public','private') and p.prosecdef and p.proname<>'rls_auto_enable'
    and not coalesce(p.proconfig @> array['search_path=""'],false)),
  'anonymous_rpc_execute',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname<>'rls_auto_enable' and has_function_privilege('anon',p.oid,'EXECUTE')),
  'new_functions_present',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname in ('get_teacher_overview','list_teacher_groups','list_teacher_sessions')),
  'detail_function_present',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='get_teacher_session_detail'),
  'profile_function_present',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='get_teacher_student_profile'),
  'auth_user_count',(select count(*) from auth.users),
  'approved_account_count',(select count(*) from auth.users
    where email in ('teacher-a@centerly.test','teacher-b@centerly.test','secretary-a@centerly.test','secretary-b@centerly.test')),
  'platform_helper_preserved',to_regprocedure('public.rls_auto_enable()') is not null
) as teacher_read_preflight;
commit;
