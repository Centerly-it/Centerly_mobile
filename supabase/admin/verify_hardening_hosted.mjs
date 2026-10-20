// Existing synthetic identities only; no account/Auth changes or customer data.
import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {writeFile} from 'node:fs/promises';
import {hostedContext} from './completion_hosted_context.mjs';
import {querySql} from './trusted_cli.mjs';
const c=await hostedContext();let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
try {
 const {rpc,request,teacher,other,secretary,student,group}=c;
 const current=await rpc(teacher,'get_teacher_overview',{});eq(current.ok,true);
 const date=current.data.date;eq(current.data.attendance_scope,'ongoing_sessions');
 assert.ok(Date.parse(current.data.attendance_synced_at));checks++;
 const invoice=await rpc(secretary,'create_invoice',{p_student_id:student,p_amount:10.01,p_due_on:date,p_invoice_number:`HARD-${randomUUID()}`});eq(invoice.ok,true);
 const reads=[['get_teacher_finance_overview',{p_from:date,p_to:date}],
 ['get_teacher_invoice_detail',{p_id:invoice.data}],['list_teacher_finance_dues',{p_from:date,p_to:date}]];
 for(const [name,body] of reads) {
  eq((await rpc(teacher,name,body)).ok,true);
  for(const actor of [secretary,c.actors['secretary-b']]) eq((await rpc(actor,name,body)).data.message,'FORBIDDEN_ROLE');
  eq([401,403].includes((await rpc(null,name,body)).status),true);
 }
 eq((await rpc(other,'get_teacher_invoice_detail',{p_id:invoice.data})).data.message,'NOT_FOUND');
 const key=randomUUID(),payBody={p_invoice_id:invoice.data,p_amount:4.01,p_method:'cash',p_idempotency_key:key};
 const paid=await Promise.all([rpc(secretary,'record_payment',payBody),rpc(secretary,'record_payment',payBody)]);
 eq(paid.every(r=>r.ok),true);eq(paid[0].data,paid[1].data);
 for(const id of [invoice.data,teacher.id,student,group]) assert.match(id,/^[0-9a-f-]{36}$/i);
 await querySql(`update public.invoices set status='void',void_reason='Approved synthetic hardening fixture' where id='${invoice.data}' and teacher_id='${teacher.id}' and student_id='${student}';`);
 const reverse=()=>rpc(secretary,'reverse_payment',{p_payment_id:paid[0].data,p_reason:'Approved synthetic void correction'});
 const reversed=await Promise.all([reverse(),reverse()]);eq(reversed.every(r=>r.ok),true);eq(reversed[0].data,reversed[1].data);
 const detail=await rpc(teacher,'get_teacher_invoice_detail',{p_id:invoice.data});
 eq(detail.data.invoice.status,'void');eq(detail.data.invoice.net_paid_egp,'0.00');eq(detail.data.rows.length,2);
 for(const payment of [paid[0].data,reversed[0].data]) {
  const events=await request(teacher,`/rest/v1/notifications?select=id&payload->>payment_id=eq.${payment}`);
  eq(events.ok,true);eq(events.data.length,1);
 }
 const bad=await request(secretary,'/rest/v1/group_enrollments','POST',{
  teacher_id:teacher.id,group_id:group,student_id:student,status:'inactive',left_at:null});
 eq(bad.ok,false);eq(bad.data.code,'23514');
 const session=randomUUID();
 // One statement timestamp; all attendance/session mutations ROLLBACK.
 await querySql(`begin; do $$ declare t timestamptz:=statement_timestamp(); b jsonb; r jsonb; begin
 perform set_config('request.jwt.claim.sub','${teacher.id}',true);
 b:=public.get_teacher_overview('2030-01-01')->'attendance_counts';
 insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at)
 values('${session}','${teacher.id}','${group}',(t at time zone 'Africa/Cairo')::date-1,t,t+interval '1 hour');
 insert into public.attendance(teacher_id,session_id,student_id) values('${teacher.id}','${session}','${student}');
 r:=public.get_teacher_overview('2030-01-01')->'attendance_counts';
 assert (r->>'not_marked')::int=(b->>'not_marked')::int+1;
 assert r->>'absent'=b->>'absent';
 update public.attendance set status='present' where session_id='${session}';
 r:=public.get_teacher_overview('2030-01-01')->'attendance_counts';
 assert (r->>'present')::int=(b->>'present')::int+1;
 update public.sessions set starts_at=t-interval '1 hour',ends_at=t where id='${session}';
 assert public.get_teacher_overview('2030-01-01')->'attendance_counts'=b;
 update public.sessions set starts_at=t+interval '1 second',ends_at=t+interval '1 hour' where id='${session}';
 assert public.get_teacher_overview('2030-01-01')->'attendance_counts'=b;
 update public.sessions set starts_at=t-interval '1 hour',status='cancelled',cancelled_by='${teacher.id}',cancelled_at=t,cancel_reason='Approved synthetic' where id='${session}';
 assert public.get_teacher_overview('2030-01-01')->'attendance_counts'=b;
 end $$; rollback;`);checks+=6;
 const rollback=await request(teacher,`/rest/v1/sessions?id=eq.${session}&select=id`);eq(rollback.data,[]);
 const report={passed:true,checks,project:'centerly-dev',syntheticOnly:true,accountsOrAuthChanged:false,
  coverage:['three real teacher finance reads','Secretary/anonymous/other-tenant denial','void preserved',
  'concurrent payment/reversal idempotency','exactly-once notification','enrollment timeline rejected',
  'server attendance boundaries/selected-day independence/overnight/cancellation','transaction rollback'],invoice:invoice.data};
 await writeFile(new URL('../../build/hardening-hosted-result.json',import.meta.url),JSON.stringify(report,null,2));
 console.log(`PASS: ${checks} hosted hardening assertions; synthetic fixtures only; no account/Auth changes.`);
} finally {await c.close();}
