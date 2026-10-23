-- GENERATED REVIEW ARTIFACT: centerly-dev only after explicit approval.
-- Source: eight focused proposal files pinned in review-manifest.json.
begin;
-- LOCAL REVIEW ONLY. Not deployed. Baseline 27 migrations remain immutable.
-- PACKAGE PROPOSAL ONLY: no managed migration or hosted change authorized.
create or replace function private.require_teacher_student(p_id uuid) returns uuid
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); begin
  if p_id is null then raise exception 'VALIDATION_ERROR'; end if;
  if not exists(select 1 from public.students where id=p_id and teacher_id=t)
    then raise exception 'NOT_FOUND'; end if;
  return t;
end $$;

revoke all on function private.require_teacher_student(uuid) from public,anon,authenticated;

-- LOCAL REVIEW ONLY. Not deployed. Baseline 27 migrations remain immutable.
-- PROPOSAL ONLY. Not managed/deployed; separate owner approval required.
-- Teacher-only student contacts and bounded membership history; no mutation/QR.
create or replace function public.get_teacher_student_profile(p_id uuid,p_cursor uuid default null,
  p_limit integer default 30) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); v_student jsonb;
  v_rows jsonb; v_next uuid; v_count bigint;
begin
  if p_id is null or p_limit is null or p_limit not between 1 and 100 then
    raise exception 'VALIDATION_ERROR'; end if;
  select jsonb_build_object('id',id,'full_name',full_name,'phone',phone,
    'guardian_phone',guardian_phone,'level_tag',level_tag,'created_at',created_at,'updated_at',updated_at,'archived_at',archived_at)
    into v_student from public.students where id=p_id and teacher_id=v_tenant;
  if not found then raise exception 'NOT_FOUND'; end if;
  select count(*) into v_count from public.group_enrollments where student_id=p_id and teacher_id=v_tenant;
  with page as materialized (
    select e.id,e.group_id,e.status,e.joined_at,e.left_at,g.name as group_name,
      g.subject_name,g.archived_at as group_archived_at,l.name as grade_name
    from public.group_enrollments e
    join public.groups g on g.id=e.group_id and g.teacher_id=e.teacher_id
    join public.grade_levels l on l.id=g.grade_level_id and l.teacher_id=g.teacher_id
    where e.student_id=p_id and e.teacher_id=v_tenant and (p_cursor is null or e.id>p_cursor)
    order by e.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]'::jsonb)
      from (select * from page order by id limit p_limit) r),
    case when (select count(*) from page)>p_limit
      then (select id from page order by id offset p_limit-1 limit 1) else null end
    into v_rows,v_next;
  return jsonb_build_object('student',v_student,'memberships',v_rows,
    'membership_count',v_count,'next_cursor',v_next,'synced_at',statement_timestamp());
