-- Teacher operational inbox only; Secretary recipients and historical rows retained.
create function private.teacher_notification_scope() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if new.recipient_id=new.teacher_id and new.type not in
 ('student_added','student_withdrawn','student_removed','payment_collected') then return null;end if;
 return new;
end $$;
create trigger teacher_notification_scope before insert on public.notifications
 for each row execute function private.teacher_notification_scope();
create function private.notify_teacher_student_lifecycle() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if tg_op='INSERT' then
  insert into public.notifications(teacher_id,recipient_id,type,payload)
   values(new.teacher_id,new.teacher_id,'student_added',jsonb_build_object('student_id',new.id));
 elsif old.archived_at is null and new.archived_at is not null then
  insert into public.notifications(teacher_id,recipient_id,type,payload)
   values(new.teacher_id,new.teacher_id,'student_removed',jsonb_build_object('student_id',new.id));
 end if;
 return new;
end $$;
create trigger notify_teacher_student_added after insert on public.students
 for each row execute function private.notify_teacher_student_lifecycle();
create trigger notify_teacher_student_removed after update of archived_at on public.students
 for each row execute function private.notify_teacher_student_lifecycle();
create function private.notify_teacher_student_withdrawal() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if old.status='active' and new.status='inactive' and exists
 (select 1 from public.students where id=new.student_id and teacher_id=new.teacher_id and archived_at is null)
 and exists(select 1 from public.groups where id=new.group_id and teacher_id=new.teacher_id and archived_at is null) then
  insert into public.notifications(teacher_id,recipient_id,type,payload)
   values(new.teacher_id,new.teacher_id,'student_withdrawn',
     jsonb_build_object('student_id',new.student_id,'group_id',new.group_id));
 end if;
 return new;
end $$;
create trigger notify_teacher_student_withdrawal after update of status on public.group_enrollments
 for each row execute function private.notify_teacher_student_withdrawal();
create or replace function public.list_teacher_notifications(p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher');result jsonb;n bigint;unread bigint;
 allowed text[]:=array['student_added','student_withdrawn','student_removed','payment_collected'];
begin
 if p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR';end if;
 select count(*),count(*) filter(where read_at is null) into n,unread from public.notifications
 where teacher_id=t and recipient_id=auth.uid() and type=any(allowed);
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
 select x.id,x.type,x.created_at,x.read_at,
 (select s.full_name from public.students s where s.teacher_id=t and s.id::text=x.payload->>'student_id') student_name,
 jsonb_strip_nulls(jsonb_build_object('student_id',x.payload->'student_id','group_id',x.payload->'group_id',
 'payment_id',x.payload->'payment_id')) payload
 from public.notifications x where x.teacher_id=t and x.recipient_id=auth.uid() and x.type=any(allowed)
 and (p_cursor is null or x.id>p_cursor) order by x.id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('total_count',n,'unread_count',unread);
end $$;
revoke all on function private.teacher_notification_scope(),private.notify_teacher_student_lifecycle(),
 private.notify_teacher_student_withdrawal() from public,anon,authenticated;
revoke all on function public.list_teacher_notifications(uuid,integer) from public,anon;
grant execute on function public.list_teacher_notifications(uuid,integer) to authenticated;
