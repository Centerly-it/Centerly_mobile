-- Owner-approved product scope; LOCAL REVIEW ONLY, not deployed.
-- Immutable deployed migrations and RLS policies are unchanged.
create function private.restore_is_authorized(p_entity text,p_id uuid,p_before timestamptz) returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.audit_events a where a.teacher_id=(select tenant_id from private.identity())
  and a.actor_id=auth.uid() and a.entity_type='record_restore' and a.action='restored'
  and a.metadata->>'entity'=p_entity and a.metadata->>'target_id'=p_id::text
  and (a.metadata->>'before_archived_at')::timestamptz=p_before
  and a.metadata->>'transaction_id'=txid_current()::text)
$$;
revoke all on function private.restore_is_authorized(text,uuid,timestamptz) from public,anon,authenticated;

create or replace function private.archived_student_write_guard() returns trigger
language plpgsql security definer set search_path='' as $$
declare student uuid;tenant uuid;stamp timestamptz;issued timestamptz;
begin
 if tg_table_name='students' then
  if old.archived_at is not null then
   if new.archived_at is not null or (to_jsonb(new)-'archived_at'-'updated_at') is distinct from (to_jsonb(old)-'archived_at'-'updated_at')
    or not private.restore_is_authorized('students',old.id,old.archived_at) then raise exception 'CONFLICT';end if;
  end if;
  return new;
 end if;
 tenant:=new.teacher_id;
 if tg_table_name='payments' then
  if new.reversal_of is not null then return new;end if;
  select student_id,created_at into student,issued from public.invoices where id=new.invoice_id and teacher_id=tenant;
 else student:=new.student_id;end if;
 select archived_at into stamp from public.students where id=student and teacher_id=tenant for share;
 if not found then raise exception 'NOT_FOUND';end if;
 -- Only collection against an invoice actually issued before archival is permitted.
 if stamp is not null and not(tg_table_name='payments' and issued<=stamp) then raise exception 'CONFLICT';end if;
 if tg_op='UPDATE' then
  if new.teacher_id<>old.teacher_id then raise exception 'CONFLICT';end if;
  if tg_table_name<>'payments' then
   if new.student_id<>old.student_id then raise exception 'CONFLICT';end if;
  end if;
 end if;
 return new;
end $$;

create function private.group_restore_guard() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if old.archived_at is not null and new.archived_at is null then
  if (to_jsonb(new)-'archived_at'-'updated_at') is distinct from (to_jsonb(old)-'archived_at'-'updated_at')
   or not private.restore_is_authorized('groups',old.id,old.archived_at) then raise exception 'CONFLICT';end if;
 end if;
 return new;
end $$;
revoke all on function private.group_restore_guard() from public,anon,authenticated;
create trigger group_restore_authorization before update on public.groups for each row execute function private.group_restore_guard();

create function public.secretary_restore(p_entity text,p_id uuid,p_request uuid) returns jsonb
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');matched integer;stamp timestamptz;a public.audit_events;r record;result jsonb;today date:=(now() at time zone 'Africa/Cairo')::date;
begin
 if p_entity is null or p_entity not in('students','groups') or p_id is null or p_request is null then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_request::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='record_restore' and entity_id=p_request;
 if found then
  if a.metadata->>'entity'<>p_entity or a.metadata->>'target_id'<>p_id::text then raise exception 'CONFLICT';end if;
  return a.metadata->'result';
 end if;
 execute format('select archived_at from public.%I where id=$1 and teacher_id=$2 for update',p_entity) into stamp using p_id,t;
 get diagnostics matched=row_count;
 if matched=0 then raise exception 'NOT_FOUND';end if;
 result:=jsonb_build_object('id',p_id,'restored',stamp is not null);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'record_restore',p_request,'restored',jsonb_build_object('entity',p_entity,'target_id',p_id,
  'before_archived_at',stamp,'transaction_id',txid_current()::text,'result',result));
 if stamp is null then return result;end if;
 execute format('update public.%I set archived_at=null where id=$1 and teacher_id=$2',p_entity) using p_id,t;
 if p_entity='groups' then
  for r in select * from public.group_schedules where teacher_id=t and group_id=p_id and retired_at is null
    and (effective_to is null or effective_to>=today) order by id for update loop
   update public.group_schedules set retired_at=clock_timestamp() where id=r.id;
   insert into public.group_schedules(teacher_id,group_id,weekday,local_start_time,local_end_time,effective_from,effective_to)
    values(t,p_id,r.weekday,r.local_start_time,r.local_end_time,greatest(today,r.effective_from),r.effective_to);
  end loop;
 end if;
 -- Never reset enrollment status/left_at/joined_at or change historical sessions.
 return result;
end $$;
revoke all on function public.secretary_restore(text,uuid,uuid) from public,anon;
grant execute on function public.secretary_restore(text,uuid,uuid) to authenticated;
