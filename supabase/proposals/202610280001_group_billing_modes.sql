-- BILL: additive monthly/per-session billing. Local review, not deployed.
-- Additive: existing groups and all issued financial values retain their meaning.
alter table public.groups add column billing_mode text not null default 'monthly' check(billing_mode in ('monthly','per_session')),
 add column session_fee_egp numeric(12,2) not null default 0 check(session_fee_egp>=0 and session_fee_egp<=9999999999.99);
alter table public.sessions add column billing_mode text;
alter table public.sessions add constraint session_billing_mode_check check(billing_mode is null or billing_mode in ('monthly','per_session'));
alter table public.invoices add column billing_origin text not null default 'legacy',
 add column attendance_target_egp numeric(12,2) check(attendance_target_egp>=0),
 add column attendance_settlement_required boolean not null default false,
 add column attendance_reviewed_at timestamptz;
create unique index one_initial_session_group_materials on public.invoices(teacher_id,group_id,student_id)
 where billing_origin='session_group_materials';
create function private.billing_lock() returns void language plpgsql security definer set search_path='' as $$
begin perform pg_advisory_xact_lock(hashtextextended(private.require_actor()::text||'session_billing',0));end $$;
revoke all on function private.billing_lock() from public,anon,authenticated;
create function private.group_billing_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.billing_mode<>old.billing_mode and not exists(select 1 from public.audit_events a
  where a.teacher_id=old.teacher_id and a.actor_id=auth.uid() and a.entity_type='billing_group_create'
   and a.entity_id=old.id and a.metadata->>'transaction_id'=txid_current()::text)
 then raise exception 'CONFLICT';end if;
 if new.session_fee_egp<>old.session_fee_egp and not exists(select 1 from public.audit_events a where a.teacher_id=old.teacher_id and a.actor_id=auth.uid() and a.entity_type in ('billing_group_create','session_tariff') and a.metadata->>'transaction_id'=txid_current()::text and (a.entity_id=old.id or a.metadata->>'group_id'=old.id::text)) then raise exception 'CONFLICT';end if;
 if new.billing_mode='per_session' and new.monthly_fee_egp<>0 then raise exception 'VALIDATION_ERROR';end if;
 return new;
end $$;
create trigger group_billing_guard before update on public.groups for each row execute function private.group_billing_guard();
revoke all on function private.group_billing_guard() from public,anon,authenticated;
create function private.session_billing_snapshot() returns trigger language plpgsql security definer set search_path='' as $$
declare g public.groups;
begin
 select * into g from public.groups where id=new.group_id and teacher_id=new.teacher_id;
 if not found then raise exception 'NOT_FOUND';end if;
 new.billing_mode:=g.billing_mode;
 if g.billing_mode='per_session' and new.fee_egp=0 then new.fee_egp:=g.session_fee_egp;end if;
 return new;
end $$;
create trigger session_billing_snapshot before insert on public.sessions for each row execute function private.session_billing_snapshot();
revoke all on function private.session_billing_snapshot() from public,anon,authenticated;

create index eligible_session_billing_enrollments on public.sessions(teacher_id,group_id,ends_at) where billing_mode='per_session' and status<>'cancelled';

CREATE OR REPLACE FUNCTION private.billing_legacy_bill_group_month(p_group uuid, p_student uuid, p_materials boolean)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');g public.groups;v uuid;m numeric:=0;
 period date;anchor date;e public.group_enrollments;today date:=(statement_timestamp() at time zone 'Africa/Cairo')::date;
begin
 select * into g from public.groups where id=p_group and teacher_id=t for update;
 if not found or g.archived_at is not null then raise exception 'NOT_FOUND';end if;
 if not exists(select 1 from public.group_enrollments where teacher_id=t and group_id=p_group
  and student_id=p_student and status='active') or not exists(select 1 from public.students
  where id=p_student and teacher_id=t and archived_at is null) then raise exception 'CONFLICT';end if;
 select * into e from public.group_enrollments where teacher_id=t and group_id=p_group
  and student_id=p_student and status='active' for update;
 select min((joined_at at time zone 'Africa/Cairo')::date) into anchor from public.group_enrollments
  where teacher_id=t and group_id=p_group and student_id=p_student;
 if e.last_billed_on is null then
  period:=private.billing_cycle_on(anchor,(e.joined_at at time zone 'Africa/Cairo')::date);
 else
  period:=private.billing_cycle_next(anchor,e.last_billed_on);
 end if;
 while period<=today loop
 select id into v from public.invoices where teacher_id=t and student_id=p_student
  and group_id=p_group and billing_period_start=period;
 if found then
  update public.group_enrollments set last_billed_on=period where id=e.id;
  period:=private.billing_cycle_next(anchor,period);continue;end if;
 -- Rejoining the same group never charges its materials again, including voided bills.
 if p_materials and not exists(select 1 from public.invoices where teacher_id=t and student_id=p_student
  and group_id=p_group and billing_period_start is not null and materials_fee_egp>0) then m:=g.materials_fee_egp;end if;
 if g.monthly_fee_egp+m>0 then
 insert into public.invoices(teacher_id,student_id,group_id,invoice_number,amount_egp,due_on,
  created_by,billing_period_start,monthly_fee_egp,materials_fee_egp)
 values(t,p_student,p_group,'AUTO-'||gen_random_uuid()::text,g.monthly_fee_egp+m,
  period,auth.uid(),period,g.monthly_fee_egp,m)
 returning id into v;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'invoice',v,'created',jsonb_build_object('source','group_pricing','billing_period_start',period));
 end if;
 update public.group_enrollments set last_billed_on=period where id=e.id;
 p_materials:=false;m:=0;period:=private.billing_cycle_next(anchor,period);
 end loop;
 return v;
