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
