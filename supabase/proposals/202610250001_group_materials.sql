-- Atomic, retry-safe additional materials invoices for current group members.
create function public.secretary_group_materials_preview(p_group uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary'); result jsonb;
begin
 if not exists(select 1 from public.groups where id=p_group and teacher_id=t and archived_at is null)
 then raise exception 'NOT_FOUND';end if;
 select coalesce(jsonb_agg(jsonb_build_object('id',s.id,'name',s.full_name) order by s.id),'[]') into result
 from public.group_enrollments e join public.students s on s.id=e.student_id and s.teacher_id=t
 where e.teacher_id=t and e.group_id=p_group and e.status='active' and s.archived_at is null;
 return result;
end $$;
create function public.secretary_add_group_materials(p_group uuid,p_request uuid,p_title text,
 p_amount numeric,p_due date,p_students uuid[]) returns jsonb
language plpgsql security definer set search_path='' as $$
declare t uuid:=private.require_actor('secretary');request jsonb;a public.audit_events;
 members uuid[];expected uuid[];s uuid;i uuid;invoices jsonb:='[]';result jsonb;
begin
 if p_request is null or p_group is null or nullif(trim(p_title),'') is null or length(p_title)>100
 or p_amount is null or p_amount<=0 or p_amount>9999999999.99 or p_amount<>round(p_amount,2)
 or p_due is null or p_students is null or cardinality(p_students)=0
 or array_position(p_students,null) is not null then raise exception 'VALIDATION_ERROR';end if;
 select array_agg(x order by x) into expected from unnest(p_students) x;
 if cardinality(expected)<>(select count(distinct x) from unnest(expected) x) then raise exception 'VALIDATION_ERROR';end if;
 request:=jsonb_build_object('group',p_group,'title',trim(p_title),'amount',p_amount::text,'due',p_due,'students',expected);
 perform pg_advisory_xact_lock(hashtextextended(t::text||p_request::text,0));
 select * into a from public.audit_events where teacher_id=t and entity_type='group_materials' and entity_id=p_request;
 if found then
  if a.metadata->'request'<>request then raise exception 'CONFLICT';end if;
  return a.metadata->'result';
 end if;
 perform 1 from public.groups where id=p_group and teacher_id=t and archived_at is null for update;
 if not found then raise exception 'NOT_FOUND';end if;
 -- Freeze the admitted roster while validating the preview and issuing invoices.
 perform 1 from public.group_enrollments where teacher_id=t and group_id=p_group order by id for update;
 perform 1 from public.students where teacher_id=t and id in
 (select student_id from public.group_enrollments where teacher_id=t and group_id=p_group) order by id for update;
 select coalesce(array_agg(st.id order by st.id),'{}') into members
 from public.group_enrollments e join public.students st on st.id=e.student_id and st.teacher_id=t
 where e.teacher_id=t and e.group_id=p_group and e.status='active' and st.archived_at is null;
 if members<>expected then raise exception 'CONFLICT';end if;
 foreach s in array members loop
  i:=public.create_invoice(s,p_amount,p_due,'GMAT-'||p_request||'-'||s||' | '||trim(p_title),p_group);
  invoices:=invoices||jsonb_build_array(i);
 end loop;
 result:=jsonb_build_object('invoice_ids',invoices,'count',cardinality(members),'total_egp',(p_amount*cardinality(members))::text);
 insert into public.audit_events(teacher_id,actor_id,entity_type,entity_id,action,metadata)
 values(t,auth.uid(),'group_materials',p_request,'created',jsonb_build_object('request',request,'result',result));
 return result;
end $$;
revoke all on function public.secretary_group_materials_preview(uuid),
 public.secretary_add_group_materials(uuid,uuid,text,numeric,date,uuid[]) from public,anon;
grant execute on function public.secretary_group_materials_preview(uuid),
 public.secretary_add_group_materials(uuid,uuid,text,numeric,date,uuid[]) to authenticated;