end $function$;
revoke all on function private.billing_legacy_bill_group_month(uuid,uuid,boolean) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION private.billing_legacy_sync_manual_session(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');s public.sessions;e record;v uuid;
begin
 select * into s from public.sessions where id=p_id and teacher_id=t and status<>'cancelled' for update;
 if not found then raise exception 'NOT_FOUND';end if;
 for e in select distinct en.student_id from public.group_enrollments en join public.students st
  on st.id=en.student_id and st.teacher_id=en.teacher_id where en.teacher_id=t and en.group_id=s.group_id
  and en.joined_at<=s.ends_at and (en.left_at is null or en.left_at>s.starts_at) and st.archived_at is null
  order by en.student_id loop
  insert into public.attendance(teacher_id,session_id,student_id) values(t,s.id,e.student_id)
   on conflict(session_id,student_id) do nothing;
  if s.fee_egp>0 and not exists(select 1 from public.invoices where teacher_id=t and session_id=s.id and student_id=e.student_id) then
   v:=public.create_invoice(e.student_id,s.fee_egp,s.local_date,'CLASS-'||s.id||'-'||e.student_id,s.group_id);
   update public.invoices set session_id=s.id where id=v and teacher_id=t;
  end if;
 end loop;
end $function$;
revoke all on function private.billing_legacy_sync_manual_session(uuid) from public,anon,authenticated;

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

create function public.get_session_billing(p_session_id uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor();s public.sessions;rows jsonb;v text;
begin
 select * into s from public.sessions where id=p_session_id and teacher_id=t;
 if not found then raise exception 'NOT_FOUND';end if;
 with details as (
  select a.id,a.student_id,st.full_name student_name,a.status attendance_status,a.updated_at attendance_updated_at,
   i.id invoice_id,i.status invoice_status,i.amount_egp::text amount_egp,coalesce(i.initial_amount_egp,s.fee_egp)::text fee_egp,
   i.attendance_reviewed_at,i.attendance_target_egp::text attendance_target_egp,i.attendance_settlement_required,
   coalesce(p.paid,0)::numeric(20,2)::text paid_egp,coalesce(p.signature,'') payment_version,
   (case when s.status<>'cancelled' and a.status='present' and (st.archived_at is null or st.archived_at>=s.ends_at) and exists(select 1 from public.groups g where g.id=s.group_id and g.teacher_id=t and (g.archived_at is null or g.archived_at>=s.ends_at)) and exists(select 1 from public.group_enrollments e where e.teacher_id=t and e.group_id=s.group_id and e.student_id=a.student_id and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)) and i.status is distinct from 'void' then coalesce(i.initial_amount_egp,s.fee_egp) else 0 end)::numeric(20,2) target
  from public.attendance a join public.students st on st.id=a.student_id and st.teacher_id=t
  left join public.invoices i on i.teacher_id=t and i.session_id=s.id and i.student_id=a.student_id
  left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid,string_agg(id::text,',' order by id) signature from public.payments where teacher_id=t and invoice_id=i.id) p on true
  where a.teacher_id=t and a.session_id=s.id
 )select coalesce(jsonb_agg(to_jsonb(d)-'target'||jsonb_build_object('target_egp',target::text,
   'proposed_amount_egp',greatest(target,paid_egp::numeric)::numeric(20,2)::text,
   'settlement_required',paid_egp::numeric>target) order by d.student_id),'[]') into rows from details d;
 v:=md5(jsonb_build_object('session',s.id,'status',s.status,'fee',s.fee_egp,'rows',rows)::text);
 return jsonb_build_object('session_id',s.id,'billing_mode',coalesce(s.billing_mode,'monthly'),'fee_egp',s.fee_egp::text,'status',s.status,'version',v,'rows',rows);
end $$;
revoke all on function public.get_session_billing(uuid) from public,anon;
grant execute on function public.get_session_billing(uuid) to authenticated;

create function private.billing_financial_authorized(p_invoice uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.audit_events a join public.invoices i on i.id=p_invoice and i.teacher_id=a.teacher_id
 where a.actor_id=auth.uid() and a.entity_type in ('session_billing_review_intent','session_billing_settlement')
  and a.metadata->>'transaction_id'=txid_current()::text and a.metadata->>'session_id'=i.session_id::text)
$$;
revoke all on function private.billing_financial_authorized(uuid) from public,anon,authenticated;

create function public.secretary_review_session_billing(p_session_id uuid,p_expected_version text,p_request_id uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');a public.audit_events;before_value jsonb;result jsonb;r jsonb;
 request jsonb:=jsonb_build_object('session',p_session_id,'version',p_expected_version);
begin
 if p_session_id is null or p_expected_version is null or p_request_id is null then raise exception 'VALIDATION_ERROR';end if;
 perform private.billing_lock();
 select * into a from public.audit_events where teacher_id=t and entity_type='session_billing_review' and entity_id=p_request_id;
 if found then if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;return a.metadata->'result';end if;
 perform 1 from public.sessions where id=p_session_id and teacher_id=t for update;
 before_value:=public.get_session_billing(p_session_id);
 if before_value->>'billing_mode'<>'per_session' then raise exception 'VALIDATION_ERROR';end if;
 if before_value->>'version'<>p_expected_version then raise exception 'CONFLICT';end if;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'session_billing_review_intent',p_request_id,'reviewing',jsonb_build_object('session_id',p_session_id,'transaction_id',txid_current()::text,'request',request,'before',before_value));
 for r in select value from jsonb_array_elements(before_value->'rows') loop
  if r->>'invoice_id' is not null and r->>'invoice_status'<>'void' then
   update public.invoices set amount_egp=(r->>'proposed_amount_egp')::numeric,
    attendance_target_egp=(r->>'target_egp')::numeric,attendance_settlement_required=(r->>'settlement_required')::boolean,
    attendance_reviewed_at=clock_timestamp(),status=case when (r->>'proposed_amount_egp')::numeric=(r->>'paid_egp')::numeric then 'paid' when (r->>'paid_egp')::numeric=0 then 'due' else 'partially_paid' end
   where teacher_id=t and id=(r->>'invoice_id')::uuid;
  end if;
 end loop;
 result:=public.get_session_billing(p_session_id);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(t,auth.uid(),'session_billing_review',p_request_id,'reviewed',jsonb_build_object('request',request,'result',result));
 return result;
