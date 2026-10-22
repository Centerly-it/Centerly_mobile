-- READ ONLY: existing synthetic identities; SQL role simulation, not password Auth.
begin read only;
do $$ declare registry jsonb; begin
 select jsonb_object_agg(case email when 'teacher-a@centerly.test' then 'ta' when 'teacher-b@centerly.test' then 'tb' when 'secretary-a@centerly.test' then 'sa' when 'secretary-b@centerly.test' then 'sb' end,id) into registry from auth.users where email in ('teacher-a@centerly.test','teacher-b@centerly.test','secretary-a@centerly.test','secretary-b@centerly.test');
 if (select count(*) from jsonb_object_keys(registry))<>4 then raise exception 'SYNTHETIC_IDENTITIES_MISSING'; end if;
 registry:=registry||jsonb_build_object('student_a',(select id from public.students where teacher_id=(registry->>'ta')::uuid limit 1),'student_b',(select id from public.students where teacher_id=(registry->>'tb')::uuid limit 1));
 perform set_config('centerly.read_registry',registry::text,true);
end $$;
set local role authenticated;
do $$ declare r jsonb:=current_setting('centerly.read_registry')::jsonb; actor text; tenant uuid; entity text; page jsonb; dashboard jsonb; n bigint; expected numeric; d date; checks int:=0; denied boolean; begin
 foreach actor in array array['sa','sb'] loop
  tenant:=(r->>case actor when 'sa' then 'ta' else 'tb' end)::uuid;
  perform set_config('request.jwt.claim.sub',r->>actor,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',r->>actor,'role','authenticated','user_metadata',jsonb_build_object('teacher_id',r->>'tb','role','teacher'))::text,true);
  if public.get_current_profile()->>'teacher_id'<>tenant::text then raise exception 'PROFILE_SCOPE'; end if;checks:=checks+1;
  foreach entity in array array['students','grade_levels','groups','group_enrollments','group_schedules','sessions','attendance','attendance_change_log','exams','assignments','invoices','payments','teacher_notes','notifications','secretaries'] loop
   page:=public.secretary_browse(entity,'{}','',null,1);
   execute format('select count(*) from public.%I',entity) into n;
   if (page->>'total_count')::bigint<>n or jsonb_array_length(page->'rows')>1 then raise exception 'COUNT_OR_BOUND'; end if;
   if exists(select 1 from jsonb_array_elements(page->'rows') x where x->>'teacher_id'<>tenant::text) then raise exception 'TENANT_LEAK'; end if;
   if entity='notifications' and exists(select 1 from jsonb_array_elements(page->'rows') x where x->>'recipient_id'<>r->>actor) then raise exception 'RECIPIENT_LEAK'; end if;
   checks:=checks+1;
  end loop;
  page:=public.secretary_browse('students',jsonb_build_object('id',r->>case actor when 'sa' then 'student_b' else 'student_a' end));
  if (page->>'total_count')::int<>0 then raise exception 'FOREIGN_ID_LEAK'; end if;checks:=checks+1;
  dashboard:=public.secretary_dashboard();d:=(dashboard->>'server_date')::date;
  select coalesce(sum(i.amount_egp-coalesce(p.paid,0)),0) into expected from public.invoices i left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where invoice_id=i.id) p on true where i.status<>'void';
  if (dashboard->>'outstanding_egp')::numeric<>expected then raise exception 'OUTSTANDING_MISMATCH'; end if;checks:=checks+1;
  select coalesce(sum(i.amount_egp-coalesce(p.paid,0)),0) into expected from public.invoices i left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where invoice_id=i.id) p on true where i.status<>'void' and i.due_on<=d;
  if (dashboard->>'due_egp')::numeric<>expected then raise exception 'DUE_MISMATCH'; end if;checks:=checks+1;
  select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0) into expected from public.payments where collected_at>=d::timestamp at time zone 'Africa/Cairo' and collected_at<(d+1)::timestamp at time zone 'Africa/Cairo';
  if (dashboard->>'collected_egp')::numeric<>expected then raise exception 'CASH_MISMATCH'; end if;checks:=checks+1;
  denied:=false;begin perform public.get_teacher_overview(d);exception when raise_exception then if sqlerrm='FORBIDDEN_ROLE' then denied:=true;else raise;end if;end;if not denied then raise exception 'SECRETARY_ALLOWED_TEACHER_REPORT';end if;checks:=checks+1;
 end loop;
 foreach actor in array array['ta','tb'] loop
  perform set_config('request.jwt.claim.sub',r->>actor,true);
  perform public.get_teacher_overview((statement_timestamp() at time zone 'Africa/Cairo')::date);checks:=checks+1;
  denied:=false;begin perform public.secretary_dashboard();exception when raise_exception then if sqlerrm='FORBIDDEN_ROLE' then denied:=true;else raise;end if;end;if not denied then raise exception 'TEACHER_ALLOWED_SECRETARY_REPORT';end if;checks:=checks+1;
 end loop;
 perform set_config('request.jwt.claim.sub','ce27ffff-0000-4000-8000-000000000001',true);
 denied:=false;begin perform public.secretary_dashboard();exception when raise_exception then if sqlerrm='ACCOUNT_INACTIVE' then denied:=true;else raise;end if;end;if not denied then raise exception 'UNPROVISIONED_ALLOWED';end if;checks:=checks+1;
 perform set_config('centerly.read_checks',checks::text,true);
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform public.secretary_dashboard();raise exception 'ANON_ALLOWED';exception when insufficient_privilege then null;end;
 begin perform public.secretary_browse('students');raise exception 'ANON_ALLOWED';exception when insufficient_privilege then null;end;
end $$;
select jsonb_build_object('pass',true,'checks',current_setting('centerly.read_checks')::int+2,'mode','READ ONLY SQL role simulation; not password Auth; no fixture mutations') as secretary_readonly;
rollback;
