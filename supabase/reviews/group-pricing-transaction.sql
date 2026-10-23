begin;
-- Owner review: enrollment-anniversary group pricing. Apply only after review approval.
-- Existing invoices and receipts are unchanged. Billing begins with each active enrollment.
alter table public.groups
 add column monthly_fee_egp numeric(12,2) not null default 0 check(monthly_fee_egp>=0),
 add column materials_fee_egp numeric(12,2) not null default 0 check(materials_fee_egp>=0);
alter table public.group_enrollments add column last_billed_on date;
-- Billing cursor is server-owned, including zero-price cycles. Membership edits use the RPC.
revoke update on public.group_enrollments from authenticated;
alter table public.invoices
 add column billing_period_start date,
 add column monthly_fee_egp numeric(12,2),
 add column materials_fee_egp numeric(12,2),
 add constraint group_bill_components check(billing_period_start is null or
  (group_id is not null and monthly_fee_egp is not null and materials_fee_egp is not null
   and monthly_fee_egp>=0 and materials_fee_egp>=0
   and amount_egp=monthly_fee_egp+materials_fee_egp
   and billing_period_start is not null));
create unique index one_group_bill_per_period on public.invoices(student_id,group_id,billing_period_start)
 where billing_period_start is not null;

create function private.billing_cycle_on(anchor date,on_date date) returns date
language plpgsql immutable set search_path='' as $$
declare d date;
begin
 d:=least((date_trunc('month',on_date)+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',on_date)+interval '1 month - 1 day')::date);
 if d>on_date then d:=least((date_trunc('month',on_date)-interval '1 month'+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',on_date)-interval '1 day')::date);end if;
 return d;
end $$;
create function private.billing_cycle_next(anchor date,previous date) returns date
language sql immutable set search_path='' as $$
 select least((date_trunc('month',previous)+interval '1 month'+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',previous)+interval '2 months - 1 day')::date)
$$;
revoke all on function private.billing_cycle_on(date,date),private.billing_cycle_next(date,date) from public,anon,authenticated;

create function private.bill_group_month(p_group uuid,p_student uuid,p_materials boolean)
returns uuid language plpgsql security definer set search_path='' as $$
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
end $$;
revoke all on function private.bill_group_month(uuid,uuid,boolean) from public,anon,authenticated;

create function private.enrollment_bill() returns trigger language plpgsql security definer set search_path='' as $$
begin
 perform private.bill_group_month(new.group_id,new.student_id,true);
 return new;
end $$;
revoke all on function private.enrollment_bill() from public,anon,authenticated;
create trigger enrollment_automatic_bill after insert on public.group_enrollments
 for each row when(new.status='active') execute function private.enrollment_bill();

-- Authenticated refresh settles every elapsed active enrollment cycle, including missed visits.
-- Price changes settle elapsed cycles at the old price first. No cron or proration.
create function public.secretary_refresh_group_dues() returns integer
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');g record;s record;n integer:=0;v uuid;
begin
 for g in select id from public.groups where teacher_id=t and archived_at is null
  and monthly_fee_egp>0 order by id for update loop
  for s in select e.student_id from public.group_enrollments e join public.students st
   on st.id=e.student_id and st.teacher_id=t where e.teacher_id=t and e.group_id=g.id
   and e.status='active' and st.archived_at is null order by e.student_id loop
   v:=private.bill_group_month(g.id,s.student_id,false);if v is not null then n:=n+1;end if;
  end loop;
 end loop;
 return n;
end $$;
revoke all on function public.secretary_refresh_group_dues() from public,anon;
grant execute on function public.secretary_refresh_group_dues() to authenticated;

create function private.group_bill_snapshot_guard() returns trigger
language plpgsql set search_path='' as $$
begin
 if (new.billing_period_start,new.monthly_fee_egp,new.materials_fee_egp,new.amount_egp,
  new.student_id,new.group_id,new.teacher_id) is distinct from
 (old.billing_period_start,old.monthly_fee_egp,old.materials_fee_egp,old.amount_egp,
  old.student_id,old.group_id,old.teacher_id) then raise exception 'CONFLICT';end if;
 return new;
end $$;
revoke all on function private.group_bill_snapshot_guard() from public,anon,authenticated;
create trigger group_bill_snapshot before update on public.invoices
 for each row when(old.billing_period_start is not null) execute function private.group_bill_snapshot_guard();

create function private.enrollment_billing_cursor() returns trigger language plpgsql security definer set search_path='' as $$
begin
 new.last_billed_on:=null;
 return new;
end $$;
revoke all on function private.enrollment_billing_cursor() from public,anon,authenticated;
create trigger zz_enrollment_billing_cursor before insert on public.group_enrollments
 for each row execute function private.enrollment_billing_cursor();

create function private.settle_before_group_price() returns trigger language plpgsql security definer set search_path='' as $$
declare s record;
begin
 for s in select e.student_id from public.group_enrollments e join public.students st on st.id=e.student_id
  where e.group_id=old.id and e.teacher_id=old.teacher_id and e.status='active' and st.archived_at is null order by e.student_id loop
  perform private.bill_group_month(old.id,s.student_id,false);
 end loop;
 return new;
end $$;
revoke all on function private.settle_before_group_price() from public,anon,authenticated;
create trigger settle_group_prices before update on public.groups for each row
 when(old.monthly_fee_egp is distinct from new.monthly_fee_egp or old.materials_fee_egp is distinct from new.materials_fee_egp)
 execute function private.settle_before_group_price();

create or replace function public.secretary_enroll(p_group_id uuid,p_student_id uuid,p_enrollment_id uuid default null) returns uuid language plpgsql security definer set search_path='' as $$
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
end $$;

create or replace function public.secretary_archive(p_entity text,p_id uuid) returns timestamptz
language plpgsql security definer set search_path='' as $$
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
end $$;

-- Move and both groups' billing are one transaction; a failed target leaves the old membership intact.
create function public.secretary_transfer(p_enrollment_id uuid,p_group_id uuid) returns uuid
language plpgsql security definer set search_path='' as $$
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
end $$;
revoke all on function public.secretary_transfer(uuid,uuid) from public,anon;
grant execute on function public.secretary_transfer(uuid,uuid) to authenticated;

commit;
