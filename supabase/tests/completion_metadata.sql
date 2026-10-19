begin read only;
select jsonb_build_object(
 'functions',(select jsonb_agg(jsonb_build_object('schema',n.nspname,'name',p.proname,
  'config',p.proconfig,'definer',p.prosecdef,
  'public_execute',exists(select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a where grantee=0 and privilege_type='EXECUTE'),
  'anon_execute',has_function_privilege('anon',p.oid,'EXECUTE'),
  'authenticated_execute',has_function_privilege('authenticated',p.oid,'EXECUTE')) order by n.nspname,p.proname)
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace where
  (n.nspname='public' and p.proname in ('get_teacher_student_academics','get_teacher_student_attendance',
   'get_teacher_finance','get_teacher_student_note','list_teacher_secretaries','list_teacher_notifications','get_teacher_calendar'))
  or (n.nspname='private' and p.proname in ('require_teacher_student','check_teacher_window','teacher_page','notify_teacher_payment','notify_teacher_removal_handled'))),
 'indexes',(select jsonb_agg(indexname order by indexname) from pg_indexes where schemaname='public' and indexname in
  ('teacher_exam_history','teacher_assignment_history','teacher_attendance_history','teacher_invoice_history','teacher_payment_history','teacher_notification_page')),
 'triggers',(select jsonb_agg(jsonb_build_object('name',tgname,'table',c.relname,'enabled',tgenabled,
   'function',p.proname,'definition',pg_get_triggerdef(t.oid)) order by tgname)
  from pg_trigger t join pg_class c on c.oid=t.tgrelid join pg_proc p on p.oid=t.tgfoid
  where not t.tgisinternal and tgname in ('notify_teacher_payment','notify_teacher_removal_handled'))
) as completion_metadata;
commit;
