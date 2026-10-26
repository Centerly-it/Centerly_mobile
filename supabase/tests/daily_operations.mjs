// OPS37 local native SQL only. No hosted configuration, account or fixture writes.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {randomUUID,createHash} from 'node:crypto';
import {startPostgres} from './postgres.mjs';
const pg=await startPostgres({through:'202610250002'});let checks=0;
const t='10000000-0000-0000-0000-000000000001',s='20000000-0000-0000-0000-000000000001',other='20000000-0000-0000-0000-000000000002',student='30000000-0000-0000-0000-000000000001';
const scalar=async(c,q,p=[])=>Object.values((await c.query(q,p)).rows[0])[0];
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const deny=async(p,pattern)=>{await assert.rejects(p,pattern);checks++;};
try{
 const a=await pg.connect(s),b=await pg.connect(s),teacher=await pg.connect(t),foreign=await pg.connect(other);
 const policies=await scalar(pg.admin,"select jsonb_agg(to_jsonb(p) order by tablename,policyname) from pg_policies p where schemaname='public'");
 const sql=await readFile(new URL('../proposals/202610260001_daily_operations.sql',import.meta.url),'utf8');await pg.admin.query(sql);
 eq(await scalar(pg.admin,"select jsonb_agg(to_jsonb(p) order by tablename,policyname) from pg_policies p where schemaname='public'"),policies);
 await deny(teacher.query("select public.secretary_restore('students',$1,$2)",[student,randomUUID()]),/FORBIDDEN_ROLE/);
 await deny(foreign.query("select public.secretary_restore('students',$1,$2)",[student,randomUUID()]),/NOT_FOUND/);
 const inv=await scalar(a,"select public.create_invoice($1,100.10,current_date,'OPS37')",[student]);
 const before=(await pg.admin.query('select id,status,joined_at::text,left_at::text from public.group_enrollments where student_id=$1',[student])).rows;
 await a.query("select public.secretary_archive('students',$1)",[student]);
 const history=(await pg.admin.query('select id,status,joined_at::text,left_at::text from public.group_enrollments where student_id=$1',[student])).rows;
 eq(history,before);
 await deny(a.query('update public.students set archived_at=null where id=$1',[student]),/CONFLICT/);
 const pay=await scalar(a,"select public.record_payment($1,40.05,'cash',$2)",[inv,randomUUID()]);checks++;
 const editKey=randomUUID();await a.query("select public.secretary_edit_finance('payment',$1,30.05,40.05,$2,null,'cash')",[pay,editKey]);checks++;
 const page=await scalar(a,"select public.secretary_finance_page('payments',jsonb_build_object('invoice_id',$1::text))",[inv]);eq(page.total_count,1);eq(page.rows[0].amount_egp,'30.05');eq(page.summary.amount_egp,'30.05');
 const ti=await scalar(teacher,'select public.get_teacher_current_invoice($1)',[inv]);eq(ti.total_count,1);eq(ti.invoice.outstanding_egp,'70.05');eq(ti.rows[0].amount_egp,'30.05');
 const legacy=await scalar(teacher,'select public.get_teacher_invoice_detail($1)',[inv]);eq(legacy.rows.length,3); // immutable internal history retained
 await deny(a.query('select public.get_teacher_current_invoice($1)',[inv]),/FORBIDDEN_ROLE/);
 eq((await scalar(foreign,"select public.secretary_finance_page('invoices',jsonb_build_object('id',$1::text))",[inv])).total_count,0);
 await deny(a.query("select public.create_invoice($1,1,current_date,'ARCHIVED-NEW')",[student]),/CONFLICT/);
 const request=randomUUID();const restores=await Promise.all([a,b].map(c=>scalar(c,"select public.secretary_restore('students',$1,$2)",[student,request])));eq(restores[0],restores[1]);
 eq((await pg.admin.query('select id,status,joined_at::text,left_at::text from public.group_enrollments where student_id=$1',[student])).rows,history);
 await deny(a.query("select public.secretary_restore('groups',$1,$2)",[student,request]),/CONFLICT/);
 eq(await scalar(pg.admin,"select count(*)::int from public.audit_events where entity_type='record_restore' and entity_id=$1",[request]),1);
 // Server-side name search, exact full totals and cursor pages after >30 matches.
 await a.query("update public.students set full_name='أحمد حسن' where id=$1",[student]);
 for(let i=0;i<35;i++)await a.query('select public.create_invoice($1,0.01,current_date,$2)',[student,'OPS37-PAGE-'+i]);
 const p1=await scalar(a,"select public.secretary_finance_page('invoices','{}','احمد',null,10)");eq(p1.total_count,36);eq(p1.rows.length,10);eq(p1.summary.balance_egp,'70.40');
 const p2=await scalar(a,"select public.secretary_finance_page('invoices','{}','أحمد',$1,10)",[p1.next_cursor]);eq(p2.total_count,36);eq(p2.summary.balance_egp,p1.summary.balance_egp);assert.ok(p2.rows.every(r=>!p1.rows.some(x=>x.id===r.id)));checks++;
 await deny(a.query("select public.secretary_finance_page('invoices','{\"teacher_id\":\"x\"}')"),/VALIDATION_ERROR/);
 await deny(teacher.query("select public.secretary_finance_page('payments')"),/FORBIDDEN_ROLE/);
 // Automatic generation adopts pre-existing exact manual sessions and keeps cancellations.
 const group=randomUUID();const day=await scalar(pg.admin,"select (now() at time zone 'Africa/Cairo')::date+1");
 const date=typeof day==='string'?day:day.toISOString().slice(0,10),weekday=await scalar(pg.admin,'select extract(dow from $1::date)::int',[date]);
 await a.query("select public.secretary_create_weekly_group($1,'OPS37-GROUP','Math',0,0,$2,'15:00','16:00')",[group,[weekday]]);
 await a.query('select public.secretary_enroll($1,$2)',[group,student]);
 const manual=randomUUID();await a.query("select public.secretary_create_session($1,$2,$3,'15:00','16:00',0)",[manual,group,date]);
 await a.query('select public.generate_sessions($1,$1)',[date]);eq(await scalar(pg.admin,'select count(*)::int from public.sessions where group_id=$1 and local_date=$2',[group,date]),1);
 await a.query("select public.cancel_session($1,'OPS37 cancellation')",[manual]);await a.query('select public.generate_sessions($1,$1)',[date]);eq(await scalar(pg.admin,'select count(*)::int from public.sessions where group_id=$1 and local_date=$2',[group,date]),1);
 const oldSchedules=(await pg.admin.query('select id,effective_from::text from public.group_schedules where group_id=$1',[group])).rows;
 await a.query("select public.secretary_archive('groups',$1)",[group]);
 await deny(a.query('update public.groups set archived_at=null where id=$1',[group]),/CONFLICT/);
 await a.query("select public.secretary_restore('groups',$1,$2)",[group,randomUUID()]);
 eq(await scalar(pg.admin,'select count(*)::int from public.group_enrollments where group_id=$1 and status=\'active\'',[group]),1);
 eq(await scalar(pg.admin,'select count(*)::int from public.group_schedules where group_id=$1 and retired_at is not null',[group]),oldSchedules.length);
 const futureDate=await scalar(pg.admin,'select ($1::date+7)::text',[date]);
 const generated=await Promise.all([a,b].map(c=>scalar(c,'select public.generate_sessions($1::date,$1::date)',[futureDate])));eq(generated.reduce((x,y)=>x+y,0),1);
 eq(await scalar(pg.admin,'select count(*)::int from public.sessions where group_id=$1 and local_date=$2',[group,futureDate]),1);
 await deny(teacher.query('select public.generate_sessions($1,$1)',[date]),/FORBIDDEN_ROLE/);
 // Stale concurrent edits: one succeeds, one conflicts, exact current balance remains authoritative.
 const raceInvoice=await scalar(a,"select public.create_invoice($1,100,current_date,'OPS37-RACE')",[student]);
 const racePayment=await scalar(a,"select public.record_payment($1,50,'cash',$2)",[raceInvoice,randomUUID()]);
 const race=await Promise.allSettled([a,b].map((c,i)=>c.query("select public.secretary_edit_finance('payment',$1,$2,50,$3,null,'cash')",[racePayment,30+i,randomUUID()])));
 eq(race.filter(r=>r.status==='fulfilled').length,1);eq(race.filter(r=>r.status==='rejected').length,1);
 const racePage=await scalar(a,"select public.secretary_finance_page('payments',jsonb_build_object('invoice_id',$1::text))",[raceInvoice]);eq(racePage.total_count,1);assert.ok(['30.00','31.00'].includes(racePage.summary.amount_egp));checks++;
 console.log(JSON.stringify({pass:true,checks,baseline:36,candidate:'202610260001',sha256:createHash('sha256').update(sql).digest('hex'),hosted:false}));
}finally{await pg.close();}
