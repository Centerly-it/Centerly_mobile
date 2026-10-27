// Manual administrator subscription suspension: disposable SQL-role tests only.
import assert from 'node:assert/strict';
import {completionContext,ids} from './completion_context.mjs';
const {pg,a,b,s,call}=await completionContext();
let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const deny=async(c,sql,args=[])=>{await assert.rejects(call(c,sql,args),e=>e.message.includes('SUBSCRIPTION_INACTIVE'));checks++;};
try {
 const historySql=`select (select jsonb_agg(to_jsonb(p) order by id) from public.payments p) payments,
 (select jsonb_agg(to_jsonb(a) order by id) from public.attendance a) attendance,
 (select jsonb_agg(to_jsonb(i) order by id) from public.invoices i) invoices`;
 const before=(await pg.admin.query(historySql)).rows;
 await assert.rejects(a.query("update public.teachers set subscription_status='active' where id=$1",[ids.teacher]));checks++;
 await pg.admin.query("update public.teachers set subscription_status='inactive' where id=$1",[ids.teacher]);
 await deny(a,'public.get_current_profile()');
 await deny(s,'public.get_current_profile()');
 await deny(a,'public.list_teacher_secretaries()');
 await deny(s,'public.secretary_dashboard()');
 await deny(s,"public.secretary_set_attendance($1,$2,'present')",[ids.session,ids.student]);
 await deny(a,'public.deactivate_secretary($1)',[ids.secretary]);
 for(const c of [a,s]) {
  eq((await c.query('select count(*)::int n from public.students')).rows[0].n,0);
  eq((await c.query('select count(*)::int n from public.payments')).rows[0].n,0);
 }
 eq((await call(b,'public.get_current_profile()')).teacher_id,ids.other);
 const fresh=await pg.connect(ids.teacher);await deny(fresh,'public.get_current_profile()');
 await pg.admin.query("update public.teachers set subscription_status='active' where id=$1",[ids.teacher]);
 eq((await call(a,'public.get_current_profile()')).role,'teacher');
 eq((await call(s,'public.get_current_profile()')).role,'secretary');
 eq((await pg.admin.query(historySql)).rows,before);
 console.log(JSON.stringify({pass:true,checks,backend:'native PostgreSQL role simulation',hosted:false}));
}finally{await pg.close();}
