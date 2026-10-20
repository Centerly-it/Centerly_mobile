begin read only;
select jsonb_build_object(
 'functions',(select jsonb_agg(jsonb_build_object('schema',n.nspname,'name',p.proname,
 'args',pg_get_function_identity_arguments(p.oid),'definition',pg_get_functiondef(p.oid),
 'public_execute',exists(select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a where a.grantee=0 and a.privilege_type='EXECUTE'),
 'anon_execute',has_function_privilege('anon',p.oid,'EXECUTE'),
 'authenticated_execute',has_function_privilege('authenticated',p.oid,'EXECUTE')) order by n.nspname,p.proname,pg_get_function_identity_arguments(p.oid))
 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
 where n.nspname in ('public','private') and p.proname<>'rls_auto_enable'
 and not exists(select 1 from pg_depend d where d.classid='pg_proc'::regclass and d.objid=p.oid and d.deptype='e')),
 'tables',(select jsonb_agg(jsonb_build_object('name',c.relname,'rls',c.relrowsecurity,'forced',c.relforcerowsecurity,
 'anon_read',has_table_privilege('anon',c.oid,'SELECT'),
 'authenticated_read',has_table_privilege('authenticated',c.oid,'SELECT'),
 'authenticated_insert',has_table_privilege('authenticated',c.oid,'INSERT'),
 'authenticated_update',has_table_privilege('authenticated',c.oid,'UPDATE'),
 'authenticated_delete',has_table_privilege('authenticated',c.oid,'DELETE')) order by c.relname)
 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='r'),
 'policies',(select jsonb_agg(to_jsonb(p) order by p.tablename,p.policyname) from pg_policies p where schemaname='public'),
 'indexes',(select jsonb_agg(jsonb_build_object('name',indexname,'definition',indexdef) order by indexname)
 from pg_indexes where schemaname='public'),
 'triggers',(select jsonb_agg(jsonb_build_object('table',c.relname,'name',t.tgname,'enabled',t.tgenabled,
 'definition',pg_get_triggerdef(t.oid)) order by c.relname,t.tgname)
 from pg_trigger t join pg_class c on c.oid=t.tgrelid join pg_namespace n on n.oid=c.relnamespace
 where n.nspname='public' and not t.tgisinternal),
 'constraints',(select jsonb_agg(jsonb_build_object('table',c.relname,'name',k.conname,'validated',k.convalidated,
 'definition',pg_get_constraintdef(k.oid)) order by c.relname,k.conname)
 from pg_constraint k join pg_class c on c.oid=k.conrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='public'),
 'invalid_enrollments',(select count(*) from public.group_enrollments where not
 ((status='active' and left_at is null) or (status='inactive' and left_at is not null and left_at>=joined_at))),
 'sizes',(select jsonb_agg(jsonb_build_object('table',relname,'bytes',pg_total_relation_size(c.oid)) order by relname)
 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname in ('payments','sessions','group_enrollments'))
) as hardening_inventory;
commit;
