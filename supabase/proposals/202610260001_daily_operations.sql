-- OPS37: additive reviewed operational completion; NOT DEPLOYED.
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

create or replace function public.generate_sessions(p_from date,p_to date) returns integer
language plpgsql security definer set search_path='' as $$
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
end $$;

CREATE OR REPLACE FUNCTION public.secretary_edit_finance(p_kind text, p_id uuid, p_amount numeric, p_expected_amount numeric, p_change_id uuid, p_due_on date DEFAULT NULL::date, p_method text DEFAULT NULL::text)
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

create function private.normalized_student_name(value text) returns text
language sql immutable set search_path='' as $$
 select lower(trim(regexp_replace(translate(normalize(coalesce(value,''),NFKC),'أإآى','اااي'),'[ً-ٟـ]','','g')))
$$;
revoke all on function private.normalized_student_name(text) from public,anon,authenticated;

create function public.secretary_finance_page(p_entity text,p_filters jsonb default '{}',p_search text default '',p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');result jsonb;stats jsonb;n bigint;k text;allowed text[];needle text;
begin
 if p_entity is null or p_entity not in('invoices','payments') or p_filters is null or jsonb_typeof(p_filters)<>'object'
  or p_search is null or length(p_search)>100 or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR';end if;
 allowed:=case when p_entity='invoices' then array['id','student_id','group_id','status','from','to']
  else array['id','student_id','group_id','invoice_id','idempotency_key','method','from','to'] end;
 for k in select jsonb_object_keys(p_filters) loop if not k=any(allowed) then raise exception 'VALIDATION_ERROR';end if;end loop;
 if (p_filters ? 'from')<>(p_filters ? 'to') or (p_filters ? 'from' and ((p_filters->>'to')::date<(p_filters->>'from')::date or (p_filters->>'to')::date-(p_filters->>'from')::date>366)) then raise exception 'VALIDATION_ERROR';end if;
 needle:=private.normalized_student_name(p_search);
 if p_entity='invoices' then
  with filtered as materialized (
   select i.*,s.full_name student_name,g.name group_name,a.name creator_name,
    coalesce(p.paid,0)::numeric(20,2)::text paid_egp,
    (case when i.status='void' then 0 else i.amount_egp-coalesce(p.paid,0) end)::numeric(20,2)::text balance_egp
   from public.invoices i join public.students s on s.id=i.student_id and s.teacher_id=t
   left join public.groups g on g.id=i.group_id and g.teacher_id=t
   left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
   left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where teacher_id=t and invoice_id=i.id)p on true
   where i.teacher_id=t and to_jsonb(i) @> (p_filters-'from'-'to')
    and (needle='' or strpos(private.normalized_student_name(s.full_name),needle)>0)
    and (not(p_filters ? 'from') or i.due_on between (p_filters->>'from')::date and (p_filters->>'to')::date)
  ), page as (
   select to_jsonb(f)||jsonb_build_object('amount_egp',f.amount_egp::text,'original_amount_egp',coalesce(f.initial_amount_egp,f.amount_egp)::text,
    'ledger_net_egp',f.paid_egp,'payable_balance_egp',f.balance_egp) v,f.id
   from filtered f where p_cursor is null or f.id>p_cursor order by f.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(v order by id),'[]') from page),count(*),
    jsonb_build_object('amount_egp',coalesce(sum(amount_egp) filter(where status<>'void'),0)::numeric(20,2)::text,
     'paid_egp',coalesce(sum(paid_egp::numeric) filter(where status<>'void'),0)::numeric(20,2)::text,
     'balance_egp',coalesce(sum(balance_egp::numeric),0)::numeric(20,2)::text)
   into result,n,stats from filtered;
 else
  with filtered as materialized (
   select p.*,i.student_id,s.full_name student_name,i.group_id,g.name group_name,a.name collector_name
   from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
   join public.students s on s.id=i.student_id and s.teacher_id=t
   left join public.groups g on g.id=i.group_id and g.teacher_id=t
   left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
   where p.teacher_id=t and p.reversal_of is null and not exists(select 1 from public.payments rev where rev.teacher_id=t and rev.reversal_of=p.id)
    and (to_jsonb(p)||jsonb_build_object('student_id',i.student_id,'group_id',i.group_id)) @> (p_filters-'from'-'to')
    and (needle='' or strpos(private.normalized_student_name(s.full_name),needle)>0)
    and (not(p_filters ? 'from') or ((p.collected_at at time zone 'Africa/Cairo')::date between (p_filters->>'from')::date and (p_filters->>'to')::date))
  ), page as (
   select to_jsonb(f)||jsonb_build_object('amount_egp',f.amount_egp::text) v,f.id from filtered f
    where p_cursor is null or f.id>p_cursor order by f.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(v order by id),'[]') from page),count(*),
   jsonb_build_object('amount_egp',coalesce(sum(amount_egp),0)::numeric(20,2)::text) into result,n,stats from filtered;
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('total_count',n,'summary',stats,
  'synced_at',statement_timestamp(),'server_date',(statement_timestamp() at time zone 'Africa/Cairo')::date);
