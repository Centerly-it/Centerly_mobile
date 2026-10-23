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

