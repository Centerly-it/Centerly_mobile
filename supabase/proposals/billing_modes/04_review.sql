create function public.get_session_billing(p_session_id uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor();s public.sessions;rows jsonb;v text;
begin
 select * into s from public.sessions where id=p_session_id and teacher_id=t;
 if not found then raise exception 'NOT_FOUND';end if;
 with details as (
  select a.id,a.student_id,st.full_name student_name,a.status attendance_status,a.updated_at attendance_updated_at,
   i.id invoice_id,i.status invoice_status,i.amount_egp::text amount_egp,coalesce(i.initial_amount_egp,s.fee_egp)::text fee_egp,
   i.attendance_reviewed_at,i.attendance_target_egp::text attendance_target_egp,i.attendance_settlement_required,
   coalesce(p.paid,0)::numeric(20,2)::text paid_egp,coalesce(p.signature,'') payment_version,
   (case when s.status<>'cancelled' and a.status='present' and (st.archived_at is null or st.archived_at>=s.ends_at) and exists(select 1 from public.groups g where g.id=s.group_id and g.teacher_id=t and (g.archived_at is null or g.archived_at>=s.ends_at)) and exists(select 1 from public.group_enrollments e where e.teacher_id=t and e.group_id=s.group_id and e.student_id=a.student_id and e.joined_at<=s.ends_at and (e.left_at is null or e.left_at>s.starts_at)) and i.status is distinct from 'void' then coalesce(i.initial_amount_egp,s.fee_egp) else 0 end)::numeric(20,2) target
  from public.attendance a join public.students st on st.id=a.student_id and st.teacher_id=t
  left join public.invoices i on i.teacher_id=t and i.session_id=s.id and i.student_id=a.student_id
  left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid,string_agg(id::text,',' order by id) signature from public.payments where teacher_id=t and invoice_id=i.id) p on true
  where a.teacher_id=t and a.session_id=s.id
 )select coalesce(jsonb_agg(to_jsonb(d)-'target'||jsonb_build_object('target_egp',target::text,
   'proposed_amount_egp',greatest(target,paid_egp::numeric)::numeric(20,2)::text,
   'settlement_required',paid_egp::numeric>target) order by d.student_id),'[]') into rows from details d;
 v:=md5(jsonb_build_object('session',s.id,'status',s.status,'fee',s.fee_egp,'rows',rows)::text);
 return jsonb_build_object('session_id',s.id,'billing_mode',coalesce(s.billing_mode,'monthly'),'fee_egp',s.fee_egp::text,'status',s.status,'version',v,'rows',rows);
end $$;
revoke all on function public.get_session_billing(uuid) from public,anon;
grant execute on function public.get_session_billing(uuid) to authenticated;

create function private.billing_financial_authorized(p_invoice uuid) returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.audit_events a join public.invoices i on i.id=p_invoice and i.teacher_id=a.teacher_id
 where a.actor_id=auth.uid() and a.entity_type in ('session_billing_review_intent','session_billing_settlement')
  and a.metadata->>'transaction_id'=txid_current()::text and a.metadata->>'session_id'=i.session_id::text)
$$;
revoke all on function private.billing_financial_authorized(uuid) from public,anon,authenticated;

create function public.secretary_review_session_billing(p_session_id uuid,p_expected_version text,p_request_id uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');a public.audit_events;before_value jsonb;result jsonb;r jsonb;
 request jsonb:=jsonb_build_object('session',p_session_id,'version',p_expected_version);
begin
 if p_session_id is null or p_expected_version is null or p_request_id is null then raise exception 'VALIDATION_ERROR';end if;
 perform private.billing_lock();
 select * into a from public.audit_events where teacher_id=t and entity_type='session_billing_review' and entity_id=p_request_id;
 if found then if a.metadata->'request' is distinct from request then raise exception 'CONFLICT';end if;return a.metadata->'result';end if;
 perform 1 from public.sessions where id=p_session_id and teacher_id=t for update;
 before_value:=public.get_session_billing(p_session_id);
 if before_value->>'billing_mode'<>'per_session' then raise exception 'VALIDATION_ERROR';end if;
 if before_value->>'version'<>p_expected_version then raise exception 'CONFLICT';end if;
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'session_billing_review_intent',p_request_id,'reviewing',jsonb_build_object('session_id',p_session_id,'transaction_id',txid_current()::text,'request',request,'before',before_value));
 for r in select value from jsonb_array_elements(before_value->'rows') loop
  if r->>'invoice_id' is not null and r->>'invoice_status'<>'void' then
   update public.invoices set amount_egp=(r->>'proposed_amount_egp')::numeric,
    attendance_target_egp=(r->>'target_egp')::numeric,attendance_settlement_required=(r->>'settlement_required')::boolean,
    attendance_reviewed_at=clock_timestamp(),status=case when (r->>'proposed_amount_egp')::numeric=(r->>'paid_egp')::numeric then 'paid' when (r->>'paid_egp')::numeric=0 then 'due' else 'partially_paid' end
   where teacher_id=t and id=(r->>'invoice_id')::uuid;
  end if;
 end loop;
 result:=public.get_session_billing(p_session_id);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata) values(t,auth.uid(),'session_billing_review',p_request_id,'reviewed',jsonb_build_object('request',request,'result',result));
 return result;
end $$;
revoke all on function public.secretary_review_session_billing(uuid,text,uuid) from public,anon;
grant execute on function public.secretary_review_session_billing(uuid,text,uuid) to authenticated;

create function private.issued_session_billing_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if old.billing_origin='group_session' and (new.session_id,new.billing_origin,new.initial_amount_egp,new.teacher_id,new.student_id,new.group_id)
  is distinct from (old.session_id,old.billing_origin,old.initial_amount_egp,old.teacher_id,old.student_id,old.group_id) then raise exception 'CONFLICT';end if;
 return new;
end $$;
create trigger issued_session_billing_guard before update on public.invoices for each row execute function private.issued_session_billing_guard();
revoke all on function private.issued_session_billing_guard() from public,anon,authenticated;

create function public.get_teacher_session_billing(p_session_id uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare data jsonb;summary jsonb;
begin
 perform private.require_actor('teacher');data:=public.get_session_billing(p_session_id);
 select jsonb_build_object('charged_egp',coalesce(sum(coalesce(value->>'amount_egp','0')::numeric),0)::numeric(20,2)::text,
 'paid_egp',coalesce(sum((value->>'paid_egp')::numeric),0)::numeric(20,2)::text,
 'settlement_count',count(*) filter(where (value->>'attendance_settlement_required')::boolean)) into summary from jsonb_array_elements(data->'rows');
 return (data-'rows')||jsonb_build_object('summary',summary);
end $$;
revoke all on function public.get_teacher_session_billing(uuid) from public,anon;
grant execute on function public.get_teacher_session_billing(uuid) to authenticated;