end $$;
revoke all on function public.secretary_finance_page(text,jsonb,text,uuid,integer) from public,anon;
grant execute on function public.secretary_finance_page(text,jsonb,text,uuid,integer) to authenticated;

CREATE OR REPLACE FUNCTION public.list_teacher_current_payments(p_from date, p_to date, p_search text DEFAULT ''::text, p_method text DEFAULT NULL::text, p_kind text DEFAULT NULL::text, p_secretary_id uuid DEFAULT NULL::uuid, p_student_id uuid DEFAULT NULL::uuid, p_group_id uuid DEFAULT NULL::uuid, p_cursor uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint;
begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_search is null or length(p_search)>100
  or (p_method is not null and p_method not in ('cash','transfer','other'))
  or (p_kind is not null and p_kind not in ('collections','corrections'))
 then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null then perform private.require_teacher_student(p_student_id); end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_secretary_id is not null and not exists(select 1 from public.secretaries where id=p_secretary_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with filtered as materialized (
  select p.id,p.invoice_id,i.invoice_number,i.student_id,s.full_name student_name,
   p.amount_egp,(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end) signed_amount_egp,
   p.receipt_number,p.collected_at,p.method,p.reversal_of,p.reason,p.collected_by,a.name collected_by_name,
   o.receipt_number original_receipt_number,oa.name original_collected_by_name,
   rev.receipt_number correction_receipt_number
  from public.payments p
  join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
  join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  left join public.payments o on o.id=p.reversal_of and o.teacher_id=t and o.invoice_id=i.id
  left join public.secretaries oa on oa.id=o.collected_by and oa.teacher_id=t
  left join public.payments rev on rev.reversal_of=p.id and rev.teacher_id=t and rev.invoice_id=i.id
  where p.teacher_id=t and p.reversal_of is null and rev.id is null
   and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_secretary_id is null or p.collected_by=p_secretary_id)
   and (p_student_id is null or i.student_id=p_student_id)
   and (p_group_id is null or i.group_id=p_group_id)
   and (p_method is null or p.method=p_method)
   and (p_kind is null or (p_kind='corrections')=(p.reversal_of is not null))
   and (p_search='' or strpos(lower(s.full_name),lower(p_search))>0
    or strpos(lower(i.invoice_number),lower(p_search))>0 or strpos(lower(p.receipt_number::text),lower(p_search))>0)
 ), page as (
  select id,invoice_id,invoice_number,student_id,student_name,
   amount_egp::numeric(20,2)::text amount_egp,signed_amount_egp::numeric(20,2)::text signed_amount_egp,
   receipt_number,collected_at,method,reversal_of,reason,collected_by,collected_by_name,
   original_receipt_number,original_collected_by_name,correction_receipt_number
  from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1
 ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),
  jsonb_build_object('net_egp',coalesce(sum(signed_amount_egp),0)::numeric(20,2)::text,
   'gross_egp',coalesce(sum(amount_egp) filter(where reversal_of is null),0)::numeric(20,2)::text,
   'corrections_egp',coalesce(sum(amount_egp) filter(where reversal_of is not null),0)::numeric(20,2)::text),count(*)
 into result,stats,n from filtered;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $function$;

revoke all on function public.list_teacher_current_payments(date,date,text,text,text,uuid,uuid,uuid,uuid,integer) from public,anon;
grant execute on function public.list_teacher_current_payments(date,date,text,text,text,uuid,uuid,uuid,uuid,integer) to authenticated;


create function public.get_teacher_current_invoice(p_id uuid,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher');header jsonb;result jsonb;n bigint;
begin
 if p_id is null or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR';end if;
 header:=public.get_teacher_invoice_detail(p_id,null,1)->'invoice';
 with filtered as materialized (
  select p.id,p.invoice_id,p.receipt_number,p.amount_egp::text amount_egp,p.amount_egp::text signed_amount_egp,
   p.method,p.collected_at,p.collected_by,a.name collected_by_name,s.full_name student_name
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
  join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  where p.teacher_id=t and p.invoice_id=p_id and p.reversal_of is null
   and not exists(select 1 from public.payments rev where rev.teacher_id=t and rev.reversal_of=p.id)
 ), page as(select * from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1)
 select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),count(*) into result,n from filtered;
 return private.teacher_page(result,p_limit)||jsonb_build_object('invoice',header,'total_count',n);
end $$;
revoke all on function public.get_teacher_current_invoice(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_current_invoice(uuid,uuid,integer) to authenticated;
