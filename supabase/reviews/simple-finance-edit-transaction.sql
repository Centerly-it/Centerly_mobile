begin;
-- Local review only: preserve issued value while allowing explicit balance edits.
alter table public.invoices add column initial_amount_egp numeric(12,2);
alter table public.invoices drop constraint invoices_amount_egp_check;
alter table public.invoices add constraint invoices_amount_egp_check check(amount_egp>=0 and amount_egp<=9999999999.99);
alter table public.invoices add constraint invoice_initial_amount_check check(initial_amount_egp>=0 and initial_amount_egp<=9999999999.99);
alter table public.invoices drop constraint group_bill_components;
alter table public.invoices add constraint group_bill_components check(billing_period_start is null or
 (group_id is not null and monthly_fee_egp is not null and materials_fee_egp is not null and monthly_fee_egp>=0 and materials_fee_egp>=0
 and coalesce(initial_amount_egp,amount_egp)=monthly_fee_egp+materials_fee_egp));
create or replace function private.group_bill_snapshot_guard() returns trigger language plpgsql set search_path='' as $$
begin
 if (new.billing_period_start,new.monthly_fee_egp,new.materials_fee_egp,new.student_id,new.group_id,new.teacher_id)
 is distinct from (old.billing_period_start,old.monthly_fee_egp,old.materials_fee_egp,old.student_id,old.group_id,old.teacher_id)
 then raise exception 'CONFLICT';end if;
 if new.initial_amount_egp is distinct from old.initial_amount_egp and not
  (old.initial_amount_egp is null and new.initial_amount_egp=old.amount_egp and new.amount_egp<>old.amount_egp)
 then raise exception 'CONFLICT';end if;
 if new.amount_egp<>old.amount_egp and new.initial_amount_egp is null then raise exception 'CONFLICT';end if;
 return new;
end $$;

create function public.secretary_edit_finance(p_kind text,p_id uuid,p_amount numeric,p_expected_amount numeric,
 p_change_id uuid,p_due_on date default null,p_method text default null) returns jsonb
language plpgsql security definer set search_path='' as $$
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
 if i.status='void' or not exists(select 1 from public.students where id=i.student_id and teacher_id=t and archived_at is null)
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
end $$;
revoke all on function public.secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text) from public,anon;
grant execute on function public.secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text) to authenticated;

