-- PACKAGE PROPOSAL ONLY. Existing secured mutations remain unchanged.
create function public.get_teacher_student_note(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_teacher_student(p_id); begin
 return jsonb_build_object('note',(select jsonb_build_object('content',content,'updated_at',updated_at)
  from public.teacher_notes where teacher_id=t and student_id=p_id),'synced_at',statement_timestamp());
end $$;
create function public.list_teacher_secretaries(p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; n bigint; begin
 if p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
 select count(*) into n from public.secretaries where teacher_id=t;
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
  select s.id,s.name,s.email,s.phone,s.status,
   (select jsonb_build_object('id',id,'status',status,'requested_at',requested_at,'handled_at',handled_at)
    from public.secretary_removal_requests where teacher_id=t and secretary_id=s.id order by requested_at desc,id desc limit 1) as removal_request
  from public.secretaries s where s.teacher_id=t and (p_cursor is null or s.id>p_cursor) order by s.id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('total_count',n);
end $$;
create function public.list_teacher_notifications(p_cursor uuid default null,p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); result jsonb; n bigint; unread bigint; begin
 if p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
 select count(*),count(*) filter(where read_at is null) into n,unread from public.notifications
  where teacher_id=t and recipient_id=auth.uid();
 -- Allowlist payload identifiers only. No untrusted arbitrary message/PII rendering.
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
  select id,type,created_at,read_at,jsonb_strip_nulls(jsonb_build_object(
   'session_id',payload->'session_id','payment_id',payload->'payment_id','request_id',payload->'request_id')) as payload
  from public.notifications where teacher_id=t and recipient_id=auth.uid() and (p_cursor is null or id>p_cursor)
  order by id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('total_count',n,'unread_count',unread);
end $$;
revoke all on function public.get_teacher_student_note(uuid),public.list_teacher_secretaries(uuid,integer),
 public.list_teacher_notifications(uuid,integer) from public,anon;
grant execute on function public.get_teacher_student_note(uuid),public.list_teacher_secretaries(uuid,integer),
 public.list_teacher_notifications(uuid,integer) to authenticated;
