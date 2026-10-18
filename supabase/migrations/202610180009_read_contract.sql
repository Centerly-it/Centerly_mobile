create function public.list_students(p_search text default null,p_group_id uuid default null,p_cursor uuid default null,p_limit integer default 30)
returns setof public.students language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor(); begin
  if p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
  return query select s.* from public.students s where s.teacher_id=v_tenant and s.archived_at is null
    and (p_cursor is null or s.id>p_cursor)
    and (nullif(trim(p_search),'') is null or s.full_name ilike '%'||p_search||'%')
    and (p_group_id is null or exists(select 1 from public.group_enrollments e
      where e.teacher_id=v_tenant and e.student_id=s.id and e.group_id=p_group_id and e.status='active'))
    order by s.id limit p_limit;
end $$;
create function public.list_sessions(p_from date,p_to date,p_group_id uuid default null)
returns setof public.sessions language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor(); begin
  if p_from is null or p_to is null or p_to<p_from or p_to-p_from>61 then raise exception 'VALIDATION_ERROR'; end if;
  return query select s.* from public.sessions s where s.teacher_id=v_tenant
    and s.local_date between p_from and p_to and (p_group_id is null or s.group_id=p_group_id)
    order by s.starts_at,s.id;
end $$;
create function public.get_teacher_dashboard(p_date date) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare v_tenant uuid:=private.require_actor('teacher'); begin
  if p_date is null then raise exception 'VALIDATION_ERROR'; end if;
  return jsonb_build_object('date',p_date,
    'total_students',(select count(*) from public.students where teacher_id=v_tenant and archived_at is null),
    'total_groups',(select count(*) from public.groups where teacher_id=v_tenant and archived_at is null),
    'today_sessions',(select coalesce(jsonb_agg(to_jsonb(s) order by s.starts_at),'[]')
      from public.sessions s where teacher_id=v_tenant and local_date=p_date),
    'collected_egp',(select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0)
      from public.payments where teacher_id=v_tenant and collected_at>=p_date::timestamp at time zone 'Africa/Cairo'
      and collected_at<(p_date+1)::timestamp at time zone 'Africa/Cairo'),
    'outstanding_egp',(select coalesce(sum(i.amount_egp-coalesce(p.paid,0)),0) from public.invoices i
      left join (select invoice_id,sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
        from public.payments where teacher_id=v_tenant group by invoice_id) p on p.invoice_id=i.id
      where i.teacher_id=v_tenant and i.status<>'void'));
end $$;
revoke all on function public.list_students(text,uuid,uuid,integer),public.list_sessions(date,date,uuid),
  public.get_teacher_dashboard(date) from public,anon;
grant execute on function public.list_students(text,uuid,uuid,integer),public.list_sessions(date,date,uuid),
  public.get_teacher_dashboard(date) to authenticated;