create or replace function public.secretary_browse(p_entity text,p_filters jsonb default '{}',p_search text default '',p_cursor uuid default null,p_limit integer default 30) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); q text; rows jsonb; n bigint; last_id uuid; allowed text[]; k text; row_expr text:='to_jsonb(x)'; ordering text:='x.id'; paging text:=' and ($4 is null or x.id>$4)';
begin
 if p_filters is null or p_search is null or p_entity is null or p_entity<>all(array['students','grade_levels','groups','group_enrollments','group_schedules','sessions','attendance','attendance_change_log','exams','assignments','invoices','payments','teacher_notes','notifications','secretaries']) or p_limit is null or p_limit not between 1 and 100 or length(p_search)>100 or jsonb_typeof(p_filters)<>'object' then raise exception 'VALIDATION_ERROR'; end if;
 allowed:=case p_entity
 when 'students' then array['id','archived_at'] when 'groups' then array['id','grade_level_id','archived_at']
 when 'group_enrollments' then array['id','group_id','student_id','status'] when 'group_schedules' then array['id','group_id']
 when 'sessions' then array['id','group_id','local_date','status','from','to'] when 'attendance' then array['id','session_id','student_id','status']
 when 'attendance_change_log' then array['id','attendance_id'] when 'exams' then array['id','student_id','group_id']
 when 'assignments' then array['id','student_id','group_id'] when 'invoices' then array['id','student_id','group_id','status']
 when 'payments' then array['id','invoice_id','idempotency_key'] when 'teacher_notes' then array['id','student_id']
 when 'notifications' then array['id','read_at'] else array['id'] end;
 for k in select jsonb_object_keys(p_filters) loop if not k=any(allowed) then raise exception 'VALIDATION_ERROR'; end if; end loop;
 q:=format(' from public.%I x where x.teacher_id=$1 and to_jsonb(x) @> ($2-''from''-''to'')',p_entity);
 if p_entity='sessions' and (p_filters ? 'from' or p_filters ? 'to') then
  if not (p_filters ? 'from' and p_filters ? 'to') or (p_filters->>'to')::date<(p_filters->>'from')::date or (p_filters->>'to')::date-(p_filters->>'from')::date>61 then raise exception 'VALIDATION_ERROR'; end if;
  q:=q||' and x.local_date between ($2->>''from'')::date and ($2->>''to'')::date';
 end if;
 if p_entity='notifications' then q:=q||' and x.recipient_id=auth.uid()'; end if;
 if p_entity in ('students','groups','grade_levels','exams','assignments','invoices') then
 q:=q||' and ($3='''' or position(lower($3) in lower(coalesce(to_jsonb(x)->>''full_name'',to_jsonb(x)->>''name'',to_jsonb(x)->>''title'',to_jsonb(x)->>''invoice_number'','''')))>0)';
 end if;
 execute 'select count(*)'||q into n using t,p_filters,p_search;
 if p_entity='invoices' then row_expr:='to_jsonb(x)||jsonb_build_object(''original_amount_egp'',coalesce(x.initial_amount_egp,x.amount_egp)::text,''amount_egp'',x.amount_egp::text,''paid_egp'',(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)::text from public.payments p where p.invoice_id=x.id),''balance_egp'',(case when x.status=''void'' then 0 else x.amount_egp-(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0) from public.payments p where p.invoice_id=x.id) end)::numeric(20,2)::text)'; end if;
 if p_entity='invoices' then row_expr:='(select v||jsonb_build_object(''ledger_net_egp'',v->''paid_egp'',''payable_balance_egp'',v->''balance_egp'') from (select '||row_expr||' v) amounts)'; end if;
 if p_entity='payments' then row_expr:='to_jsonb(x)||jsonb_build_object(''original_amount_egp'',x.amount_egp::text,''amount_egp'',x.amount_egp::text,''collector_name'',(select name from public.secretaries where id=x.collected_by),''original_collector_id'',(select collected_by from public.payments where id=x.reversal_of))'; end if;
 if p_entity='sessions' then row_expr:='to_jsonb(x)||jsonb_build_object(''status'',case when x.status=''cancelled'' then ''cancelled'' when x.ends_at<=statement_timestamp() then ''completed'' when x.starts_at<=statement_timestamp() then ''ongoing'' else ''upcoming'' end)'; end if;

 if p_entity in ('exams','assignments','invoices','attendance','group_enrollments','teacher_notes') then row_expr:=row_expr||'||jsonb_build_object(''student_name'',(select full_name from public.students where id=x.student_id and teacher_id=x.teacher_id))'; end if;
 if p_entity in ('exams','assignments','invoices','sessions','group_schedules','group_enrollments') then row_expr:=row_expr||'||jsonb_build_object(''group_name'',(select name from public.groups where id=x.group_id and teacher_id=x.teacher_id))'; end if;
 if p_entity='payments' then row_expr:=row_expr||'||jsonb_build_object(''original_collector_name'',(select s.name from public.payments p join public.secretaries s on s.id=p.collected_by where p.id=x.reversal_of),''reversed_by_payment_id'',(select id from public.payments where reversal_of=x.id))'; end if;

 if p_entity='groups' then row_expr:=row_expr||'||jsonb_build_object(''grade_level_name'',(select name from public.grade_levels where id=x.grade_level_id and teacher_id=x.teacher_id))'; end if;
 if p_entity='attendance' then row_expr:=row_expr||'||jsonb_build_object(''marker_name'',(select name from public.secretaries where id=x.marked_by and teacher_id=x.teacher_id))'; end if;
 if p_entity='attendance_change_log' then row_expr:=row_expr||'||jsonb_build_object(''actor_name'',(select name from public.secretaries where id=x.actor_id and teacher_id=x.teacher_id))'; end if;
 if p_entity='invoices' then row_expr:=row_expr||'||jsonb_build_object(''creator_name'',(select name from public.secretaries where id=x.created_by and teacher_id=x.teacher_id))'; end if;
 if p_entity='payments' then row_expr:=row_expr||'||jsonb_build_object(''invoice_number'',(select invoice_number from public.invoices where id=x.invoice_id and teacher_id=x.teacher_id),''student_name'',(select st.full_name from public.invoices i join public.students st on st.id=i.student_id where i.id=x.invoice_id and i.teacher_id=x.teacher_id),''group_name'',(select g.name from public.invoices i join public.groups g on g.id=i.group_id where i.id=x.invoice_id and i.teacher_id=x.teacher_id))'; end if;
 if p_entity='sessions' then ordering:='x.starts_at,x.id';paging:=' and ($4 is null or (x.starts_at,x.id)>(select starts_at,id from public.sessions where id=$4 and teacher_id=$1))'; end if;
 execute 'select coalesce(jsonb_agg(v order by ord),''[]'') from (select x.id,row_number() over(order by '||ordering||') ord,'||row_expr||' v'||q||paging||' order by '||ordering||' limit $5) z' into rows using t,p_filters,p_search,p_cursor,p_limit+1;
 if jsonb_array_length(rows)>p_limit then rows:=rows-p_limit; last_id:=(rows->(p_limit-1)->>'id')::uuid; end if;
 return jsonb_build_object('rows',rows,'total_count',n,'next_cursor',last_id,'synced_at',statement_timestamp(),'server_date',(statement_timestamp() at time zone 'Africa/Cairo')::date,'unread_count',case when p_entity='notifications' then (select count(*) from public.notifications where teacher_id=t and recipient_id=auth.uid() and read_at is null) else null end);
