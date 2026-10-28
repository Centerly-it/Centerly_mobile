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
