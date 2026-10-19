-- Read-only structural and relational verification. No fixture mutations.
begin read only;
select jsonb_build_object(
  'functions',(select jsonb_agg(jsonb_build_object(
    'name',p.proname,'arguments',pg_get_function_identity_arguments(p.oid),
    'security_definer',p.prosecdef,'config',p.proconfig,
    'anon_execute',has_function_privilege('anon',p.oid,'EXECUTE'),
    'authenticated_execute',has_function_privilege('authenticated',p.oid,'EXECUTE')) order by p.proname)
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname in ('get_teacher_overview','list_teacher_groups','list_teacher_sessions')),
  'migration_versions',(select jsonb_agg(version order by version) from supabase_migrations.schema_migrations),
  'not_marked_rows',(select count(*) from public.attendance where status='not_marked'),
  'cancelled_attendance_rows',(select count(*) from public.attendance a join public.sessions s
    on s.id=a.session_id and s.teacher_id=a.teacher_id where s.status='cancelled')
) as teacher_read_postflight;
commit;
