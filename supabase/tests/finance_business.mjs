import {verifyFinanceReview} from './finance_review_manifest.mjs';
import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {completionContext,ids} from './completion_context.mjs';
await verifyFinanceReview();
const ctx=await completionContext({through:'202610190010'});
const {pg,a,b,s,date,call,invoice,payment}=ctx;
let checks=0;
const eq=(actual,expected)=>{assert.deepEqual(actual,expected);checks++;};
const deny=async(client,sql,args=[],message)=>{await assert.rejects(()=>call(client,sql,args),message);checks++;};
try {
 for(const file of (await readdir(new URL('../proposals/finance_business/',import.meta.url))).sort())
  await pg.admin.query(await readFile(new URL('../proposals/finance_business/'+file,import.meta.url),'utf8'));
 const overview=()=>call(a,'public.get_teacher_finance_overview($1,$1)',[date]);
 let data=await overview();
 eq(data.invoiced_egp,'100.01');eq(data.paid_against_invoices_egp,'0.00');eq(data.outstanding_egp,'100.01');
 eq(data.gross_collected_egp,'25.01');eq(data.corrections_egp,'25.01');eq(data.period_net_collected_egp,'0.00');
 eq(data.due_today_egp,'100.01');eq(data.overdue_egp,'0.00');eq(data.future_due_egp,'0.00');
 const partial=await call(s,"public.record_payment($1,40.01,'transfer',gen_random_uuid())",[invoice]);
 data=await overview();eq(data.paid_against_invoices_egp,'40.01');eq(data.outstanding_egp,'60.00');
 eq(data.actors[0].net_egp,'40.01');eq(data.actors[0].collection_count,2);eq(data.actors[0].correction_count,1);
 const detail=await call(a,'public.get_teacher_invoice_detail($1,null,1)',[invoice]);
 eq(detail.invoice.created_by,ids.secretary);eq(detail.invoice.net_paid_egp,'40.01');eq(detail.total_count,3);
 eq(detail.rows.length,1);assert.ok(detail.next_cursor);checks++;
 const full=await call(a,'public.get_teacher_invoice_detail($1)',[invoice]);
 const correction=full.rows.find(r=>r.reversal_of===payment);eq(correction.original_collected_by,ids.secretary);
 eq(correction.original_amount_egp,'25.01');eq(correction.signed_amount_egp,'-25.01');
 eq(full.rows.find(r=>r.id===payment).reversed_by,correction.id);
 let dues=await call(a,"public.list_teacher_finance_dues($1,$1,'partial')",[date]);eq(dues.total_count,1);eq(dues.summary.outstanding_egp,'60.00');
 dues=await call(a,"public.list_teacher_finance_dues($1,$1,'overdue')",[date]);eq(dues.total_count,0);
 dues=await call(a,"public.list_teacher_finance_dues($1,$1,'all','PKG-1')",[date]);eq(dues.total_count,1);
 dues=await call(a,"public.list_teacher_finance_dues($1,$1,'all','%')",[date]);eq(dues.total_count,0);
 eq((await call(b,'public.get_teacher_finance_overview($1,$1)',[date])).invoiced_egp,'0.00');
 await deny(b,'public.get_teacher_invoice_detail($1)',[invoice],/NOT_FOUND/);
 await deny(a,"public.list_teacher_finance_dues($1,$1,'all','',$2)",[date,ids.otherStudent],/NOT_FOUND/);
 await deny(a,"public.list_teacher_finance_dues($1,$1,'invalid')",[date],/VALIDATION_ERROR/);
 await deny(a,'public.get_teacher_finance_overview($1,$2)',[date,'2000-01-01'],/VALIDATION_ERROR/);
 await deny(a,'public.get_teacher_invoice_detail($1,null,101)',[invoice],/VALIDATION_ERROR/);
 for(const [sql,args] of [['public.get_teacher_finance_overview($1,$1)',[date]],['public.get_teacher_invoice_detail($1)',[invoice]],["public.list_teacher_finance_dues($1,$1)",[date]]]) {
  await deny(s,sql,args,/FORBIDDEN/);
  await pg.admin.query('set role anon');await deny(pg.admin,sql,args,/permission denied/);await pg.admin.query('reset role');
 }
 // Synthetic local history straddles midnight Cairo, including archived records.
 const second='20000000-0000-0000-0000-000000000003';
 await pg.admin.query('insert into auth.users(id) values($1)',[second]);
 await pg.admin.query("insert into public.secretaries(id,teacher_id,name,email) values($1,$2,'Correction actor','correction@example.invalid')",[second,ids.teacher]);
 const otherActor=await pg.connect(second);
 await call(otherActor,"public.reverse_payment($1,'Different actor corrects full amount')",[partial]);
 data=await overview();
 eq(data.actors.find(r=>r.actor_id===ids.secretary).net_egp,'40.01');
 eq(data.actors.find(r=>r.actor_id===second).net_egp,'-40.01');
 eq(data.period_net_collected_egp,'0.00');
 const old=await call(s,"public.create_invoice($1,50.01,($2::date-1),'OLD-COHORT')",[ids.student,date]);
 await call(s,"public.record_payment($1,20.01,'cash',gen_random_uuid())",[old]);
 data=await overview();eq(data.invoiced_egp,'100.01');eq(data.period_net_collected_egp,'20.01');
 eq((await call(a,'public.get_teacher_invoice_detail($1)',[old])).invoice.outstanding_egp,'30.00');
 const boundary=await call(s,"public.create_invoice($1,2,$2,'BOUNDARY')",[ids.student,date]);
 await pg.admin.query(`insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,collected_at,method,idempotency_key)
 values($1,$2,0.01,$3,($4::date::timestamp at time zone 'Africa/Cairo')-interval '1 microsecond','cash',gen_random_uuid()),
 ($1,$2,0.02,$3,$4::date::timestamp at time zone 'Africa/Cairo','cash',gen_random_uuid()),
 ($1,$2,0.03,$3,($4::date+1)::timestamp at time zone 'Africa/Cairo','cash',gen_random_uuid())`,[ids.teacher,boundary,ids.secretary,date]);
 data=await overview();eq(data.period_net_collected_egp,'20.03');
 eq(data.paid_against_invoices_egp,'0.06');
 let first=await call(a,"public.list_teacher_finance_dues($1,$1,'all','',null,null,null,1)",[date]);
 eq(first.rows.length,1);eq(first.total_count,2);eq(first.summary.invoiced_egp,'102.01');
 const next=await call(a,"public.list_teacher_finance_dues($1,$1,'all','',null,null,$2,1)",[date,first.next_cursor]);
 eq(next.rows.length,1);eq(next.next_cursor,null);assert.notEqual(next.rows[0].id,first.rows[0].id);checks++;
 await pg.admin.query('update public.students set archived_at=now() where id=$1',[ids.student]);
 eq((await call(a,'public.get_teacher_invoice_detail($1)',[invoice])).invoice.student_id,ids.student);
 await pg.admin.query("update public.secretaries set status='inactive' where id=$1",[ids.secretary]);
 eq((await overview()).actors[0].actor_status,'inactive');
 eq((await call(a,'public.get_teacher_invoice_detail($1)',[invoice])).invoice.created_by_status,'inactive');
 await pg.admin.query("update public.teachers set subscription_status='inactive' where id=$1",[ids.teacher]);
 await deny(a,'public.get_teacher_finance_overview($1,$1)',[date],/SUBSCRIPTION_INACTIVE/);
 await pg.admin.query("update public.teachers set subscription_status='active',status='inactive' where id=$1",[ids.teacher]);
 await deny(a,'public.get_teacher_invoice_detail($1)',[invoice],/ACCOUNT_INACTIVE/);
 await pg.admin.query("update public.teachers set status='active' where id=$1",[ids.teacher]);
 const count=async()=> (await pg.admin.query('select count(*)::int n from public.notifications')).rows[0].n;
 const notifications=await count();await overview();await call(a,'public.get_teacher_invoice_detail($1)',[invoice]);
 await call(a,'public.list_teacher_finance_dues($1,$1)',[date]);eq(await count(),notifications);
 eq((await pg.admin.query("select count(*)::int n from pg_indexes where indexname='teacher_invoice_movements' and indexdef like '%(invoice_id, id) INCLUDE (teacher_id, amount_egp, reversal_of)%'")).rows[0].n,1);
 const defs=(await pg.admin.query("select prosecdef,proconfig from pg_proc where proname in ('get_teacher_finance_overview','get_teacher_invoice_detail','list_teacher_finance_dues')")).rows;
 eq(defs.length,3);for(const def of defs){eq(def.prosecdef,true);assert.ok(def.proconfig.includes('search_path=""'));checks++;}
 console.log(`Finance business proposals: ${checks} assertions PASS (disposable local PostgreSQL; no hosted access).`);
} finally {await pg.close();}
