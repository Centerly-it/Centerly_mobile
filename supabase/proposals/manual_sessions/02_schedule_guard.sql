create or replace function private.schedule_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 perform 1 from public.groups where id=new.group_id and teacher_id=new.teacher_id and archived_at is null for update;
 if not found then raise exception 'CONFLICT'; end if;
 if exists(select 1 from public.group_schedules s where s.group_id=new.group_id and s.retired_at is null and s.id<>new.id
 and exists(select 1 from generate_series(-1,1) shift where numrange(s.weekday*86400+extract(epoch from s.local_start_time),s.weekday*86400+extract(epoch from s.local_end_time)+case when s.local_end_time<s.local_start_time then 86400 else 0 end,'[)') && numrange(new.weekday*86400+extract(epoch from new.local_start_time)+shift*604800,new.weekday*86400+extract(epoch from new.local_end_time)+case when new.local_end_time<new.local_start_time then 86400 else 0 end+shift*604800,'[)'))
 and daterange(s.effective_from,s.effective_to,'[]') && daterange(new.effective_from,new.effective_to,'[]')) then raise exception 'CONFLICT'; end if;
 return new;
end $$;
