-- LOCAL REVIEW ONLY. Apply through canonical Teacher migration ownership after approval.
-- Never edit/replay the pinned baseline. No hosted deployment authorized.
create function private.enrollment_guard() returns trigger language plpgsql security definer set search_path='' as $$
declare g public.groups; n integer;
begin
 if tg_op='INSERT' and auth.uid() is not null then new.joined_at:=clock_timestamp();new.status:='active';new.left_at:=null; end if;
 if tg_op='UPDATE' and old.status='inactive' then raise exception 'CONFLICT'; end if;
 if tg_op='UPDATE' and new.status='inactive' and old.status='active' then new.left_at:=clock_timestamp(); end if;
 if tg_op='UPDATE' and (new.teacher_id<>old.teacher_id or new.student_id<>old.student_id or new.group_id<>old.group_id or new.joined_at<>old.joined_at) then raise exception 'CONFLICT'; end if;
 select * into g from public.groups where id=new.group_id and teacher_id=new.teacher_id for update;
 if not found then raise exception 'NOT_FOUND'; end if;
 if new.status='active' then
  if g.archived_at is not null or not exists(select 1 from public.students where id=new.student_id and teacher_id=new.teacher_id and archived_at is null) then raise exception 'CONFLICT'; end if;
  select count(*) into n from public.group_enrollments where group_id=g.id and status='active' and id<>new.id;
  if n>=g.capacity then raise exception 'CONFLICT'; end if;
 end if;
 return new;
end $$;
create trigger secretary_enrollment_guard before insert or update on public.group_enrollments for each row execute function private.enrollment_guard();
create function private.capacity_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.id<>old.id or new.teacher_id<>old.teacher_id then raise exception 'CONFLICT'; end if;
 if new.capacity<(select count(*) from public.group_enrollments where group_id=new.id and status='active') then raise exception 'CONFLICT'; end if;
 return new;
end $$;
create trigger secretary_capacity_guard before update on public.groups for each row execute function private.capacity_guard();
create function public.secretary_enroll(p_group_id uuid,p_student_id uuid,p_enrollment_id uuid default null) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); v uuid;
begin
 if p_enrollment_id is null then
 insert into public.group_enrollments(teacher_id,group_id,student_id) values(t,p_group_id,p_student_id) returning id into v;
 insert into public.attendance(teacher_id,session_id,student_id)
 select t,id,p_student_id from public.sessions where teacher_id=t and group_id=p_group_id and status<>'cancelled' and ends_at>=statement_timestamp()
 on conflict(session_id,student_id) do nothing;
 else
 update public.group_enrollments set status='inactive',left_at=clock_timestamp() where teacher_id=t and id=p_enrollment_id and group_id=p_group_id and student_id=p_student_id and status='active' returning id into v;
 if v is null then raise exception 'CONFLICT'; end if;
 end if;
 return v;
end $$;
create function public.secretary_set_attendance(p_session_id uuid,p_student_id uuid,p_status text,p_expected_updated_at timestamptz default null,p_reason text default null) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); a public.attendance;
begin
 perform 1 from public.sessions where id=p_session_id and teacher_id=t for update;
 if not found then raise exception 'NOT_FOUND'; end if;
 select * into a from public.attendance where session_id=p_session_id and student_id=p_student_id and teacher_id=t;
 if a.updated_at is distinct from p_expected_updated_at then raise exception 'CONFLICT'; end if;
 return public.set_attendance(p_session_id,p_student_id,p_status,p_reason);
end $$;
create function public.secretary_revise_schedule(p_id uuid,p_from date,p_weekday integer,p_start time,p_end time,p_to date default null) returns uuid language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); s public.group_schedules;
begin
 perform pg_advisory_xact_lock(hashtextextended(t::text||'schedule_generation',0));
 select * into s from public.group_schedules where id=p_id and teacher_id=t for update;
 if not found then raise exception 'NOT_FOUND'; end if;
 if exists(select 1 from public.sessions where schedule_id=s.id and local_date>=p_from) then raise exception 'CONFLICT'; end if;
 if p_from<=s.effective_from or p_from<(statement_timestamp() at time zone 'Africa/Cairo')::date or (s.effective_to is not null and p_from>s.effective_to) then raise exception 'VALIDATION_ERROR'; end if;
 update public.group_schedules set effective_to=p_from-1 where id=s.id;
 return public.add_schedule(s.group_id,p_weekday,p_start,p_end,p_from,p_to);
