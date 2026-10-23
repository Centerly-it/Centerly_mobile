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
