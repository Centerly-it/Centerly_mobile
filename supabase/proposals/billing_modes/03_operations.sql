create function public.secretary_create_billing_group(p_id uuid,p_name text,p_subject text,p_mode text,p_price numeric,p_materials numeric,p_weekdays integer[],p_start time,p_end time)
returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');a public.audit_events;request jsonb;
begin
 perform private.billing_lock();
 if p_mode is null or p_mode not in('monthly','per_session') or p_price is null or p_price<0 or p_price>9999999999.99 or p_price<>round(p_price,2) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('name',p_name,'subject',p_subject,'mode',p_mode,'price',p_price,'materials',p_materials,'days',p_weekdays,'start',p_start,'end',p_end);
 select * into a from public.audit_events where teacher_id=t and entity_type='billing_group_create' and entity_id=p_id;
 if found then if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;return p_id;end if;
 if exists(select 1 from public.groups where id=p_id) then raise exception 'CONFLICT';end if;
 perform public.secretary_create_weekly_group(p_id,p_name,p_subject,case when p_mode='monthly' then p_price else 0 end,p_materials,p_weekdays,p_start,p_end);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(t,auth.uid(),'billing_group_create',p_id,'created',jsonb_build_object('request',request,'transaction_id',txid_current()::text));
 update public.groups set billing_mode=p_mode,session_fee_egp=case when p_mode='per_session' then p_price else 0 end where teacher_id=t and id=p_id;
 return p_id;
end $$;
revoke all on function public.secretary_create_billing_group(uuid,text,text,text,numeric,numeric,integer[],time,time) from public,anon;
grant execute on function public.secretary_create_billing_group(uuid,text,text,text,numeric,numeric,integer[],time,time) to authenticated;

create or replace function private.bill_group_month(p_group uuid,p_student uuid,p_materials boolean) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g public.groups;v uuid;
begin
 select * into g from public.groups where id=p_group and teacher_id=t;
 if g.billing_mode is distinct from 'per_session' then return private.billing_legacy_bill_group_month(p_group,p_student,p_materials);end if;
 if not p_materials or g.materials_fee_egp=0 then return null;end if;
 select id into v from public.invoices where teacher_id=t and student_id=p_student and group_id=p_group and billing_origin='session_group_materials';
 if v is not null then return v;end if;
 v:=public.create_invoice(p_student,g.materials_fee_egp,(statement_timestamp() at time zone 'Africa/Cairo')::date,'MATERIALS-'||gen_random_uuid(),p_group);
 update public.invoices set billing_origin='session_group_materials' where id=v;
 return v;
end $$;

create function private.bill_session_student(p_session uuid,p_student uuid) returns void language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');s public.sessions;v uuid;
begin
 select * into s from public.sessions where id=p_session and teacher_id=t and billing_mode='per_session' and status<>'cancelled';
 if not found then return;end if;
 if not exists(select 1 from public.group_enrollments e join public.students st on st.id=e.student_id and st.teacher_id=t where e.teacher_id=t and e.group_id=s.group_id and e.student_id=p_student and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at) and st.archived_at is null) then return;end if;
 insert into public.attendance(teacher_id,session_id,student_id) values(t,s.id,p_student) on conflict(session_id,student_id) do nothing;
 if s.fee_egp>0 and not exists(select 1 from public.invoices where teacher_id=t and session_id=s.id and student_id=p_student) then
  v:=public.create_invoice(p_student,s.fee_egp,s.local_date,'CLASS-'||s.id||'-'||p_student,s.group_id);
  update public.invoices set session_id=s.id,billing_origin='group_session',initial_amount_egp=s.fee_egp where id=v;
 end if;