end $$;
revoke all on function public.secretary_review_session_billing(uuid,text,uuid) from public,anon;
grant execute on function public.secretary_review_session_billing(uuid,text,uuid) to authenticated;

create function private.issued_session_billing_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if old.billing_origin='group_session' and (new.session_id,new.billing_origin,new.initial_amount_egp,new.teacher_id,new.student_id,new.group_id)
  is distinct from (old.session_id,old.billing_origin,old.initial_amount_egp,old.teacher_id,old.student_id,old.group_id) then raise exception 'CONFLICT';end if;
 return new;
end $$;
create trigger issued_session_billing_guard before update on public.invoices for each row execute function private.issued_session_billing_guard();
revoke all on function private.issued_session_billing_guard() from public,anon,authenticated;

create function public.get_teacher_session_billing(p_session_id uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare data jsonb;summary jsonb;
begin
 perform private.require_actor('teacher');data:=public.get_session_billing(p_session_id);
 select jsonb_build_object('charged_egp',coalesce(sum(coalesce(value->>'amount_egp','0')::numeric),0)::numeric(20,2)::text,
 'paid_egp',coalesce(sum((value->>'paid_egp')::numeric),0)::numeric(20,2)::text,
 'settlement_count',count(*) filter(where (value->>'attendance_settlement_required')::boolean)) into summary from jsonb_array_elements(data->'rows');
 return (data-'rows')||jsonb_build_object('summary',summary);
end $$;
revoke all on function public.get_teacher_session_billing(uuid) from public,anon;
grant execute on function public.get_teacher_session_billing(uuid) to authenticated;

CREATE OR REPLACE FUNCTION private.billing_legacy_record_payment(p_invoice_id uuid, p_amount numeric, p_method text, p_idempotency_key uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid:=private.require_actor('secretary'); i public.invoices; p public.payments; v_paid numeric; v_id uuid;
begin
  if p_amount is null or p_amount<=0 or p_amount<>round(p_amount,2) or p_method is null
    or p_method not in ('cash','transfer','other') or p_idempotency_key is null then raise exception 'VALIDATION_ERROR'; end if;
  -- Serialize tenant-key reuse, including concurrent reuse against different invoices.
  perform pg_advisory_xact_lock(hashtextextended(v_tenant::text||p_idempotency_key::text,0));
  select * into p from public.payments where teacher_id=v_tenant and idempotency_key=p_idempotency_key;
  if found then
    if p.invoice_id<>p_invoice_id or p.amount_egp<>p_amount or p.method<>p_method or p.reversal_of is not null
      then raise exception 'CONFLICT'; end if;
    return p.id;
  end if;
  select * into i from public.invoices where id=p_invoice_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if i.status='void' then raise exception 'CONFLICT'; end if;
  select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)
    into v_paid from public.payments where invoice_id=i.id;
  if v_paid+p_amount>i.amount_egp then raise exception 'CONFLICT'; end if;
  insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key)
    values(v_tenant,i.id,p_amount,auth.uid(),p_method,p_idempotency_key) returning id into v_id;
  perform private.reconcile_invoice(i.id);
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action) values(v_tenant,auth.uid(),'payment',v_id,'collected');
  return v_id;
