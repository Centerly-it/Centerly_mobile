-- Helpers owned by migration postgres (BYPASSRLS); avoids recursive membership policies.
grant usage on schema private to authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
grant execute on function private.tenant_id(), private.actor_role() to authenticated;
do $$ declare t text; begin
  foreach t in array array['teachers','secretaries','grade_levels','groups','students',
    'group_enrollments','group_schedules','sessions','attendance','exams','assignments',
    'invoices','payments','teacher_notes','notifications','secretary_removal_requests',
    'attendance_change_log','audit_events'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('alter table public.%I force row level security',t);
    execute format('revoke all on public.%I from anon, authenticated',t);
    execute format('grant select on public.%I to authenticated',t);
    if t='teachers' then
      execute 'create policy tenant_read on public.teachers for select to authenticated using(id=(select private.tenant_id()))';
    elsif t='notifications' then
      execute 'create policy tenant_read on public.notifications for select to authenticated using(teacher_id=(select private.tenant_id()) and recipient_id=(select auth.uid()))';
    else
      execute format('create policy tenant_read on public.%I for select to authenticated using(teacher_id=(select private.tenant_id()))',t);
      execute format('create index on public.%I (teacher_id)',t);
    end if;
  end loop;
  -- Sensitive writes exclusively through RPC; no client DELETE privileges anywhere.
  foreach t in array array['grade_levels','groups','students','group_enrollments','exams','assignments'] loop
    execute format('grant insert, update on public.%I to authenticated',t);
    execute format('create policy secretary_insert on public.%I for insert to authenticated with check(teacher_id=(select private.tenant_id()) and (select private.actor_role())=''secretary'')',t);
    execute format('create policy secretary_update on public.%I for update to authenticated using(teacher_id=(select private.tenant_id()) and (select private.actor_role())=''secretary'') with check(teacher_id=(select private.tenant_id()) and (select private.actor_role())=''secretary'')',t);
  end loop;
end $$;
create function private.stamp_record() returns trigger language plpgsql set search_path='' as $$
begin
  if tg_op='UPDATE' and (new.teacher_id<>old.teacher_id or new.id<>old.id) then raise exception 'TENANT_SCOPE'; end if;
  new.updated_at:=clock_timestamp();
  if tg_table_name in ('exams','assignments') then new.entered_by:=auth.uid(); end if;
  return new;
end $$;
create trigger stamp_student before insert or update on public.students for each row execute function private.stamp_record();
create trigger stamp_exam before insert or update on public.exams for each row execute function private.stamp_record();
create trigger stamp_assignment before insert or update on public.assignments for each row execute function private.stamp_record();
create function private.immutable() returns trigger language plpgsql set search_path='' as $$
begin raise exception 'APPEND_ONLY'; end $$;
create trigger immutable_payments before update or delete on public.payments for each row execute function private.immutable();
create trigger immutable_attendance_log before update or delete on public.attendance_change_log for each row execute function private.immutable();
create trigger immutable_audit before update or delete on public.audit_events for each row execute function private.immutable();
create index student_page on public.students(teacher_id,created_at,id);
create index session_dates on public.sessions(teacher_id,starts_at);
create index invoice_student on public.invoices(teacher_id,student_id);
create index collections_date on public.payments(teacher_id,collected_at);
