// Disposable PostgreSQL role/concurrency tests. No hosted account mutations.
import assert from 'node:assert/strict';
import {completionContext,ids} from './completion_context.mjs';
const {pg,a,b,s,call}=await completionContext();let checks=0;
const eq=(x,y)=>{assert.deepEqual(x,y);checks++;};
const deny=async(c,args,message)=>{await assert.rejects(call(c,'public.reactivate_secretary($1)',args),e=>!message||e.message.includes(message));checks++;};
try {
 const anon=await pg.connect();await anon.query('set role anon');
 await deny(anon,[ids.secretary]);await deny(s,[ids.secretary],'FORBIDDEN_ROLE');
 await deny(b,[ids.secretary],'NOT_FOUND');await deny(a,[ids.other],'NOT_FOUND');
 const history=async()=>(await pg.admin.query(`select
 (select jsonb_agg(to_jsonb(p) order by id) from public.payments p) payments,
 (select jsonb_agg(to_jsonb(a) order by id) from public.attendance a) attendance,
 (select jsonb_agg(to_jsonb(i) order by id) from public.invoices i) invoices`)).rows;
 const before=await history();await call(a,'public.deactivate_secretary($1)',[ids.secretary]);
 await pg.admin.query("update public.teachers set secretary_seats=0 where id=$1",[ids.teacher]);
 await deny(a,[ids.secretary],'CONFLICT');
 await pg.admin.query("update public.teachers set secretary_seats=1,subscription_status='inactive' where id=$1",[ids.teacher]);
 await deny(a,[ids.secretary],'SUBSCRIPTION_INACTIVE');
 await pg.admin.query("update public.teachers set subscription_status='active' where id=$1",[ids.teacher]);
 await pg.admin.query(`create function private.fail_reactivation_test() returns trigger language plpgsql as $$
 begin if new.action='reactivated' then raise exception 'audit test failure'; end if; return new; end $$;
 create trigger fail_reactivation_test before insert on public.audit_events for each row execute function private.fail_reactivation_test()`);
 await deny(a,[ids.secretary],'audit test failure');
 eq((await pg.admin.query('select status from public.secretaries where id=$1',[ids.secretary])).rows[0].status,'inactive');
 await pg.admin.query('drop trigger fail_reactivation_test on public.audit_events;drop function private.fail_reactivation_test()');
 const second=await pg.connect(ids.teacher);
 eq(await Promise.all([a,second].map(c=>call(c,'public.reactivate_secretary($1)',[ids.secretary]))),[ids.secretary,ids.secretary]);
 eq((await pg.admin.query("select count(*)::int n from public.audit_events where action='reactivated'")).rows[0].n,1);
 eq((await call(s,'public.get_current_profile()')).role,'secretary');
 eq((await call(a,'public.list_teacher_secretaries()')).rows.find(r=>r.id===ids.secretary).status,'active');
 eq(await history(),before);
 // Two different inactive secretaries compete for a single available seat.
 await call(a,'public.deactivate_secretary($1)',[ids.secretary]);
 const extra='20000000-0000-0000-0000-000000000099';
 await pg.admin.query("insert into auth.users(id) values($1)",[extra]);
 await pg.admin.query("insert into public.secretaries(id,teacher_id,name,email,status) values($1,$2,'Seat test','seat@example.invalid','inactive')",[extra,ids.teacher]);
 const results=await Promise.allSettled([call(a,'public.reactivate_secretary($1)',[ids.secretary]),call(second,'public.reactivate_secretary($1)',[extra])]);
 eq(results.filter(r=>r.status==='fulfilled').length,1);
 eq((await pg.admin.query("select count(*)::int n from public.secretaries where teacher_id=$1 and status='active'",[ids.teacher])).rows[0].n,1);
 console.log(JSON.stringify({pass:true,checks,backend:'native PostgreSQL role simulation',hosted:false}));
}finally{await pg.close();}