end $$;
revoke all on function private.bill_session_student(uuid,uuid) from public,anon,authenticated;
create or replace function private.sync_manual_session(p_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');s public.sessions;e record;
begin
 select * into s from public.sessions where id=p_id and teacher_id=t;
 if s.billing_mode is distinct from 'per_session' then perform private.billing_legacy_sync_manual_session(p_id);return;end if;
 if s.status='cancelled' then return;end if;
 for e in select distinct student_id from public.group_enrollments where teacher_id=t and group_id=s.group_id and joined_at<=s.ends_at and (left_at is null or left_at>s.starts_at) order by student_id loop
  perform private.bill_session_student(s.id,e.student_id);
 end loop;
end $$;
-- Keep the original monthly trigger behavior; the new trigger handles only its new student.
create or replace function private.enrollment_manual_sessions() returns trigger language plpgsql security definer set search_path='' as $$
declare s record;
begin
 for s in select id from public.sessions where teacher_id=new.teacher_id and group_id=new.group_id and schedule_id is null and billing_mode is distinct from 'per_session' and status<>'cancelled' and ends_at>=clock_timestamp() order by id loop
  perform private.sync_manual_session(s.id);
 end loop;return new;
end $$;
create function private.bill_created_session() returns trigger language plpgsql security definer set search_path='' as $$
begin if new.billing_mode='per_session' then perform private.sync_manual_session(new.id);end if;return new;end $$;
create trigger bill_created_session after insert on public.sessions for each row execute function private.bill_created_session();
create function private.enrollment_session_billing() returns trigger language plpgsql security definer set search_path='' as $$
declare s record;
begin
 for s in select id from public.sessions where teacher_id=new.teacher_id and group_id=new.group_id and billing_mode='per_session' and status<>'cancelled' and ends_at>=clock_timestamp() order by id loop
  perform private.bill_session_student(s.id,new.student_id);
 end loop;return new;
end $$;
create trigger enrollment_session_billing after insert on public.group_enrollments for each row when(new.status='active') execute function private.enrollment_session_billing();
revoke all on function private.bill_created_session(),private.enrollment_session_billing() from public,anon,authenticated;

create function private.sync_attendance_settlement(p_invoice uuid) returns void language plpgsql security definer set search_path='' as $$
declare i public.invoices;paid numeric;target numeric;
begin
 select * into i from public.invoices where id=p_invoice for update;
 if i.billing_origin<>'group_session' or i.attendance_target_egp is null then return;end if;
 select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0) into paid from public.payments where invoice_id=i.id and teacher_id=i.teacher_id;
 target:=greatest(i.attendance_target_egp,paid);
 update public.invoices set amount_egp=target,attendance_settlement_required=paid>i.attendance_target_egp,
 status=case when target=paid then 'paid' when paid=0 then 'due' else 'partially_paid' end where id=i.id;
end $$;
revoke all on function private.sync_attendance_settlement(uuid) from public,anon,authenticated;

create function public.secretary_set_session_tariff(p_group_id uuid,p_price numeric,p_expected_price numeric,p_request_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g public.groups;a public.audit_events;request jsonb:=jsonb_build_object('group',p_group_id,'price',p_price,'expected',p_expected_price);
begin
 perform private.billing_lock();
 if p_group_id is null or p_request_id is null or p_price is null or p_price<0 or p_price>9999999999.99 or p_price<>round(p_price,2) then raise exception 'VALIDATION_ERROR';end if;
 select * into a from public.audit_events where teacher_id=t and entity_type='session_tariff' and entity_id=p_request_id;
 if found then if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;return p_group_id;end if;
 select * into g from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 if g.billing_mode<>'per_session' or p_expected_price is null or g.session_fee_egp<>p_expected_price then raise exception 'CONFLICT';end if;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(t,auth.uid(),'session_tariff',p_request_id,'updated',jsonb_build_object('group_id',p_group_id,'transaction_id',txid_current()::text,'request',request));
 update public.groups set session_fee_egp=p_price where id=g.id;return g.id;
end $$;
revoke all on function public.secretary_set_session_tariff(uuid,numeric,numeric,uuid) from public,anon;
grant execute on function public.secretary_set_session_tariff(uuid,numeric,numeric,uuid) to authenticated;
