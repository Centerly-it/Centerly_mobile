-- Additive: existing groups and all issued financial values retain their meaning.
alter table public.groups add column billing_mode text not null default 'monthly' check(billing_mode in ('monthly','per_session')),
 add column session_fee_egp numeric(12,2) not null default 0 check(session_fee_egp>=0 and session_fee_egp<=9999999999.99);
alter table public.sessions add column billing_mode text;
alter table public.sessions add constraint session_billing_mode_check check(billing_mode is null or billing_mode in ('monthly','per_session'));
alter table public.invoices add column billing_origin text not null default 'legacy',
 add column attendance_target_egp numeric(12,2) check(attendance_target_egp>=0),
 add column attendance_settlement_required boolean not null default false,
 add column attendance_reviewed_at timestamptz;
create unique index one_initial_session_group_materials on public.invoices(teacher_id,group_id,student_id)
 where billing_origin='session_group_materials';
create function private.billing_lock() returns void language plpgsql security definer set search_path='' as $$
begin perform pg_advisory_xact_lock(hashtextextended(private.require_actor()::text||'session_billing',0));end $$;
revoke all on function private.billing_lock() from public,anon,authenticated;
create function private.group_billing_guard() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.billing_mode<>old.billing_mode and not exists(select 1 from public.audit_events a
  where a.teacher_id=old.teacher_id and a.actor_id=auth.uid() and a.entity_type='billing_group_create'
   and a.entity_id=old.id and a.metadata->>'transaction_id'=txid_current()::text)
 then raise exception 'CONFLICT';end if;
 if new.session_fee_egp<>old.session_fee_egp and not exists(select 1 from public.audit_events a where a.teacher_id=old.teacher_id and a.actor_id=auth.uid() and a.entity_type in ('billing_group_create','session_tariff') and a.metadata->>'transaction_id'=txid_current()::text and (a.entity_id=old.id or a.metadata->>'group_id'=old.id::text)) then raise exception 'CONFLICT';end if;
 if new.billing_mode='per_session' and new.monthly_fee_egp<>0 then raise exception 'VALIDATION_ERROR';end if;
 return new;
end $$;
create trigger group_billing_guard before update on public.groups for each row execute function private.group_billing_guard();
revoke all on function private.group_billing_guard() from public,anon,authenticated;
create function private.session_billing_snapshot() returns trigger language plpgsql security definer set search_path='' as $$
declare g public.groups;
begin
 select * into g from public.groups where id=new.group_id and teacher_id=new.teacher_id;
 if not found then raise exception 'NOT_FOUND';end if;
 new.billing_mode:=g.billing_mode;
 if g.billing_mode='per_session' and new.fee_egp=0 then new.fee_egp:=g.session_fee_egp;end if;
 return new;
end $$;
create trigger session_billing_snapshot before insert on public.sessions for each row execute function private.session_billing_snapshot();
revoke all on function private.session_billing_snapshot() from public,anon,authenticated;

create index eligible_session_billing_enrollments on public.sessions(teacher_id,group_id,ends_at) where billing_mode='per_session' and status<>'cancelled';
