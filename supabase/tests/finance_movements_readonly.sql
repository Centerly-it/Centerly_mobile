-- Authorized read-only postflight on EXISTING synthetic accounts/data only.
-- No provisioning, account status changes, ledger writes or fixture mutations.
begin read only;
select set_config('centerly.ta',(select id::text from auth.users where email='teacher-a@centerly.test'),true);
select set_config('centerly.tb',(select id::text from auth.users where email='teacher-b@centerly.test'),true);
select set_config('centerly.sa',(select id::text from auth.users where email='secretary-a@centerly.test'),true);
select set_config('centerly.foreign_student',(select min(id::text) from public.students where teacher_id=current_setting('centerly.tb')::uuid),true);
select set_config('centerly.foreign_group',(select min(id::text) from public.groups where teacher_id=current_setting('centerly.tb')::uuid),true);
select set_config('centerly.foreign_collector',(select min(id::text) from public.secretaries where teacher_id=current_setting('centerly.tb')::uuid),true);
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('centerly.ta'),true);
do $$
declare
 t uuid:=current_setting('centerly.ta')::uuid;
 first_day date; last_day date; search_text text; method_filter text; kind_filter text;
 receipt_search text; invoice_search text; student_search text;
 sample_student uuid; sample_group uuid; sample_actor uuid;
 page jsonb; expected_count bigint; expected_gross numeric; expected_corrections numeric; expected_net numeric;
 actual_net numeric; scanned bigint; previous_id uuid; cursor_id uuid; row_id uuid; r jsonb;
 checks integer:=0; reports integer:=0; pages integer:=0; max_rows bigint:=0; correction_rows bigint:=0;