end $$;

create or replace function public.get_teacher_invoice_detail(p_id uuid,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
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
end $$;

create or replace function public.get_teacher_finance(p_from date,p_to date,p_kind text default 'invoices',
 p_student_id uuid default null,p_group_id uuid default null,p_secretary_id uuid default null,
 p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint; begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_kind is null or p_kind not in ('invoices','payments') then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null then perform private.require_teacher_student(p_student_id); end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_secretary_id is not null and not exists(select 1 from public.secretaries where id=p_secretary_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with scoped as (select i.*,coalesce((select sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)
   from public.payments p where p.teacher_id=t and p.invoice_id=i.id),0) as net_paid
  from public.invoices i where i.teacher_id=t and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id))
 select jsonb_build_object('invoiced_egp',coalesce(sum(amount_egp) filter(where status<>'void'),0)::numeric(20,2)::text,
  'paid_against_invoices_egp',coalesce(sum(net_paid) filter(where status<>'void'),0)::numeric(20,2)::text,
  'outstanding_egp',coalesce(sum(amount_egp-net_paid) filter(where status<>'void'),0)::numeric(20,2)::text) into stats from scoped;
 stats:=stats||jsonb_build_object('period_net_collected_egp',(select coalesce(sum(
   case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)::numeric(20,2)::text
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
  where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_secretary_id is null or p.collected_by=p_secretary_id)));
 stats:=stats||jsonb_build_object('daily_collections',(select coalesce(jsonb_agg(to_jsonb(d) order by d.date),'[]') from (
  select (p.collected_at at time zone 'Africa/Cairo')::date::text as date,
   sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text as net_egp
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
  where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
   and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_secretary_id is null or p.collected_by=p_secretary_id)
  group by (p.collected_at at time zone 'Africa/Cairo')::date) d));
 if p_kind='invoices' then
  select count(*) into n from public.invoices i where i.teacher_id=t and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select i.id,i.student_id,(select full_name from public.students where id=i.student_id and teacher_id=t) as student_name,
    i.group_id,(select name from public.groups where id=i.group_id and teacher_id=t) as group_name,
    i.invoice_number,i.amount_egp::text,i.due_on,i.status,i.void_reason,
    coalesce(p.net_paid,0)::numeric(20,2)::text as net_paid_egp,
    (case when i.status='void' then 0 else i.amount_egp-coalesce(p.net_paid,0) end)::numeric(20,2)::text as outstanding_egp
   from public.invoices i left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) as net_paid
    from public.payments where teacher_id=t and invoice_id=i.id) p on true
   where i.teacher_id=t and i.due_on between p_from and p_to and (p_student_id is null or i.student_id=p_student_id)
    and (p_group_id is null or i.group_id=p_group_id) and (p_cursor is null or i.id>p_cursor) order by i.id limit p_limit+1) r;
 else
  select count(*) into n from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
   where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
    and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
    and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
    and (p_secretary_id is null or p.collected_by=p_secretary_id);
  select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
   select p.id,p.invoice_id,i.invoice_number,i.student_id,
    (select full_name from public.students where id=i.student_id and teacher_id=t) as student_name,
    p.amount_egp::text,(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text as signed_amount_egp,
    p.receipt_number,p.collected_at,p.method,p.reversal_of,p.reason,p.collected_by,
    (select name from public.secretaries where id=p.collected_by and teacher_id=t) as collected_by_name
   from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=p.teacher_id
   where p.teacher_id=t and p.collected_at>=p_from::timestamp at time zone 'Africa/Cairo'
    and p.collected_at<(p_to+1)::timestamp at time zone 'Africa/Cairo'
    and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
    and (p_secretary_id is null or p.collected_by=p_secretary_id) and (p_cursor is null or p.id>p_cursor)
   order by p.id limit p_limit+1) r;
 end if;
 if p_kind='invoices' then
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',coalesce((select initial_amount_egp::text from public.invoices where id=(v->>'id')::uuid and teacher_id=t),v->>'amount_egp'),'ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;

