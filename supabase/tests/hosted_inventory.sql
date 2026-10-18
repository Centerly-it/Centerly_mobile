begin read only;
select jsonb_build_object(
 'public_tables',(select coalesce(jsonb_agg(tablename order by tablename),'[]'::jsonb) from pg_tables where schemaname='public'),
 'private_tables',(select coalesce(jsonb_agg(tablename order by tablename),'[]'::jsonb) from pg_tables where schemaname='private'),
 'functions',(select coalesce(jsonb_agg(jsonb_build_object('schema',n.nspname,'name',p.proname,'arguments',pg_get_function_identity_arguments(p.oid))),'[]'::jsonb) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname in ('public','private')),
 'policies',(select count(*) from pg_policies where schemaname in ('public','private')),
 'auth_user_count',(select count(*) from auth.users),
 'migration_history',to_regclass('supabase_migrations.schema_migrations'),
 'postgres_version',current_setting('server_version')) as inventory;
