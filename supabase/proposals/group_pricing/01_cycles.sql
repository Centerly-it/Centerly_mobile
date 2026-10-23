create function private.billing_cycle_on(anchor date,on_date date) returns date
language plpgsql immutable set search_path='' as $$
declare d date;
begin
 d:=least((date_trunc('month',on_date)+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',on_date)+interval '1 month - 1 day')::date);
 if d>on_date then d:=least((date_trunc('month',on_date)-interval '1 month'+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',on_date)-interval '1 day')::date);end if;
 return d;
end $$;
create function private.billing_cycle_next(anchor date,previous date) returns date
language sql immutable set search_path='' as $$
 select least((date_trunc('month',previous)+interval '1 month'+make_interval(days=>extract(day from anchor)::int-1))::date,
  (date_trunc('month',previous)+interval '2 months - 1 day')::date)
$$;
revoke all on function private.billing_cycle_on(date,date),private.billing_cycle_next(date,date) from public,anon,authenticated;

