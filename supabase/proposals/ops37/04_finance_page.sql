create function private.normalized_student_name(value text) returns text
language sql immutable set search_path='' as $$
 select lower(trim(regexp_replace(translate(normalize(coalesce(value,''),NFKC),'أإآى','اااي'),'[ً-ٟـ]','','g')))
$$;
revoke all on function private.normalized_student_name(text) from public,anon,authenticated;

create function public.secretary_finance_page(p_entity text,p_filters jsonb default '{}',p_search text default '',p_cursor uuid default null,p_limit integer default 30)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');result jsonb;stats jsonb;n bigint;k text;allowed text[];needle text;
begin
 if p_entity is null or p_entity not in('invoices','payments') or p_filters is null or jsonb_typeof(p_filters)<>'object'
  or p_search is null or length(p_search)>100 or p_limit is null or p_limit not between 1 and 100 then raise exception 'VALIDATION_ERROR';end if;
 allowed:=case when p_entity='invoices' then array['id','student_id','group_id','status','from','to']
  else array['id','student_id','group_id','invoice_id','idempotency_key','method','from','to'] end;
 for k in select jsonb_object_keys(p_filters) loop if not k=any(allowed) then raise exception 'VALIDATION_ERROR';end if;end loop;
 if (p_filters ? 'from')<>(p_filters ? 'to') or (p_filters ? 'from' and ((p_filters->>'to')::date<(p_filters->>'from')::date or (p_filters->>'to')::date-(p_filters->>'from')::date>366)) then raise exception 'VALIDATION_ERROR';end if;
 needle:=private.normalized_student_name(p_search);
 if p_entity='invoices' then
  with filtered as materialized (
   select i.*,s.full_name student_name,g.name group_name,a.name creator_name,
    coalesce(p.paid,0)::numeric(20,2)::text paid_egp,
    (case when i.status='void' then 0 else i.amount_egp-coalesce(p.paid,0) end)::numeric(20,2)::text balance_egp
   from public.invoices i join public.students s on s.id=i.student_id and s.teacher_id=t
   left join public.groups g on g.id=i.group_id and g.teacher_id=t
   left join public.secretaries a on a.id=i.created_by and a.teacher_id=t
   left join lateral(select sum(case when reversal_of is null then amount_egp else -amount_egp end) paid from public.payments where teacher_id=t and invoice_id=i.id)p on true
   where i.teacher_id=t and to_jsonb(i) @> (p_filters-'from'-'to')
    and (needle='' or strpos(private.normalized_student_name(s.full_name),needle)>0)
    and (not(p_filters ? 'from') or i.due_on between (p_filters->>'from')::date and (p_filters->>'to')::date)
  ), page as (
   select to_jsonb(f)||jsonb_build_object('amount_egp',f.amount_egp::text,'original_amount_egp',coalesce(f.initial_amount_egp,f.amount_egp)::text,
    'ledger_net_egp',f.paid_egp,'payable_balance_egp',f.balance_egp) v,f.id
   from filtered f where p_cursor is null or f.id>p_cursor order by f.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(v order by id),'[]') from page),count(*),
    jsonb_build_object('amount_egp',coalesce(sum(amount_egp) filter(where status<>'void'),0)::numeric(20,2)::text,
     'paid_egp',coalesce(sum(paid_egp::numeric) filter(where status<>'void'),0)::numeric(20,2)::text,
     'balance_egp',coalesce(sum(balance_egp::numeric),0)::numeric(20,2)::text)
   into result,n,stats from filtered;
 else
  with filtered as materialized (
   select p.*,i.student_id,s.full_name student_name,i.group_id,g.name group_name,a.name collector_name
   from public.payments p join public.invoices i on i.id=p.invoice_id and i.teacher_id=t
   join public.students s on s.id=i.student_id and s.teacher_id=t
   left join public.groups g on g.id=i.group_id and g.teacher_id=t
   left join public.secretaries a on a.id=p.collected_by and a.teacher_id=t
   where p.teacher_id=t and p.reversal_of is null and not exists(select 1 from public.payments rev where rev.teacher_id=t and rev.reversal_of=p.id)
    and (to_jsonb(p)||jsonb_build_object('student_id',i.student_id,'group_id',i.group_id)) @> (p_filters-'from'-'to')
    and (needle='' or strpos(private.normalized_student_name(s.full_name),needle)>0)
    and (not(p_filters ? 'from') or ((p.collected_at at time zone 'Africa/Cairo')::date between (p_filters->>'from')::date and (p_filters->>'to')::date))
  ), page as (
   select to_jsonb(f)||jsonb_build_object('amount_egp',f.amount_egp::text) v,f.id from filtered f
    where p_cursor is null or f.id>p_cursor order by f.id limit p_limit+1
  ) select (select coalesce(jsonb_agg(v order by id),'[]') from page),count(*),
   jsonb_build_object('amount_egp',coalesce(sum(amount_egp),0)::numeric(20,2)::text) into result,n,stats from filtered;
 end if;
 return private.teacher_page(result,p_limit)||jsonb_build_object('total_count',n,'summary',stats,
  'synced_at',statement_timestamp(),'server_date',(statement_timestamp() at time zone 'Africa/Cairo')::date);
end $$;
revoke all on function public.secretary_finance_page(text,jsonb,text,uuid,integer) from public,anon;
grant execute on function public.secretary_finance_page(text,jsonb,text,uuid,integer) to authenticated;
