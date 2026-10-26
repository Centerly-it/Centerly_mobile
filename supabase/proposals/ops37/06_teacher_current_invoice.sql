create function public.get_teacher_current_invoice(p_id uuid,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher');header jsonb;result jsonb;n bigint;
begin
 if p_id is null or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR';end if;
 header:=public.get_teacher_invoice_detail(p_id,null,1)->'invoice';
 with filtered as materialized (
  select p.id,p.invoice_id,p.receipt_number,p.amount_egp::text amount_egp,p.amount_egp::text signed_amount_egp,
   p.method,p.collected_at,p.collected_by,a.name collected_by_name,s.full_name student_name
  from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
  join public.students s on s.id=i.student_id and s.teacher_id=t
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  where p.teacher_id=t and p.invoice_id=p_id and p.reversal_of is null
   and not exists(select 1 from public.payments rev where rev.teacher_id=t and rev.reversal_of=p.id)
 ), page as(select * from filtered where p_cursor is null or id>p_cursor order by id limit p_limit+1)
 select (select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') from page r),count(*) into result,n from filtered;
 return private.teacher_page(result,p_limit)||jsonb_build_object('invoice',header,'total_count',n);
end $$;
revoke all on function public.get_teacher_current_invoice(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_current_invoice(uuid,uuid,integer) to authenticated;