begin
 if t is null then raise exception 'SYNTHETIC_TEACHER_MISSING'; end if;
 select max((collected_at at time zone 'Africa/Cairo')::date) into last_day from public.payments where teacher_id=t;
 if last_day is null then raise exception 'NO_EXISTING_SYNTHETIC_MOVEMENTS'; end if;
 first_day:=last_day-365;
 select p.receipt_number::text,i.invoice_number,s.full_name,i.student_id,i.group_id,p.collected_by
 into receipt_search,invoice_search,student_search,sample_student,sample_group,sample_actor
 from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
 join public.students s on s.id=i.student_id and s.teacher_id=t
 where p.teacher_id=t and (p.collected_at at time zone 'Africa/Cairo')::date between first_day and last_day
 order by p.id limit 1;
 select count(*) into correction_rows from public.payments where teacher_id=t and reversal_of is not null
 and (collected_at at time zone 'Africa/Cairo')::date between first_day and last_day;
 if correction_rows=0 then raise exception 'NO_EXISTING_SYNTHETIC_CORRECTIONS'; end if;
 foreach search_text in array array['',receipt_search,invoice_search,student_search,'%__NO_MATCH__%'] loop
  foreach method_filter in array array[null::text,'cash','transfer','other'] loop
   foreach kind_filter in array array[null::text,'collections','corrections'] loop
    select count(*),coalesce(sum(p.amount_egp) filter(where p.reversal_of is null),0),
      coalesce(sum(p.amount_egp) filter(where p.reversal_of is not null),0),
      coalesce(sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end),0)
    into expected_count,expected_gross,expected_corrections,expected_net
    from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
    join public.students s on s.id=i.student_id and s.teacher_id=t
    where p.teacher_id=t
      and p.collected_at>=first_day::timestamp at time zone 'Africa/Cairo'
      and p.collected_at<(last_day+1)::timestamp at time zone 'Africa/Cairo'
      and (method_filter is null or p.method=method_filter)
      and (kind_filter is null or (kind_filter='corrections')=(p.reversal_of is not null))
      and (search_text='' or strpos(lower(s.full_name),lower(search_text))>0
        or strpos(lower(i.invoice_number),lower(search_text))>0 or strpos(lower(p.receipt_number::text),lower(search_text))>0);
    cursor_id:=null; previous_id:=null; scanned:=0; actual_net:=0; reports:=reports+1;
    loop
      page:=public.list_teacher_finance_movements(first_day,last_day,search_text,method_filter,kind_filter,null,null,null,cursor_id,1);
      if (page->>'total_count')::bigint<>expected_count
        or (page->'summary'->>'gross_egp')::numeric<>expected_gross
        or (page->'summary'->>'corrections_egp')::numeric<>expected_corrections
        or (page->'summary'->>'net_egp')::numeric<>expected_net then raise exception 'FULL_FILTERED_TOTAL_MISMATCH'; end if;
      checks:=checks+4; pages:=pages+1;
      if jsonb_array_length(page->'rows')>1 then raise exception 'PAGE_LIMIT_MISMATCH'; end if;
      checks:=checks+1;
      for r in select value from jsonb_array_elements(page->'rows') loop
        row_id:=(r->>'id')::uuid;
        if previous_id is not null and row_id<=previous_id then raise exception 'NON_ADVANCING_PAGE'; end if;
        if not exists(select 1 from public.payments where id=row_id and teacher_id=t) then raise exception 'TENANT_ROW_LEAK'; end if;
        if (r->>'signed_amount_egp')::numeric<>(case when r->>'reversal_of' is null then (r->>'amount_egp')::numeric else -(r->>'amount_egp')::numeric end) then raise exception 'MONEY_SIGN_MISMATCH'; end if;
        if r->>'reversal_of' is not null and not exists(select 1 from public.payments o
          left join public.secretaries a on a.id=o.collected_by and a.teacher_id=t
          where o.id=(r->>'reversal_of')::uuid and o.teacher_id=t
          and o.receipt_number::text=r->>'original_receipt_number'
          and a.name is not distinct from r->>'original_collected_by_name') then raise exception 'ORIGINAL_ATTRIBUTION_MISMATCH'; end if;
        if not exists(select 1 from public.payments p left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
          where p.id=row_id and a.name is not distinct from r->>'collected_by_name') then raise exception 'COLLECTOR_ATTRIBUTION_MISMATCH'; end if;
        checks:=checks+5; scanned:=scanned+1; actual_net:=actual_net+(r->>'signed_amount_egp')::numeric;
        previous_id:=row_id;
      end loop;
      cursor_id:=(page->>'next_cursor')::uuid;
      if cursor_id is not null and (jsonb_array_length(page->'rows')=0 or cursor_id<>previous_id) then raise exception 'NEXT_CURSOR_MISMATCH'; end if;
      checks:=checks+1;
      exit when cursor_id is null;
      if scanned>expected_count or pages>10000 then raise exception 'LOOPING_PAGES'; end if;
    end loop;
    if scanned<>expected_count or actual_net<>expected_net then raise exception 'PAGED_RECONCILIATION_MISMATCH'; end if;
    checks:=checks+2; max_rows:=greatest(max_rows,scanned);
   end loop;
  end loop;
 end loop;
 if max_rows<2 then raise exception 'MULTIPAGE_FIXTURE_UNAVAILABLE'; end if;
 page:=public.list_teacher_finance_movements(first_day,last_day,'',null,null,sample_actor,sample_student,sample_group,null,1);
 select count(*) into expected_count from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
 where p.teacher_id=t and p.collected_by=sample_actor and i.student_id=sample_student
 and (sample_group is null or i.group_id=sample_group)
 and (p.collected_at at time zone 'Africa/Cairo')::date between first_day and last_day;
 if (page->>'total_count')::bigint<>expected_count then raise exception 'ENTITY_FILTER_MISMATCH'; end if;
 checks:=checks+1;
 begin perform public.list_teacher_finance_movements(first_day,last_day,'',null,null,null,current_setting('centerly.foreign_student')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if;end; checks:=checks+1;
 begin perform public.list_teacher_finance_movements(first_day,last_day,'',null,null,null,null,current_setting('centerly.foreign_group')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if;end; checks:=checks+1;
 begin perform public.list_teacher_finance_movements(first_day,last_day,'',null,null,current_setting('centerly.foreign_collector')::uuid);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if;end; checks:=checks+1;
 begin perform public.list_teacher_finance_movements(first_day,last_day,'','invalid');raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'VALIDATION_ERROR' then raise; end if;end; checks:=checks+1;
 begin perform public.list_teacher_finance_movements(first_day,last_day,'',null,'invalid');raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'VALIDATION_ERROR' then raise; end if;end; checks:=checks+1;
 perform set_config('centerly.movement_result',jsonb_build_object('checks',checks,'reports',reports,'pages',pages,'max_report_rows',max_rows,'existing_corrections',correction_rows)::text,true);
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.tb'),true);
do $$ declare page jsonb;r jsonb; begin
 page:=public.list_teacher_finance_movements(current_date-180,current_date+180,'',null,null,null,null,null,null,100);
 for r in select value from jsonb_array_elements(page->'rows') loop
  if not exists(select 1 from public.payments where id=(r->>'id')::uuid and teacher_id=current_setting('centerly.tb')::uuid) then raise exception 'OTHER_TEACHER_SCOPE_LEAK'; end if;
 end loop;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.sa'),true);
do $$ begin
 begin perform public.list_teacher_finance_movements(current_date,current_date);raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if;end;
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform public.list_teacher_finance_movements(current_date,current_date);raise exception 'UNEXPECTED_ALLOW';
 exception when insufficient_privilege then null;end;
end $$;
reset role;
select jsonb_build_object('pass',true,'mode','read-only SQL roles; existing synthetic records only',
 'teacher_checks',current_setting('centerly.movement_result')::jsonb,'other_teacher_scope',true,'secretary_denied',true,'anonymous_denied',true) as finance_movements_postflight;
commit;
