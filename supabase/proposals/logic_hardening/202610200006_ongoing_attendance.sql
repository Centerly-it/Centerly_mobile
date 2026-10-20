-- LOCAL PROPOSAL ONLY. Current session marks, not physical occupancy.
create or replace function public.get_teacher_overview(p_date date default (now() at time zone 'Africa/Cairo')::date)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); v_base jsonb;
begin
  v_base:=public.get_teacher_dashboard(p_date);
  return v_base || jsonb_build_object('attendance_scope','ongoing_sessions',
    'attendance_synced_at',statement_timestamp(),'attendance_counts',(
    select jsonb_build_object(
      'present',count(*) filter(where a.status='present'),
      'absent',count(*) filter(where a.status='absent'),
      'excused',count(*) filter(where a.status='excused'),
      'not_marked',count(*) filter(where a.status='not_marked'))
    from public.attendance a join public.sessions s
      on s.id=a.session_id and s.teacher_id=a.teacher_id
    where a.teacher_id=v_tenant and s.starts_at<=statement_timestamp()
      and s.ends_at>statement_timestamp() and s.status<>'cancelled'));
end $$;

revoke all on function public.get_teacher_overview(date) from public,anon;
grant execute on function public.get_teacher_overview(date) to authenticated;
create index teacher_current_sessions on public.sessions(teacher_id,ends_at,starts_at)
 include(id) where status<>'cancelled';
