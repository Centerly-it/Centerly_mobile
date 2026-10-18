begin read only;
select jsonb_build_object(
  'application_tables',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='r'),
  'tables_without_forced_rls',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r' and (not c.relrowsecurity or not c.relforcerowsecurity)),
  'policy_count',(select count(*) from pg_policies where schemaname='public'),
  'migration_count',(select count(*) from supabase_migrations.schema_migrations),
  'unsafe_centerly_definers',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname in ('public','private') and p.prosecdef and p.proname<>'rls_auto_enable'
    and not coalesce(p.proconfig @> array['search_path=""'],false)),
  'anonymous_rpc_execute',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname<>'rls_auto_enable' and has_function_privilege('anon',p.oid,'EXECUTE')),
  'platform_helper_preserved',to_regprocedure('public.rls_auto_enable()') is not null,
  'auth_user_count',(select count(*) from auth.users)) as verification;
