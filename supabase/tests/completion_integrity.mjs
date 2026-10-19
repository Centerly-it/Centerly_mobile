// Disposable PostgreSQL only: package side effects and financial/optimistic races.
import assert from 'node:assert/strict';
import {completionContext,ids} from './completion_context.mjs';
const c=await completionContext(); let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const denied=async p=>{await assert.rejects(p,/NOT_FOUND|permission denied/);checks++;};
try {
 const {a,s,pg,call,date}=c;
 const second=await pg.connect(ids.secretary), editor=await pg.connect(ids.teacher);
 const invoice=await call(s,"public.create_invoice($1,100.01,$2,'PACKAGE-RACE')",[ids.student,date]);
 const key='60000000-0000-0000-0000-000000000010';
 const pay=client=>call(client,"public.record_payment($1,10.01,'cash',$2)",[invoice,key]);
 const payments=await Promise.all([pay(s),pay(second)]); eq(payments[0],payments[1]);
 const notificationCount=async id=>Number((await pg.admin.query(
  "select count(*) from public.notifications where payload->>'payment_id'=$1",[id])).rows[0].count);
 eq(await notificationCount(payments[0]),1);
 const reverse=client=>call(client,"public.reverse_payment($1,'package integrity')",[payments[0]]);
 const reversals=await Promise.all([reverse(s),reverse(second)]);eq(reversals[0],reversals[1]);
 eq(await notificationCount(reversals[0]),1);
 let f=await call(a,"public.get_teacher_finance($1,$1,'invoices',$2)",[date,ids.student]);
 eq(f.summary.invoiced_egp,'200.02');eq(f.summary.paid_against_invoices_egp,'0.00');
 eq(f.summary.outstanding_egp,'200.02');eq(f.summary.period_net_collected_egp,'0.00');
 // Calendar-day conversion must use Cairo even when the database connection is UTC.
 const paid=await call(s,"public.record_payment($1,1.01,'cash',gen_random_uuid())",[invoice]);
 const edge=(await pg.admin.query("select ('2026-04-24'::date::timestamp at time zone 'Africa/Cairo')::text as instant")).rows[0].instant;
 // Test-only fixture insertion predates the boundary; never update append-only money.
 await pg.admin.query(`insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key,collected_at)
  values($1,$2,2.01,$3,'cash',gen_random_uuid(),$4::timestamptz-interval '1 microsecond')`,[ids.teacher,invoice,ids.secretary,edge]);
 f=await call(a,"public.get_teacher_finance('2026-04-23','2026-04-23','payments')");
 eq(f.summary.period_net_collected_egp,'2.01');
 f=await call(a,"public.get_teacher_finance('2026-04-24','2026-04-24','payments')");
 eq(f.summary.period_net_collected_egp,'0.00');
 await call(a,"public.save_teacher_note($1,'initial')",[ids.student]);
 const version=(await call(a,'public.get_teacher_student_note($1)',[ids.student])).note.updated_at;
 const writes=await Promise.allSettled([a,editor].map(client=>call(client,
  "public.save_teacher_note($1,'concurrent',$2)",[ids.student,version])));
 eq(writes.filter(r=>r.status==='fulfilled').length,1);
 eq(writes.find(r=>r.status==='rejected').reason.message,'CONFLICT');
 const requests=await Promise.all([a,editor].map(client=>call(client,'public.request_secretary_removal($1)',[ids.secretary])));
 eq(requests[0],requests[1]);
 await pg.admin.query("update public.secretary_removal_requests set status='handled',handled_at=now() where id=$1",[requests[0]]);
 await pg.admin.query("update public.secretary_removal_requests set handled_at=now() where id=$1",[requests[0]]);
 eq(Number((await pg.admin.query("select count(*) from public.notifications where payload->>'request_id'=$1",[requests[0]])).rows[0].count),1);
 eq((await call(a,'public.list_teacher_secretaries()')).rows[0].status,'active');
 const privateEvent=(await pg.admin.query(`insert into public.notifications(teacher_id,recipient_id,type,payload)
  values($1,$2,'admin_event','{}') returning id`,[ids.teacher,ids.secretary])).rows[0].id;
 await denied(call(a,'public.mark_notification_read($1)',[privateEvent]));
 await denied(call(c.b,'public.mark_notification_read($1)',[privateEvent]));
 const ownEvents=await call(a,'public.list_teacher_notifications(null,1)');eq(ownEvents.rows.length,1);
 const all=[];let page=ownEvents;
 while(page) {all.push(...page.rows);page=page.next_cursor?await call(a,'public.list_teacher_notifications($1,1)',[page.next_cursor]):null;}
 eq(new Set(all.map(r=>r.id)).size,all.length);eq(all.length,ownEvents.total_count);
 eq(all.some(r=>r.id===privateEvent),false);
 eq(await notificationCount(paid),1);
 console.log(`PASS: ${checks} completion integrity assertions (races, notification effects, Cairo boundary).`);
} finally {await c.pg.close();}
