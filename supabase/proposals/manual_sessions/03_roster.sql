create function private.sync_manual_session(p_id uuid) returns void
language plpgsql security definer set search_path='' as $$
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
end $$;
revoke all on function private.sync_manual_session(uuid) from public,anon,authenticated;

create function private.enrollment_manual_sessions() returns trigger
language plpgsql security definer set search_path='' as $$
declare s record;
begin
 for s in select id from public.sessions where teacher_id=new.teacher_id and group_id=new.group_id
  and schedule_id is null and status<>'cancelled' and ends_at>=clock_timestamp() order by id loop
  perform private.sync_manual_session(s.id);
 end loop;
 return new;
end $$;
revoke all on function private.enrollment_manual_sessions() from public,anon,authenticated;
create trigger enrollment_manual_sessions after insert on public.group_enrollments
 for each row when(new.status='active') execute function private.enrollment_manual_sessions();
