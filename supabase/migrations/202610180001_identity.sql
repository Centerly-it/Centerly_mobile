-- Canonical shared backend v6.1. Internal provisioning only; no signup trigger.
create schema if not exists private;
revoke all on schema private from public;
create table public.teachers (
  id uuid primary key references auth.users(id), name text not null,
  phone text, status text not null default 'active' check(status in ('active','inactive')),
  subscription_status text not null default 'inactive' check(subscription_status in ('active','inactive')),
  secretary_seats integer not null default 1 check(secretary_seats >= 0),
  created_at timestamptz not null default now()
);
create table public.secretaries (
  id uuid primary key references auth.users(id), teacher_id uuid not null references public.teachers(id),
  name text not null, phone text, email text not null,
  status text not null default 'active' check(status in ('active','inactive')),
  created_at timestamptz not null default now(), unique(teacher_id,id)
);
create function private.identity() returns table(tenant_id uuid, actor_role text)
language sql stable security definer set search_path = '' as $$
  select t.id, 'teacher'::text from public.teachers t
  where t.id = auth.uid() and t.status='active' and t.subscription_status='active'
  union all
  select t.id, 'secretary'::text from public.secretaries s
  join public.teachers t on t.id=s.teacher_id
  where s.id=auth.uid() and s.status='active' and t.status='active'
    and t.subscription_status='active'
$$;
create function private.tenant_id() returns uuid language sql stable security definer
set search_path = '' as $$ select tenant_id from private.identity() limit 1 $$;
create function private.actor_role() returns text language sql stable security definer
set search_path = '' as $$ select actor_role from private.identity() limit 1 $$;
create function private.require_actor(p_role text default null) returns uuid
language plpgsql stable security definer set search_path = '' as $$
declare v_tenant uuid; v_role text;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  select tenant_id,actor_role into v_tenant,v_role from private.identity();
  if v_tenant is null then
    if exists(select 1 from public.teachers t where t.status='active' and t.subscription_status='inactive'
      and (t.id=auth.uid() or exists(select 1 from public.secretaries s where s.id=auth.uid()
        and s.teacher_id=t.id and s.status='active'))) then raise exception 'SUBSCRIPTION_INACTIVE'; end if;
    raise exception 'ACCOUNT_INACTIVE';
  end if;
  if p_role is not null and v_role<>p_role then raise exception 'FORBIDDEN_ROLE'; end if;
  return v_tenant;
end $$;
create function public.get_current_profile() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_tenant uuid := private.require_actor();
begin
  return jsonb_build_object('id',auth.uid(),'teacher_id',v_tenant,'role',private.actor_role());
end $$;
-- An Auth UID cannot occupy both roles, even through trusted provisioning mistakes.
create function private.exclusive_role() returns trigger language plpgsql
set search_path = '' as $$ begin
  if (tg_table_name='teachers' and exists(select 1 from public.secretaries where id=new.id))
    or (tg_table_name='secretaries' and exists(select 1 from public.teachers where id=new.id))
  then raise exception 'CONFLICT'; end if;
  return new;
end $$;
create trigger exclusive_teacher before insert or update on public.teachers
for each row execute function private.exclusive_role();
create trigger exclusive_secretary before insert or update on public.secretaries
for each row execute function private.exclusive_role();
