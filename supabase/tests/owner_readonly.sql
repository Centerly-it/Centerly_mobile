-- Read-only synthetic actor checks. These do not establish SDK/password acceptance.
begin read only;
select set_config('centerly.teacher_a',(select id::text from auth.users where email='teacher-a@centerly.test'),true);
select set_config('centerly.teacher_b',(select id::text from auth.users where email='teacher-b@centerly.test'),true);
select set_config('centerly.secretary_a',(select id::text from auth.users where email='secretary-a@centerly.test'),true);
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('centerly.teacher_a'),true);
do $$ declare d jsonb; page jsonb; invoice_id uuid; begin
 if nullif(current_setting('centerly.teacher_a'),'') is null then raise exception 'SYNTHETIC_TEACHER_MISSING'; end if;
 if (select count(*) from public.teachers where id=current_setting('centerly.teacher_a')::uuid and nullif(btrim(name),'') is not null)<>1 then raise exception 'TRUSTED_NAME_UNAVAILABLE'; end if;
 d:=public.get_teacher_finance_overview(date_trunc('month',current_date)::date,(date_trunc('month',current_date)+interval '1 month - 1 day')::date);
 if (d->>'invoiced_egp')::numeric<>(d->>'paid_against_invoices_egp')::numeric+(d->>'outstanding_egp')::numeric then raise exception 'COHORT_MISMATCH'; end if;
 if (d->>'period_net_collected_egp')::numeric<>(d->>'gross_collected_egp')::numeric-(d->>'corrections_egp')::numeric then raise exception 'CASH_MISMATCH'; end if;
 page:=public.list_teacher_finance_dues(current_date-30,current_date+30,'all','',null,null,null,1);
 if jsonb_array_length(page->'rows')>1 then raise exception 'DUES_LIMIT'; end if;
 if (page->'summary'->>'invoiced_egp')::numeric<>(page->'summary'->>'net_paid_egp')::numeric+(page->'summary'->>'outstanding_egp')::numeric then raise exception 'FILTER_TOTAL_MISMATCH'; end if;
 invoice_id:=(page->'rows'->0->>'id')::uuid;
 if invoice_id is null then raise exception 'SYNTHETIC_INVOICE_MISSING'; end if;
 perform set_config('centerly.invoice',invoice_id::text,true);
 d:=public.get_teacher_invoice_detail(invoice_id,null,1);
 if d->'invoice'->>'id'<>invoice_id::text or jsonb_array_length(d->'rows')>1 then raise exception 'DETAIL_MISMATCH'; end if;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.teacher_b'),true);
do $$ begin
 if (select count(*) from public.teachers where id=current_setting('centerly.teacher_a')::uuid)<>0 then raise exception 'NAME_TENANT_LEAK'; end if;
 begin perform public.get_teacher_invoice_detail(current_setting('centerly.invoice')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'NOT_FOUND' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub',current_setting('centerly.secretary_a'),true);
do $$ begin
 begin perform public.get_teacher_finance_overview(current_date,current_date); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
 begin perform public.list_teacher_finance_dues(current_date,current_date); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
 begin perform public.get_teacher_invoice_detail(current_setting('centerly.invoice')::uuid); raise exception 'UNEXPECTED_ALLOW';
 exception when raise_exception then if sqlerrm<>'FORBIDDEN_ROLE' then raise; end if; end;
end $$;
select jsonb_build_object('pass',true,'assertions',13,'mode','read-only SQL synthetic actor checks; not password Auth') as owner_readonly;
commit;