end $function$;
revoke all on function private.billing_legacy_record_payment(uuid,numeric,text,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.record_payment(p_invoice_id uuid, p_amount numeric, p_method text, p_idempotency_key uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.require_actor('secretary'); perform private.billing_lock(); if exists(select 1 from public.invoices where id=p_invoice_id and teacher_id=private.require_actor() and attendance_settlement_required) and not exists(select 1 from public.payments where teacher_id=private.require_actor() and idempotency_key=p_idempotency_key) then raise exception 'BILLING_SETTLEMENT_REQUIRED';end if;return private.billing_legacy_record_payment(p_invoice_id,p_amount,p_method,p_idempotency_key);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_reverse_payment(p_payment_id uuid, p_reason text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid:=private.require_actor('secretary'); p public.payments; v_id uuid;
begin
  if nullif(trim(p_reason),'') is null then raise exception 'VALIDATION_ERROR'; end if;
  select * into p from public.payments where id=p_payment_id and teacher_id=v_tenant;
  if not found then raise exception 'NOT_FOUND'; end if;
  perform 1 from public.invoices where id=p.invoice_id for update;
  if p.reversal_of is not null then raise exception 'CONFLICT'; end if;
  select id into v_id from public.payments where reversal_of=p.id;
  if found then return v_id; end if;
  insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key,reversal_of,reason)
    values(v_tenant,p.invoice_id,p.amount_egp,auth.uid(),p.method,gen_random_uuid(),p.id,trim(p_reason)) returning id into v_id;
  perform private.reconcile_invoice(p.invoice_id);
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action) values(v_tenant,auth.uid(),'payment',v_id,'reversed');
  return v_id;
end $function$;
revoke all on function private.billing_legacy_reverse_payment(uuid,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.reverse_payment(p_payment_id uuid, p_reason text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_invoice uuid;v_session uuid;v_pending boolean;v_result uuid;begin perform private.require_actor('secretary');perform private.billing_lock();select i.id,i.session_id,i.attendance_settlement_required into v_invoice,v_session,v_pending from public.invoices i join public.payments p on p.invoice_id=i.id and p.teacher_id=i.teacher_id where p.id=p_payment_id and i.teacher_id=private.require_actor() for update of i;
      if v_pending then insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(private.require_actor(),auth.uid(),'session_billing_settlement',gen_random_uuid(),'editing',jsonb_build_object('session_id',v_session,'transaction_id',txid_current()::text));end if;
      v_result:=private.billing_legacy_reverse_payment(p_payment_id,p_reason);if v_pending then perform private.sync_attendance_settlement(v_invoice);end if;return v_result;end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_set_attendance(p_session_id uuid, p_student_id uuid, p_status text, p_reason text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid:=private.require_actor('secretary'); s public.sessions; a public.attendance; v_previous text;
begin
  if p_status is null or p_status not in ('not_marked','present','absent','excused') then raise exception 'VALIDATION_ERROR'; end if;
  select * into s from public.sessions where id=p_session_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if s.status='cancelled' then raise exception 'CONFLICT'; end if;
  select * into a from public.attendance where session_id=s.id and student_id=p_student_id;
  if not found then
    if not exists(select 1 from public.group_enrollments where teacher_id=v_tenant
      and group_id=s.group_id and student_id=p_student_id and status='active') then raise exception 'NOT_FOUND'; end if;
    insert into public.attendance(teacher_id,session_id,student_id) values(v_tenant,s.id,p_student_id) returning * into a;
  end if;
  if a.status=p_status then return a.id; end if;
  v_previous:=a.status;
  update public.attendance set status=p_status,marked_by=auth.uid(),marked_at=clock_timestamp(),updated_at=clock_timestamp() where id=a.id;
  insert into public.attendance_change_log(teacher_id,attendance_id,actor_id,previous_status,next_status,reason)
    values(v_tenant,a.id,auth.uid(),v_previous,p_status,nullif(trim(p_reason),''));
  return a.id;
end $function$;
revoke all on function private.billing_legacy_set_attendance(uuid,uuid,text,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.set_attendance(p_session_id uuid, p_student_id uuid, p_status text, p_reason text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_set_attendance(p_session_id,p_student_id,p_status,p_reason);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_edit_finance(p_kind text, p_id uuid, p_amount numeric, p_expected_amount numeric, p_change_id uuid, p_due_on date DEFAULT NULL::date, p_method text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');i public.invoices;p public.payments;a public.audit_events;
 request jsonb:=jsonb_build_object('kind',p_kind,'id',p_id,'amount',p_amount,'expected',p_expected_amount,'due',p_due_on,'method',p_method);
 paid numeric;balance numeric;total numeric;replacement uuid;result jsonb;before_value jsonb;
begin
 if p_kind is null or p_kind not in('due','payment') or p_id is null or p_change_id is null
  or p_amount is null or p_amount<0 or p_amount>9999999999.99 or p_amount<>round(p_amount,2)
  or p_expected_amount is null or p_expected_amount<0 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_change_id::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='finance_edit' and entity_id=p_change_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return a.metadata->'result';
 end if;
 if p_kind='payment' then
  select * into p from public.payments where id=p_id and teacher_id=t;
  if not found then raise exception 'NOT_FOUND';end if;
  select * into i from public.invoices where id=p.invoice_id and teacher_id=t for update;
 else
  select * into i from public.invoices where id=p_id and teacher_id=t for update;
 end if;
 if i.id is null then raise exception 'NOT_FOUND';end if;
 if i.status='void' or (p_kind='due' and not exists(select 1 from public.students where id=i.student_id and teacher_id=t and archived_at is null))
 then raise exception 'CONFLICT';end if;
 select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0) into paid from public.payments where teacher_id=t and invoice_id=i.id;
 if p_kind='due' then
  balance:=i.amount_egp-paid;total:=paid+p_amount;
  if p_due_on is null or balance<>p_expected_amount or total>9999999999.99 then raise exception 'CONFLICT';end if;
  before_value:=jsonb_build_object('amount',i.amount_egp,'balance',balance,'due',i.due_on);
  update public.invoices set amount_egp=total,due_on=p_due_on,
   initial_amount_egp=case when total<>i.amount_egp then coalesce(i.initial_amount_egp,i.amount_egp) else i.initial_amount_egp end,
   status=case when total=paid then 'paid' when paid=0 then 'due' else 'partially_paid' end where id=i.id;
 else
  if p.reversal_of is not null or p.amount_egp<>p_expected_amount or exists(select 1 from public.payments where reversal_of=p.id)
   or p_method is null or p_method not in('cash','transfer','other') then raise exception 'CONFLICT';end if;
  before_value:=jsonb_build_object('payment',p.id,'amount',p.amount_egp,'method',p.method);
  perform public.reverse_payment(p.id,'تعديل المدفوع');
  if p_amount>0 then replacement:=public.record_payment(i.id,p_amount,p_method,p_change_id);end if;
 end if;
 result:=jsonb_build_object('invoice_id',i.id,'payment_id',replacement);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'finance_edit',p_change_id,'edited',jsonb_build_object('request',request,'before',before_value,'result',result));
 return result;
end $function$;
revoke all on function private.billing_legacy_secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_edit_finance(p_kind text, p_id uuid, p_amount numeric, p_expected_amount numeric, p_change_id uuid, p_due_on date DEFAULT NULL::date, p_method text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_pending boolean;v_invoice uuid;v_result jsonb;v_session uuid;begin perform private.billing_lock();if exists(select 1 from public.audit_events where teacher_id=private.require_actor('secretary') and entity_type='finance_edit' and entity_id=p_change_id) then return private.billing_legacy_secretary_edit_finance(p_kind,p_id,p_amount,p_expected_amount,p_change_id,p_due_on,p_method);end if;select id,session_id,attendance_settlement_required into v_invoice,v_session,v_pending from public.invoices where teacher_id=private.require_actor('secretary') and id=case when p_kind='payment' then(select invoice_id from public.payments where id=p_id and teacher_id=private.require_actor())else p_id end for update;
   if v_pending then if p_kind<>'payment' then raise exception 'BILLING_SETTLEMENT_REQUIRED';end if;
   insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(private.require_actor(),auth.uid(),'session_billing_settlement',gen_random_uuid(),'editing',jsonb_build_object('session_id',v_session,'transaction_id',txid_current()::text));
   update public.invoices set attendance_settlement_required=false where id=v_invoice;end if;
   v_result:=private.billing_legacy_secretary_edit_finance(p_kind,p_id,p_amount,p_expected_amount,p_change_id,p_due_on,p_method);if v_pending then perform private.sync_attendance_settlement(v_invoice);end if;return v_result;end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_set_attendance(p_session_id uuid, p_student_id uuid, p_status text, p_expected_updated_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_reason text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary'); a public.attendance;
begin
 perform 1 from public.sessions where id=p_session_id and teacher_id=t for update;
 if not found then raise exception 'NOT_FOUND'; end if;
 select * into a from public.attendance where session_id=p_session_id and student_id=p_student_id and teacher_id=t;
 if a.updated_at is distinct from p_expected_updated_at then raise exception 'CONFLICT'; end if;
 return public.set_attendance(p_session_id,p_student_id,p_status,p_reason);
end $function$;
revoke all on function private.billing_legacy_secretary_set_attendance(uuid,uuid,text,timestamp with time zone,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_set_attendance(p_session_id uuid, p_student_id uuid, p_status text, p_expected_updated_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_reason text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_set_attendance(p_session_id,p_student_id,p_status,p_expected_updated_at,p_reason);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_cancel_session(p_session_id uuid, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid:=private.require_actor(); s public.sessions;
begin
  if nullif(trim(p_reason),'') is null then raise exception 'VALIDATION_ERROR'; end if;
  select * into s from public.sessions where id=p_session_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  if s.status='cancelled' then raise exception 'ALREADY_CANCELLED'; end if;
  if s.ends_at<=now() then raise exception 'CONFLICT'; end if;
  update public.sessions set status='cancelled',cancel_reason=trim(p_reason),cancelled_by=auth.uid(),cancelled_at=clock_timestamp() where id=s.id;
  insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
    values(v_tenant,auth.uid(),'session',s.id,'cancelled',jsonb_build_object('reason',trim(p_reason)));
  insert into public.notifications(teacher_id,recipient_id,type,payload)
    select v_tenant,id,'session_cancelled',jsonb_build_object('session_id',s.id)
    from (select id from public.secretaries where teacher_id=v_tenant and status='active'
      union select v_tenant) recipients where id<>auth.uid();
end $function$;
revoke all on function private.billing_legacy_cancel_session(uuid,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.cancel_session(p_session_id uuid, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); perform private.billing_legacy_cancel_session(p_session_id,p_reason);return;end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_enroll(p_group_id uuid, p_student_id uuid, p_enrollment_id uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary'); v uuid;
begin
 if p_enrollment_id is null then
 insert into public.group_enrollments(teacher_id,group_id,student_id) values(t,p_group_id,p_student_id) returning id into v;
 insert into public.attendance(teacher_id,session_id,student_id)
 select t,id,p_student_id from public.sessions where teacher_id=t and group_id=p_group_id and status<>'cancelled' and ends_at>=statement_timestamp()
 on conflict(session_id,student_id) do nothing;
 else
 if not exists(select 1 from public.group_enrollments where id=p_enrollment_id and teacher_id=t and student_id=p_student_id and group_id=p_group_id and status='active') then raise exception 'CONFLICT';end if;
 if exists(select 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null) and exists(select 1 from public.students where id=p_student_id and teacher_id=t and archived_at is null) then
 perform private.bill_group_month(p_group_id,p_student_id,false);end if;
 update public.group_enrollments set status='inactive',left_at=clock_timestamp() where teacher_id=t and id=p_enrollment_id and group_id=p_group_id and student_id=p_student_id and status='active' returning id into v;
 if v is null then raise exception 'CONFLICT'; end if;
 end if;
 return v;
end $function$;
revoke all on function private.billing_legacy_secretary_enroll(uuid,uuid,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_enroll(p_group_id uuid, p_student_id uuid, p_enrollment_id uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_enroll(p_group_id,p_student_id,p_enrollment_id);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_create_session(p_id uuid, p_group_id uuid, p_date date, p_start time without time zone, p_end time without time zone, p_amount numeric DEFAULT 0)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');a public.audit_events;begins timestamptz;ends timestamptz;
 request jsonb:=jsonb_build_object('group',p_group_id,'date',p_date,'start',p_start,'end',p_end,'amount',p_amount);
begin
 if p_id is null or p_group_id is null or p_date is null or p_start is null or p_end is null or p_start=p_end
  or p_amount is null or p_amount<0 or p_amount>9999999999.99 or p_amount<>round(p_amount,2)
 then raise exception 'VALIDATION_ERROR';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_id::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='manual_session' and entity_id=p_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_id;
 end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 begins:=(p_date+p_start) at time zone 'Africa/Cairo';
 ends:=(p_date+case when p_end<p_start then 1 else 0 end+p_end) at time zone 'Africa/Cairo';
 if ends<=begins or (begins at time zone 'Africa/Cairo')::time<>p_start or (ends at time zone 'Africa/Cairo')::time<>p_end
 then raise exception 'VALIDATION_ERROR';end if;
 if exists(select 1 from public.sessions where teacher_id=t and group_id=p_group_id and status<>'cancelled'
  and starts_at<ends and ends_at>begins) then raise exception 'CONFLICT';end if;
 insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at,fee_egp)
 values(p_id,t,p_group_id,p_date,begins,ends,p_amount);
 perform private.sync_manual_session(p_id);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'manual_session',p_id,'created',jsonb_build_object('request',request));
 return p_id;
end $function$;
revoke all on function private.billing_legacy_secretary_create_session(uuid,uuid,date,time without time zone,time without time zone,numeric) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_create_session(p_id uuid, p_group_id uuid, p_date date, p_start time without time zone, p_end time without time zone, p_amount numeric DEFAULT 0)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_create_session(p_id,p_group_id,p_date,p_start,p_end,p_amount);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_generate_sessions(p_from date, p_to date)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');g record;r record;begins timestamptz;ends timestamptz;n integer:=0;
begin
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR';end if;
 -- Same group lock as dated manual creation: no duplicate/conflicting races.
 for g in select id from public.groups where teacher_id=t and archived_at is null order by id for update loop
  for r in select s.*,d::date as date from public.group_schedules s
    cross join generate_series(p_from::timestamp,p_to::timestamp,interval '1 day') d
    where s.teacher_id=t and s.group_id=g.id and s.retired_at is null and extract(dow from d)=s.weekday
     and d::date>=s.effective_from and (s.effective_to is null or d::date<=s.effective_to) order by d,s.id loop
   begins:=(r.date+r.local_start_time) at time zone 'Africa/Cairo';
   ends:=(r.date+case when r.local_end_time<r.local_start_time then 1 else 0 end+r.local_end_time) at time zone 'Africa/Cairo';
   if ends<=begins or (begins at time zone 'Africa/Cairo')::time<>r.local_start_time
    or (ends at time zone 'Africa/Cairo')::time<>r.local_end_time then raise exception 'VALIDATION_ERROR';end if;
   -- Existing exact dated sessions, including cancelled ones, are never recreated.
   if exists(select 1 from public.sessions where teacher_id=t and group_id=g.id and starts_at=begins and ends_at=ends) then continue;end if;
   if exists(select 1 from public.sessions where teacher_id=t and group_id=g.id and status<>'cancelled' and starts_at<ends and ends_at>begins)
    then raise exception 'CONFLICT';end if;
   insert into public.sessions(teacher_id,group_id,schedule_id,local_date,starts_at,ends_at)
    values(t,g.id,r.id,r.date,begins,ends) on conflict(schedule_id,local_date) do nothing;
   if found then n:=n+1;end if;
  end loop;
 end loop;
 insert into public.attendance(teacher_id,session_id,student_id)
  select t,s.id,e.student_id from public.sessions s
  join public.group_enrollments e on e.group_id=s.group_id and e.teacher_id=s.teacher_id
  join public.students st on st.id=e.student_id and st.teacher_id=e.teacher_id and st.archived_at is null
  where s.teacher_id=t and s.local_date between p_from and p_to and s.status<>'cancelled'
   and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
  on conflict(session_id,student_id) do nothing;
 return n;
end $function$;
revoke all on function private.billing_legacy_generate_sessions(date,date) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.generate_sessions(p_from date, p_to date)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_generate_sessions(p_from,p_to);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_archive(p_entity text, p_id uuid)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');stamp timestamptz;e record;
begin
 if p_entity not in ('students','groups') then raise exception 'VALIDATION_ERROR';end if;
 for e in select en.group_id,en.student_id from public.group_enrollments en
  join public.groups g on g.id=en.group_id join public.students st on st.id=en.student_id
  where en.teacher_id=t and en.status='active' and g.archived_at is null and st.archived_at is null
  and ((p_entity='students' and en.student_id=p_id) or (p_entity='groups' and en.group_id=p_id))
  order by en.group_id,en.student_id loop
  perform private.bill_group_month(e.group_id,e.student_id,false);
 end loop;
 execute format('update public.%I set archived_at=coalesce(archived_at,clock_timestamp()) where id=$1 and teacher_id=$2 returning archived_at',p_entity) into stamp using p_id,t;
 if stamp is null then raise exception 'NOT_FOUND';end if;
 return stamp;
end $function$;
revoke all on function private.billing_legacy_secretary_archive(text,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_archive(p_entity text, p_id uuid)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_archive(p_entity,p_id);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_restore(p_entity text, p_id uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end $function$;
revoke all on function private.billing_legacy_secretary_restore(text,uuid,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_restore(p_entity text, p_id uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_restore(p_entity,p_id,p_request);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_set_group_timetable(p_group_id uuid, p_weekdays integer[], p_start time without time zone, p_end time without time zone, p_request_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');d integer;a public.audit_events;days integer[];request jsonb;
begin
 if p_group_id is null or p_request_id is null or p_weekdays is null or cardinality(p_weekdays) not between 1 and 7
  or array_ndims(p_weekdays)<>1 or exists(select 1 from unnest(p_weekdays) x where x is null or x not between 0 and 6)
  or p_start is null or p_end is null or p_start=p_end then raise exception 'VALIDATION_ERROR';end if;
 select array_agg(distinct x order by x) into days from unnest(p_weekdays) x;
 if cardinality(days)<>cardinality(p_weekdays) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('group',p_group_id,'days',days,'start',p_start,'end',p_end);
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 select * into a from public.audit_events where teacher_id=t and entity_type='group_timetable' and entity_id=p_request_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_group_id;
 end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 update public.group_schedules set retired_at=clock_timestamp() where teacher_id=t and group_id=p_group_id
  and retired_at is null and (effective_to is null or effective_to>=(now() at time zone 'Africa/Cairo')::date);
 foreach d in array days loop
  perform public.add_schedule(p_group_id,d,p_start,p_end,(now() at time zone 'Africa/Cairo')::date);
 end loop;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'group_timetable',p_request_id,'edited',jsonb_build_object('request',request));
 return p_group_id;
end $function$;
revoke all on function private.billing_legacy_secretary_set_group_timetable(uuid,integer[],time without time zone,time without time zone,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_set_group_timetable(p_group_id uuid, p_weekdays integer[], p_start time without time zone, p_end time without time zone, p_request_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_set_group_timetable(p_group_id,p_weekdays,p_start,p_end,p_request_id);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_transfer(p_enrollment_id uuid, p_group_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');e public.group_enrollments;v uuid;
begin
 select * into e from public.group_enrollments where id=p_enrollment_id and teacher_id=t;
 if not found or e.status<>'active' or e.group_id=p_group_id then raise exception 'CONFLICT';end if;
 perform id from public.groups where teacher_id=t and id in(e.group_id,p_group_id) order by id for update;
 select * into e from public.group_enrollments where id=p_enrollment_id and teacher_id=t for update;
 if e.status<>'active' then raise exception 'CONFLICT';end if;
 v:=public.secretary_enroll(p_group_id,e.student_id);
 perform public.secretary_enroll(e.group_id,e.student_id,e.id);
 return v;
end $function$;
revoke all on function private.billing_legacy_secretary_transfer(uuid,uuid) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_transfer(p_enrollment_id uuid, p_group_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_transfer(p_enrollment_id,p_group_id);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_create_student(p_id uuid, p_group_id uuid, p_name text, p_phone text DEFAULT NULL::text, p_guardian_phone text DEFAULT NULL::text, p_level text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');s public.students;
begin
 if p_id is null or p_group_id is null or nullif(trim(p_name),'') is null or length(p_name)>200
  or length(p_phone)>200 or length(p_guardian_phone)>200 or length(p_level)>200 then raise exception 'VALIDATION_ERROR';end if;
 perform 1 from public.groups where id=p_group_id and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_id::text,0));
 select * into s from public.students where id=p_id and teacher_id=t;
 if found then
  if (s.full_name,s.phone,s.guardian_phone,s.level_tag) is distinct from
   (trim(p_name),nullif(trim(p_phone),''),nullif(trim(p_guardian_phone),''),nullif(trim(p_level),''))
   or s.archived_at is not null or not exists(select 1 from public.group_enrollments
    where teacher_id=t and student_id=p_id and group_id=p_group_id and status='active') then raise exception 'CONFLICT';end if;
  return s.id;
 end if;
 insert into public.students(id,teacher_id,full_name,phone,guardian_phone,level_tag)
 values(p_id,t,trim(p_name),nullif(trim(p_phone),''),nullif(trim(p_guardian_phone),''),nullif(trim(p_level),''));
 perform public.secretary_enroll(p_group_id,p_id);
 return p_id;
end $function$;
revoke all on function private.billing_legacy_secretary_create_student(uuid,uuid,text,text,text,text) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_create_student(p_id uuid, p_group_id uuid, p_name text, p_phone text DEFAULT NULL::text, p_guardian_phone text DEFAULT NULL::text, p_level text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_create_student(p_id,p_group_id,p_name,p_phone,p_guardian_phone,p_level);end
$function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_secretary_create_weekly_group(p_id uuid, p_name text, p_subject text, p_monthly numeric, p_materials numeric, p_weekdays integer[], p_start time without time zone, p_end time without time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('secretary');days integer[];d integer;a public.audit_events;request jsonb;
begin
 if p_weekdays is null or cardinality(p_weekdays) not between 1 and 7
  or array_ndims(p_weekdays)<>1 or exists(select 1 from unnest(p_weekdays) x where x is null or x not between 0 and 6)
 then raise exception 'VALIDATION_ERROR';end if;
 select array_agg(distinct x order by x) into days from unnest(p_weekdays) x;
 if cardinality(days)<>cardinality(p_weekdays) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('name',trim(p_name),'subject',trim(p_subject),'monthly',p_monthly,
  'materials',p_materials,'days',days,'start',p_start,'end',p_end);
 perform pg_advisory_xact_lock(hashtextextended(t::text||'simple_group_creation',0));
 select * into a from public.audit_events where teacher_id=t and entity_type='weekly_group_creation' and entity_id=p_id;
 if found then
  if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;
  return p_id;
 end if;
 perform public.secretary_create_scheduled_group(p_id,p_name,p_subject,p_monthly,p_materials,
  days[1],p_start,p_end,(now() at time zone 'Africa/Cairo')::date);
 foreach d in array days loop
  if d<>days[1] then perform public.add_schedule(p_id,d,p_start,p_end,(now() at time zone 'Africa/Cairo')::date);end if;
 end loop;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'weekly_group_creation',p_id,'created',jsonb_build_object('request',request));
 return p_id;
end $function$;
revoke all on function private.billing_legacy_secretary_create_weekly_group(uuid,text,text,numeric,numeric,integer[],time without time zone,time without time zone) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.secretary_create_weekly_group(p_id uuid, p_name text, p_subject text, p_monthly numeric, p_materials numeric, p_weekdays integer[], p_start time without time zone, p_end time without time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin perform private.billing_lock(); return private.billing_legacy_secretary_create_weekly_group(p_id,p_name,p_subject,p_monthly,p_materials,p_weekdays,p_start,p_end);end
$function$;
CREATE OR REPLACE FUNCTION public.list_teacher_groups(p_search text DEFAULT NULL::text, p_grade_level_id uuid DEFAULT NULL::uuid, p_cursor uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 30)
 RETURNS SETOF jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid:=private.require_actor('teacher');
begin
  if p_limit is null or p_limit not between 1 and 100 or length(coalesce(p_search,''))>200
    then raise exception 'VALIDATION_ERROR'; end if;
  return query select jsonb_build_object(
    'billing_mode',g.billing_mode,'session_fee_egp',g.session_fee_egp::text,'monthly_fee_egp',g.monthly_fee_egp::text,'id',g.id,'name',g.name,'subject_name',g.subject_name,'capacity',g.capacity,
    'grade_level_id',g.grade_level_id,'grade_name',l.name,
    'students_count',(select count(*) from public.group_enrollments e
      join public.students s on s.id=e.student_id and s.teacher_id=e.teacher_id
      where e.teacher_id=v_tenant and e.group_id=g.id and e.status='active' and s.archived_at is null),
    'roster_preview',(select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]'::jsonb)
      from (select s.id,s.full_name from public.group_enrollments e
        join public.students s on s.id=e.student_id and s.teacher_id=e.teacher_id
        where e.teacher_id=v_tenant and e.group_id=g.id and e.status='active' and s.archived_at is null
        order by s.id limit 5) r),
    'schedules_truncated',(select count(*)>32 from public.group_schedules q where q.teacher_id=v_tenant and q.group_id=g.id and q.retired_at is null),
    'schedules',(select coalesce(jsonb_agg(to_jsonb(r) order by r.weekday,r.local_start_time,r.id),'[]'::jsonb)
      from (select q.id,q.weekday,q.local_start_time,q.local_end_time,q.effective_from,q.effective_to
        from public.group_schedules q where q.teacher_id=v_tenant and q.group_id=g.id and q.retired_at is null
        order by q.weekday,q.local_start_time,q.id limit 32) r))
  from public.groups g join public.grade_levels l on l.id=g.grade_level_id and l.teacher_id=g.teacher_id
  where g.teacher_id=v_tenant and g.archived_at is null and (p_cursor is null or g.id>p_cursor)
    and (p_grade_level_id is null or g.grade_level_id=p_grade_level_id)
    and (nullif(trim(p_search),'') is null or g.name ilike '%'||trim(p_search)||'%'
      or g.subject_name ilike '%'||trim(p_search)||'%')
  order by g.id limit p_limit;
end $function$;
CREATE OR REPLACE FUNCTION private.billing_legacy_get_teacher_invoice_detail(p_id uuid, p_cursor uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('teacher'); header jsonb; result jsonb;
begin
 if p_id is null or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
 select jsonb_build_object('id',i.id,'invoice_number',i.invoice_number,'amount_egp',i.amount_egp::text,
  'student_id',i.student_id,'student_name',s.full_name,'group_id',i.group_id,'group_name',g.name,
  'due_on',i.due_on,'status',i.status,'void_reason',i.void_reason,
  'created_by',i.created_by,'created_by_name',a.name,'created_by_status',a.status,'created_at',i.created_at,
  'net_paid_egp',coalesce(p.paid,0)::numeric(20,2)::text,
  'outstanding_egp',(case when i.status='void' then 0 else i.amount_egp-coalesce(p.paid,0) end)::numeric(20,2)::text)
 into header from public.invoices i
 join public.students s on s.id=i.student_id and s.teacher_id=t
 left join public.groups g on g.id=i.group_id and g.teacher_id=t
 left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
 left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
  from public.payments where teacher_id=t and invoice_id=i.id) p on true
 where i.id=p_id and i.teacher_id=t;
 if not found then raise exception 'NOT_FOUND'; end if;
 header:=header||jsonb_build_object('original_amount_egp',(select coalesce(initial_amount_egp,amount_egp)::text from public.invoices where id=p_id and teacher_id=t),'ledger_net_egp',header->'net_paid_egp','payable_balance_egp',header->'outstanding_egp');
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
  select p.id,p.invoice_id,p.receipt_number,p.amount_egp::text,
   (case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text signed_amount_egp,
   p.collected_by,a.name collected_by_name,a.status collected_by_status,p.collected_at,p.method,p.reason,p.reversal_of,
   o.receipt_number original_receipt_number,o.collected_by original_collected_by,
   oa.name original_collected_by_name,o.amount_egp::text original_amount_egp,
   rev.id reversed_by,rev.receipt_number correction_receipt_number
  from public.payments p
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  left join public.payments o on o.id=p.reversal_of and o.teacher_id=t and o.invoice_id=p_id
  left join public.secretaries oa on oa.id=o.collected_by and oa.teacher_id=t
  left join public.payments rev on rev.reversal_of=p.id and rev.teacher_id=t and rev.invoice_id=p_id
  where p.teacher_id=t and p.invoice_id=p_id and (p_cursor is null or p.id>p_cursor)
  order by p.id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('invoice',header,
  'total_count',(select count(*) from public.payments where teacher_id=t and invoice_id=p_id));
end $function$;
revoke all on function private.billing_legacy_get_teacher_invoice_detail(uuid,uuid,integer) from public,anon,authenticated;
CREATE OR REPLACE FUNCTION public.get_teacher_invoice_detail(p_id uuid, p_cursor uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$ declare v_result jsonb;v_invoice public.invoices;begin v_result:=private.billing_legacy_get_teacher_invoice_detail(p_id,p_cursor,p_limit);select * into v_invoice from public.invoices where id=p_id and teacher_id=private.require_actor('teacher');return jsonb_set(v_result,'{invoice}',(v_result->'invoice')||jsonb_build_object('billing_origin',v_invoice.billing_origin,'session_id',v_invoice.session_id,'attendance_settlement_required',v_invoice.attendance_settlement_required));end $function$;
CREATE OR REPLACE FUNCTION private.archived_student_write_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
 if stamp is not null and not((tg_table_name='payments' and issued<=stamp) or (tg_table_name='invoices' and private.billing_financial_authorized(new.id))) then raise exception 'CONFLICT';end if;
 if tg_op='UPDATE' then
  if new.teacher_id<>old.teacher_id then raise exception 'CONFLICT';end if;
  if tg_table_name<>'payments' then
   if new.student_id<>old.student_id then raise exception 'CONFLICT';end if;
  end if;
 end if;
 return new;
end $function$;
