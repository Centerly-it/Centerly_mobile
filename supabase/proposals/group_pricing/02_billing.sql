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

