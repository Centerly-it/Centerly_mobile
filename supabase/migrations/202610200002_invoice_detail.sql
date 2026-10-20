-- LOCAL PROPOSAL ONLY: creator is attribution, never an assigned debtor owner.
create function public.get_teacher_invoice_detail(p_id uuid,p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('teacher'); header jsonb; result jsonb;
begin
 if p_id is null or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR'; end if;
 select jsonb_build_object('id',i.id,'invoice_number',i.invoice_number,'amount_egp',i.amount_egp::text,
  'student_id',i.student_id,'student_name',s.full_name,'group_id',i.group_id,'group_name',g.name,
  'due_on',i.due_on,'status',i.status,'void_reason',i.void_reason,
  'created_by',i.created_by,'created_by_name',a.name,'created_by_status',a.status,'created_at',i.created_at,
  'net_paid_egp',coalesce(p.paid,0)::numeric(20,2)::text,
  'outstanding_egp',(case when i.status='void' then 0 else i.amount_egp-coalesce(p.paid,0) end)::numeric(20,2)::text)
 into header from public.invoices i
 join public.students s on s.id=i.student_id and s.teacher_id=t
 left join public.groups g on g.id=i.group_id and g.teacher_id=t
 left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
 left join lateral (select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid
  from public.payments where teacher_id=t and invoice_id=i.id) p on true
 where i.id=p_id and i.teacher_id=t;
 if not found then raise exception 'NOT_FOUND'; end if;
 select coalesce(jsonb_agg(to_jsonb(r) order by r.id),'[]') into result from (
  select p.id,p.invoice_id,p.receipt_number,p.amount_egp::text,
   (case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)::numeric(20,2)::text signed_amount_egp,
   p.collected_by,a.name collected_by_name,a.status collected_by_status,p.collected_at,p.method,p.reason,p.reversal_of,
   o.receipt_number original_receipt_number,o.collected_by original_collected_by,
   oa.name original_collected_by_name,o.amount_egp::text original_amount_egp,
   rev.id reversed_by,rev.receipt_number correction_receipt_number
  from public.payments p
  left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
  left join public.payments o on o.id=p.reversal_of and o.teacher_id=t and o.invoice_id=p_id
  left join public.secretaries oa on oa.id=o.collected_by and oa.teacher_id=t
  left join public.payments rev on rev.reversal_of=p.id and rev.teacher_id=t and rev.invoice_id=p_id
  where p.teacher_id=t and p.invoice_id=p_id and (p_cursor is null or p.id>p_cursor)
  order by p.id limit p_limit+1) r;
 return private.teacher_page(result,p_limit)||jsonb_build_object('invoice',header,
  'total_count',(select count(*) from public.payments where teacher_id=t and invoice_id=p_id));
end $$;
revoke all on function public.get_teacher_invoice_detail(uuid,uuid,integer) from public,anon;
grant execute on function public.get_teacher_invoice_detail(uuid,uuid,integer) to authenticated;