end $$;
create function public.secretary_browse(p_entity text,p_filters jsonb default '{}',p_search text default '',p_cursor uuid default null,p_limit integer default 30) returns jsonb language plpgsql stable security definer set search_path='' as $$
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
 if p_entity='invoices' then row_expr:='to_jsonb(x)||jsonb_build_object(''amount_egp'',x.amount_egp::text,''paid_egp'',(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)::text from public.payments p where p.invoice_id=x.id),''balance_egp'',(x.amount_egp-(select coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0) from public.payments p where p.invoice_id=x.id))::text)'; end if;
 if p_entity='payments' then row_expr:='to_jsonb(x)||jsonb_build_object(''amount_egp'',x.amount_egp::text,''collector_name'',(select name from public.secretaries where id=x.collected_by),''original_collector_id'',(select collected_by from public.payments where id=x.reversal_of))'; end if;
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
create function public.secretary_dashboard() returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); d date:=(statement_timestamp() at time zone 'Africa/Cairo')::date;
begin
 return jsonb_build_object('server_date',d,'synced_at',statement_timestamp(),
 'sessions',(select coalesce(jsonb_agg(to_jsonb(s)||jsonb_build_object('status',case when s.status='cancelled' then 'cancelled' when s.ends_at<=statement_timestamp() then 'completed' when s.starts_at<=statement_timestamp() then 'ongoing' else 'upcoming' end) order by s.starts_at),'[]') from public.sessions s where s.teacher_id=t and s.local_date=d),
 'pending',(select count(*) from public.attendance a join public.sessions s on s.id=a.session_id where a.teacher_id=t and s.local_date=d and s.status<>'cancelled' and a.status='not_marked'),
 'collected_egp',(select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)::text from public.payments where teacher_id=t and collected_at>=d::timestamp at time zone 'Africa/Cairo' and collected_at<(d+1)::timestamp at time zone 'Africa/Cairo'),
 'due_egp',(select coalesce(sum(i.amount_egp-coalesce(p.paid,0)),0)::text from public.invoices i left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where invoice_id=i.id) p on true where i.teacher_id=t and i.status<>'void' and i.due_on<=d),
 'outstanding_egp',(select coalesce(sum(i.amount_egp-coalesce(p.paid,0)),0)::text from public.invoices i left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where invoice_id=i.id) p on true where i.teacher_id=t and i.status<>'void'));
end $$;
revoke all on function private.enrollment_guard(),private.capacity_guard() from public,anon,authenticated;
revoke all on function public.secretary_enroll(uuid,uuid,uuid),public.secretary_set_attendance(uuid,uuid,text,timestamptz,text),public.secretary_revise_schedule(uuid,date,integer,time,time,date),public.secretary_browse(text,jsonb,text,uuid,integer),public.secretary_dashboard() from public,anon;
grant execute on function public.secretary_enroll(uuid,uuid,uuid),public.secretary_set_attendance(uuid,uuid,text,timestamptz,text),public.secretary_revise_schedule(uuid,date,integer,time,time,date),public.secretary_browse(text,jsonb,text,uuid,integer),public.secretary_dashboard() to authenticated;

create function public.secretary_archive(p_entity text,p_id uuid) returns timestamptz language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); stamp timestamptz;
begin
 if p_entity not in ('students','groups') then raise exception 'VALIDATION_ERROR'; end if;
 execute format('update public.%I set archived_at=coalesce(archived_at,clock_timestamp()) where id=$1 and teacher_id=$2 returning archived_at',p_entity) into stamp using p_id,t;
 if stamp is null then raise exception 'NOT_FOUND'; end if;
 return stamp;
end $$;
revoke all on function public.secretary_archive(text,uuid) from public,anon;
grant execute on function public.secretary_archive(text,uuid) to authenticated;
-- All schedule creation, including the original add_schedule RPC, checks lifecycle.
create function private.schedule_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.groups where id=new.group_id and teacher_id=new.teacher_id and archived_at is null for update;
 if not found then raise exception 'CONFLICT'; end if;
 if exists(select 1 from public.group_schedules s where s.group_id=new.group_id and s.id<>new.id
 and exists(select 1 from generate_series(-1,1) shift where numrange(s.weekday*86400+extract(epoch from s.local_start_time),s.weekday*86400+extract(epoch from s.local_end_time)+case when s.local_end_time<s.local_start_time then 86400 else 0 end,'[)') && numrange(new.weekday*86400+extract(epoch from new.local_start_time)+shift*604800,new.weekday*86400+extract(epoch from new.local_end_time)+case when new.local_end_time<new.local_start_time then 86400 else 0 end+shift*604800,'[)'))
 and daterange(s.effective_from,s.effective_to,'[]') && daterange(new.effective_from,new.effective_to,'[]')) then raise exception 'CONFLICT'; end if;
 return new;
end $$;
create trigger secretary_schedule_guard before insert on public.group_schedules for each row execute function private.schedule_guard();
revoke all on function private.schedule_guard() from public,anon,authenticated;

-- Serialize revisions and generation; preserve existing signatures/Teacher behavior.
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
    where s.teacher_id=v_tenant and s.local_date between p_from and p_to and s.status<>'cancelled'
      and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)
    on conflict(session_id,student_id) do nothing;
  return v_count;
end $$;

-- Serialize revisions and generation; preserve existing signatures/Teacher behavior.
create or replace function public.add_schedule(p_group_id uuid,p_weekday integer,p_start time,p_end time,p_from date,p_to date default null)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('secretary'); v_id uuid;
begin
  perform pg_advisory_xact_lock(hashtextextended(v_tenant::text||'schedule_generation',0));
  perform 1 from public.groups where id=p_group_id and teacher_id=v_tenant for update;
  if not found then raise exception 'NOT_FOUND'; end if;
  insert into public.group_schedules(teacher_id,group_id,weekday,local_start_time,local_end_time,effective_from,effective_to)
    values(v_tenant,p_group_id,p_weekday,p_start,p_end,p_from,p_to) returning id into v_id;
  return v_id;
end $$;
