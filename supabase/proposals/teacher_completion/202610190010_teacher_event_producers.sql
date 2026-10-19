-- PACKAGE PROPOSAL ONLY. Future writes only; no notification backfill.
create function private.notify_teacher_payment() returns trigger
language plpgsql security definer set search_path='' as $$ begin
 insert into public.notifications(teacher_id,recipient_id,type,payload)
 values(new.teacher_id,new.teacher_id,case when new.reversal_of is null then 'payment_collected' else 'payment_reversed' end,
  jsonb_build_object('payment_id',new.id));
 return new;
end $$;
create trigger notify_teacher_payment after insert on public.payments
 for each row execute function private.notify_teacher_payment();
create function private.notify_teacher_removal_handled() returns trigger
language plpgsql security definer set search_path='' as $$ begin
 if old.status='pending' and new.status='handled' then
  insert into public.notifications(teacher_id,recipient_id,type,payload)
   values(new.teacher_id,new.teacher_id,'removal_handled',jsonb_build_object('request_id',new.id));
 end if;
 return new;
end $$;
create trigger notify_teacher_removal_handled after update on public.secretary_removal_requests
 for each row execute function private.notify_teacher_removal_handled();
revoke all on function private.notify_teacher_payment(),private.notify_teacher_removal_handled() from public,anon,authenticated;