end $$;
revoke all on function public.get_teacher_student_profile(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_student_profile(uuid,uuid,integer) to authenticated;

-- LOCAL REVIEW ONLY. Not deployed. Baseline 27 migrations remain immutable.
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
 if p_entity='invoices' then row_expr:='to_jsonb(x)||jsonb_build_object(''original_amount_egp'',x.amount_egp::text,''amount_egp'',x.amount_egp::text,''paid_egp'',(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)::text from public.payments p where p.invoice_id=x.id),''balance_egp'',(case when x.status=''void'' then 0 else x.amount_egp-(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0) from public.payments p where p.invoice_id=x.id) end)::numeric(20,2)::text)'; end if;
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

-- LOCAL REVIEW ONLY; no hosted changes.
-- LOCAL PROPOSAL ONLY: creator is attribution, never an assigned debtor owner.
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
 header:=header||jsonb_build_object('original_amount_egp',header->'amount_egp','ledger_net_egp',header->'net_paid_egp','payable_balance_egp',header->'outstanding_egp');
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
revoke all on function public.get_teacher_invoice_detail(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_invoice_detail(uuid,uuid,integer) to authenticated;

-- LOCAL REVIEW ONLY; no hosted changes.
-- PACKAGE PROPOSAL ONLY. Invoice totals use due dates; collections use Cairo receipt dates.
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
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',v->'amount_egp','ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n);
end $$;
revoke all on function public.get_teacher_finance(date,date,text,uuid,uuid,uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_finance(date,date,text,uuid,uuid,uuid,uuid,integer) to authenticated;

-- LOCAL REVIEW ONLY; no hosted changes.
-- LOCAL PROPOSAL ONLY: filter before pagination; all totals cover the full filtered set.
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
  select coalesce(jsonb_agg(v||jsonb_build_object('original_amount_egp',v->'amount_egp','ledger_net_egp',v->'net_paid_egp','payable_balance_egp',v->'outstanding_egp') order by ord),'[]') into result from jsonb_array_elements(result) with ordinality a(v,ord);
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('summary',stats,'total_count',n,'as_of_date',today);
end $$;
revoke all on function public.list_teacher_finance_dues(date,date,text,text,uuid,uuid,uuid,integer) from public,anon;
grant execute on function public.list_teacher_finance_dues(date,date,text,text,uuid,uuid,uuid,integer) to authenticated;

-- LOCAL REVIEW ONLY. Archive is a read-only boundary, not deletion.
create function private.archived_student_write_guard() returns trigger
language plpgsql security definer set search_path='' as $$
declare student uuid; tenant uuid; stamp timestamptz;
begin
 if tg_table_name='students' then
  if old.archived_at is not null then raise exception 'CONFLICT'; end if;
  return new;
 end if;
 tenant:=new.teacher_id;
 if tg_table_name='payments' then
  -- Existing reversal workflow preserves correction/audit history.
  if new.reversal_of is not null then return new; end if;
  select student_id into student from public.invoices where id=new.invoice_id and teacher_id=tenant;
 else student:=new.student_id;
 end if;
 select archived_at into stamp from public.students
  where id=student and teacher_id=tenant for share;
 if not found then raise exception 'NOT_FOUND'; end if;
 if stamp is not null then raise exception 'CONFLICT'; end if;
 if tg_op='UPDATE' then
  if new.student_id<>old.student_id or new.teacher_id<>old.teacher_id then raise exception 'CONFLICT'; end if;
 end if;
 return new;
end $$;
revoke all on function private.archived_student_write_guard() from public,anon,authenticated;
create trigger archived_student_record before update on public.students
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_note before insert or update on public.teacher_notes
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_exam before insert or update on public.exams
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_assignment before insert or update on public.assignments
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_invoice before insert on public.invoices
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_collection before insert on public.payments
 for each row execute function private.archived_student_write_guard();
create trigger archived_student_attendance before insert or update on public.attendance
 for each row execute function private.archived_student_write_guard();

-- LOCAL REVIEW ONLY. Skip archived students without blocking unrelated generation.
create or replace function public.generate_sessions(p_from date,p_to date) returns integer
language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_count integer;
begin
  perform pg_advisory_xact_lock(hashtextextended(v_tenant::text||'schedule_generation',0));
  if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR'; end if;
  insert into public.sessions(teacher_id,group_id,schedule_id,local_date,starts_at,ends_at)
    select v_tenant,s.group_id,s.id,d::date,
      (d::date+s.local_start_time) at time zone 'Africa/Cairo',
      (d::date+case when s.local_end_time<s.local_start_time then 1 else 0 end+s.local_end_time) at time zone 'Africa/Cairo'
    from public.group_schedules s cross join generate_series(p_from::timestamp,p_to::timestamp,interval '1 day') d
    join public.groups g on g.id=s.group_id and g.teacher_id=s.teacher_id
    where s.teacher_id=v_tenant and g.archived_at is null and extract(dow from d)=s.weekday
      and d::date>=s.effective_from and (s.effective_to is null or d::date<=s.effective_to)
    on conflict(schedule_id,local_date) do nothing;
  get diagnostics v_count=row_count;
  insert into public.attendance(teacher_id,session_id,student_id)
    select v_tenant,s.id,e.student_id from public.sessions s
    join public.group_enrollments e on e.group_id=s.group_id and e.teacher_id=s.teacher_id
    join public.students pupil on pupil.id=e.student_id and pupil.teacher_id=e.teacher_id and pupil.archived_at is null
    where s.teacher_id=v_tenant and s.local_date between p_from and p_to and s.status<>'cancelled'
      and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
    on conflict(session_id,student_id) do nothing;
  return v_count;
end $$;

-- Serialize revisions and generation; preserve existing signatures/Teacher behavior.

commit;
