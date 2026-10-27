// Disposable native PostgreSQL role simulation, never hosted fixture mutations.
import assert from 'node:assert/strict';
import {completionContext,ids} from './completion_context.mjs';
const {pg,a,b,s,call}=await completionContext();
let checks=0;
const equal=(x,y)=>{assert.deepEqual(x,y);checks++;};
const deny=async(c,sql,args=[],message)=>{
 await assert.rejects(call(c,sql,args),e=>!message||e.message.includes(message));checks++;
};
try {
 const anonymous=await pg.connect();await anonymous.query('set role anon');
 await deny(anonymous,'public.deactivate_secretary($1)',[ids.secretary]);
 await deny(s,'public.deactivate_secretary($1)',[ids.secretary],'FORBIDDEN_ROLE');
 await deny(b,'public.deactivate_secretary($1)',[ids.secretary],'NOT_FOUND');
 await deny(a,'public.deactivate_secretary($1)',[ids.other],'NOT_FOUND');
 const request=await call(a,'public.request_secretary_removal($1)',[ids.secretary]);
 const history=async()=> (await pg.admin.query(`select
 (select jsonb_agg(to_jsonb(p) order by id) from public.payments p) payments,
 (select jsonb_agg(to_jsonb(i) order by id) from public.invoices i) invoices,
 (select jsonb_agg(to_jsonb(a) order by id) from public.attendance a) attendance,
 (select jsonb_agg(to_jsonb(e) order by id) from public.exams e) exams,
 (select jsonb_agg(to_jsonb(a) order by id) from public.audit_events a where action<>'deactivated') audit`)).rows[0];
 const before=await history();
 // Audit failure must roll back status and pending-request handling atomically.
 await pg.admin.query(`create function private.fail_deactivation_test() returns trigger language plpgsql as $$
 begin if new.action='deactivated' then raise exception 'test audit failure'; end if; return new; end $$;
 create trigger fail_deactivation_test before insert on public.audit_events for each row execute function private.fail_deactivation_test()`);
 await deny(a,'public.deactivate_secretary($1)',[ids.secretary],'test audit failure');
 equal(await call(s,'public.get_current_profile()').then(v=>v.role),'secretary');
 equal((await pg.admin.query('select status from public.secretary_removal_requests where id=$1',[request])).rows[0].status,'pending');
 await pg.admin.query('drop trigger fail_deactivation_test on public.audit_events; drop function private.fail_deactivation_test()');
 const second=await pg.connect(ids.teacher);
 equal(await Promise.all([a,second].map(c=>call(c,'public.deactivate_secretary($1)',[ids.secretary]))),[ids.secretary,ids.secretary]);
 equal((await pg.admin.query("select count(*)::int n from public.audit_events where action='deactivated'")).rows[0].n,1);
 equal((await pg.admin.query('select status,handled_at is not null handled from public.secretary_removal_requests where id=$1',[request])).rows[0],{status:'handled',handled:true});
 await deny(s,'public.get_current_profile()',[],'ACCOUNT_INACTIVE');
 await deny(s,'public.secretary_dashboard()',[],'ACCOUNT_INACTIVE');
 await deny(s,'public.secretary_set_attendance($1,$2,\'present\')',[ids.session,ids.student],'ACCOUNT_INACTIVE');
 await deny(s,'public.record_payment($1,1,\'cash\',gen_random_uuid())',['00000000-0000-0000-0000-000000000001'],'ACCOUNT_INACTIVE');
 equal((await s.query('select count(*)::int n from public.students')).rows[0].n,0);
 equal((await s.query('select count(*)::int n from public.payments')).rows[0].n,0);
 equal((await call(a,'public.list_teacher_secretaries()')).rows.find(r=>r.id===ids.secretary).status,'inactive');
 equal(await history(),before);
 equal((await pg.admin.query('select count(*)::int n from auth.users where id=$1',[ids.secretary])).rows[0].n,1);
 console.log(JSON.stringify({pass:true,checks,backend:'native PostgreSQL role simulation',hosted:false}));
}finally{await pg.close();}
