import {verifyOngoingAttendance} from './ongoing_attendance.mjs';
import {verifyReviewedSql} from './review_manifest.mjs';
// Disposable local PostgreSQL only. Demonstrate old defects, then verify proposals.
import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {completionContext,ids} from './completion_context.mjs';
await verifyReviewedSql(new URL('../../docs/LOGIC_HARDENING_CHANGE_REVIEW.md',import.meta.url),new URL('../proposals/logic_hardening/',import.meta.url),3);
const ctx=await completionContext({through:'202610190010'});let count=0;
const {pg,a,b,s,date,call}=ctx;
const eq=(actual,expected)=>{assert.deepEqual(actual,expected);count++;};
try {
 const create=()=>call(s,"public.create_invoice($1,100.01,$2,gen_random_uuid()::text)",[ids.student,date]);
 const old=await create();const oldPayment=await call(s,"public.record_payment($1,40.01,'cash',gen_random_uuid())",[old]);
 await pg.admin.query("update public.invoices set status='void',void_reason='Local synthetic fixture' where id=$1",[old]);
 await call(s,"public.reverse_payment($1,'Old behavior reproduction')",[oldPayment]);
 eq((await pg.admin.query('select status from public.invoices where id=$1',[old])).rows[0].status,'due');
 const malformed=(await s.query(`insert into public.group_enrollments(teacher_id,group_id,student_id,status)
 values($1,$2,$3,'inactive') returning id`,[ids.teacher,ids.group,ids.student])).rows[0].id;
 for(const file of (await readdir(new URL('../proposals/logic_hardening/',import.meta.url))).filter(f=>f.endsWith('.sql')).sort())
 await pg.admin.query(await readFile(new URL('../proposals/logic_hardening/'+file,import.meta.url),'utf8'));
 const fresh=await create();const payment=await call(s,"public.record_payment($1,40.01,'transfer',gen_random_uuid())",[fresh]);
 await pg.admin.query("update public.invoices set status='void',void_reason='Local synthetic fixture' where id=$1",[fresh]);
 const reverse=await call(s,"public.reverse_payment($1,'Preserve void')",[payment]);
 eq(await call(s,"public.reverse_payment($1,'Idempotent retry')",[payment]),reverse);
 eq((await pg.admin.query('select status from public.invoices where id=$1',[fresh])).rows[0].status,'void');
 eq((await pg.admin.query("select count(*)::int n from public.notifications where payload->>'payment_id'=$1",[reverse])).rows[0].n,1);
 eq((await pg.admin.query('select count(*)::int n from public.payments where invoice_id=$1',[fresh])).rows[0].n,2);
 const report=await call(a,"public.get_teacher_finance($1,$1,'invoices')",[date]);
 eq(report.summary.invoiced_egp,'200.02');eq(report.summary.outstanding_egp,'200.02');
 eq(report.summary.period_net_collected_egp,'0.00');
 await assert.rejects(()=>call(a,'public.reverse_payment($1,$2)',[payment,'Denied']),/FORBIDDEN_ROLE/);count++;
 await assert.rejects(()=>call(b,'public.reverse_payment($1,$2)',[payment,'Denied']),/FORBIDDEN_ROLE/);count++;
 await assert.rejects(()=>call(s,'private.reconcile_invoice($1)',[fresh]),/permission denied/);count++;
 await assert.rejects(()=>s.query("update public.group_enrollments set status='inactive' where teacher_id=$1 and status='active'",[ids.teacher]),/enrollment_status_timeline/);count++;
 await assert.rejects(()=>s.query("update public.group_enrollments set left_at=joined_at+interval '1 day' where teacher_id=$1 and status='active'",[ids.teacher]),/enrollment_status_timeline/);count++;
 await assert.rejects(()=>s.query("update public.group_enrollments set status='inactive',left_at=joined_at-interval '1 day' where id=$1",[malformed]),/enrollment_status_timeline/);count++;
 await s.query("update public.group_enrollments set status='inactive',left_at=joined_at+interval '1 day' where id=$1",[malformed]);
 eq((await pg.admin.query('select status from public.group_enrollments where id=$1',[malformed])).rows[0].status,'inactive');
 eq((await pg.admin.query("select convalidated from pg_constraint where conname='enrollment_status_timeline'")).rows[0].convalidated,false);
 await pg.admin.query('alter table public.group_enrollments validate constraint enrollment_status_timeline');
 eq((await pg.admin.query("select convalidated from pg_constraint where conname='enrollment_status_timeline'")).rows[0].convalidated,true);
 count+=await verifyOngoingAttendance(ctx);
 console.log(`Logic hardening: ${count} assertions PASS; old void/timeline defects reproduced; local-only proposals verified.`);
} finally {await pg.close();}