create or replace function public.list_teacher_finance_dues(p_from date,p_to date,p_status text default 'all',
 p_search text default '',p_student_id uuid default null,p_group_id uuid default null,
 p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; stats jsonb; n bigint;
 today date:=(statement_timestamp() at time zone 'Africa/Cairo')::date;
begin
 perform private.check_teacher_window(p_from,p_to,p_limit);
 if p_status is null or p_status not in ('all','overdue','partial','not_late','paid')
  or p_search is null or length(p_search)>100 then raise exception 'VALIDATION_ERROR'; end if;
 if p_student_id is not null and not exists(select 1 from public.students where id=p_student_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 if p_group_id is not null and not exists(select 1 from public.groups where id=p_group_id and teacher_id=t)
  then raise exception 'NOT_FOUND'; end if;
 with scoped as materialized (
  select i.id,i.invoice_number,i.student_id,s.full_name student_name,i.group_id,g.name group_name,
   i.amount_egp,i.due_on,coalesce(p.paid,0) paid,i.amount_egp-coalesce(p.paid,0) remaining,
   i.created_by,a.name created_by_name
  from public.invoices i join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.groups g on g.id=i.group_id and g.teacher_id=t
  left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
  left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
   from public.payments where teacher_id=t and invoice_id=i.id) p on true
  where i.teacher_id=t and i.status<>'void' and i.due_on between p_from and p_to
   and (p_student_id is null or i.student_id=p_student_id) and (p_group_id is null or i.group_id=p_group_id)
   and (p_search='' or strpos(lower(s.full_name),lower(p_search))>0
    or strpos(lower(i.invoice_number),lower(p_search))>0)
 ), filtered as materialized (
  select * from scoped where p_status='all'
   or (p_status='paid' and remaining=0)
   or (p_status='overdue' and remaining>0 and due_on<today)
   or (p_status='partial' and paid>0 and remaining>0)
   or (p_status='not_late' and remaining>0 and due_on>=today)
 ), page as (
  select id,invoice_number,student_id,student_name,group_id,group_name,due_on,created_by,created_by_name,
   amount_egp::numeric(20,2)::text amount_egp,paid::numeric(20,2)::text net_paid_egp,
   remaining::numeric(20,2)::text outstanding_egp
  from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1
 ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),
  jsonb_build_object('invoiced_egp',coalesce(sum(amount_egp),0)::numeric(20,2)::text,
   'net_paid_egp',coalesce(sum(paid),0)::numeric(20,2)::text,
   'outstanding_egp',coalesce(sum(remaining),0)::numeric(20,2)::text),count(*)
 into result,stats,n from filtered;
 if true then
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',coalesce((select initial_amount_egp::text from public.invoices where id=(v->>'id')::uuid and teacher_id=t),v->>'amount_egp'),'ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n,'as_of_date',today);
end $$;

commit;
