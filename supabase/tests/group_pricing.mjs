import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {startPostgres} from './postgres.mjs';
import {ids} from './completion_context.mjs';
const pg=await startPostgres();let checks=0;
const ok=(a,b)=>{assert.deepEqual(a,b);checks++;};
try {
 await pg.admin.query(await readFile(new URL('../proposals/202610230002_group_pricing.sql',import.meta.url),'utf8'));
 const s=await pg.connect(ids.secretary),teacher=await pg.connect(ids.teacher);
 const other=await pg.connect('20000000-0000-0000-0000-000000000002');
 await s.query('update public.groups set monthly_fee_egp=700,materials_fee_egp=300 where id=$1',[ids.group]);
 for(const [anchor,day,expected] of [['2026-01-23','2026-02-22','2026-01-23'],['2026-01-23','2026-02-23','2026-02-23'],['2026-01-31','2026-02-28','2026-02-28'],['2024-01-31','2024-02-29','2024-02-29']]) {
  ok((await pg.admin.query('select private.billing_cycle_on($1,$2)::text d',[anchor,day])).rows[0].d,expected);
 }
 ok((await pg.admin.query("select private.billing_cycle_next('2026-01-31','2026-02-28')::text d")).rows[0].d,'2026-03-31');
 // Existing fixture membership was made before pricing. Replace only in disposable local DB.
 await pg.admin.query('delete from public.group_enrollments where student_id=$1',[ids.student]);
 await s.query('select public.secretary_enroll($1,$2)',[ids.group,ids.student]);
 const bill=(await pg.admin.query('select * from public.invoices where student_id=$1',[ids.student])).rows[0];
 ok(bill.amount_egp,'1000.00');ok(bill.monthly_fee_egp,'700.00');ok(bill.materials_fee_egp,'300.00');
 await Promise.all([s.query('select public.secretary_refresh_group_dues()'),(await pg.connect(ids.secretary)).query('select public.secretary_refresh_group_dues()')]);
 ok((await pg.admin.query('select count(*)::int n from public.invoices')).rows[0].n,1);
 await assert.rejects(s.query("update public.group_enrollments set last_billed_on='2099-01-01' where student_id=$1",[ids.student]));checks++;
 await assert.rejects(s.query('select public.secretary_enroll($1,$2)',[ids.group,ids.student]));checks++;
 ok((await pg.admin.query('select count(*)::int n from public.invoices')).rows[0].n,1);
 await s.query("select public.record_payment($1,200,'cash','90000000-0000-0000-0000-000000000001')",[bill.id]);
 const browsed=(await s.query("select public.secretary_browse('invoices') data")).rows[0].data.rows[0];
 ok(Number(browsed.payable_balance_egp),800);ok(Number(browsed.original_amount_egp),1000);ok(Number(browsed.ledger_net_egp),200);
 await s.query('update public.groups set monthly_fee_egp=800 where id=$1',[ids.group]);
 ok((await pg.admin.query('select amount_egp from public.invoices where id=$1',[bill.id])).rows[0].amount_egp,'1000.00');
 await assert.rejects(teacher.query('select public.secretary_refresh_group_dues()'));checks++;
 await other.query('select public.secretary_refresh_group_dues()');
 ok((await pg.admin.query('select count(*)::int n from public.invoices')).rows[0].n,1);
 await assert.rejects(pg.admin.query('update public.invoices set monthly_fee_egp=600,amount_egp=900 where id=$1',[bill.id]));checks++;
 const e=(await s.query('select id from public.group_enrollments where student_id=$1',[ids.student])).rows[0].id;
 await s.query('select public.secretary_enroll($1,$2,$3)',[ids.group,ids.student,e]);
 await s.query('select public.secretary_enroll($1,$2)',[ids.group,ids.student]);
 ok((await pg.admin.query('select count(*)::int n from public.invoices')).rows[0].n,1);
 await pg.admin.query('update public.students set archived_at=now() where id=$1',[ids.student]);
 await s.query('select public.secretary_refresh_group_dues()');
 ok((await pg.admin.query('select count(*)::int n from public.invoices')).rows[0].n,1);
 // Disposable SQL-role simulation of a missed visit: backdated enrollment must catch up all cycles.
 const older='30000000-0000-0000-0000-000000000003';
 await s.query("insert into public.students(id,teacher_id,full_name) values($1,$2,'محمد')",[older,ids.teacher]);
 await pg.admin.query("select set_config('request.jwt.claim.sub',$1,false)",[ids.secretary]);
 await pg.admin.query('alter table public.group_enrollments disable trigger secretary_enrollment_guard');
 try {await pg.admin.query("insert into public.group_enrollments(teacher_id,student_id,group_id,joined_at) values($1,$2,$3,now()-interval '2 months')",[ids.teacher,older,ids.group]);}
 finally {await pg.admin.query('alter table public.group_enrollments enable trigger secretary_enrollment_guard');}
 const catchup=(await pg.admin.query('select amount_egp,materials_fee_egp from public.invoices where student_id=$1 order by billing_period_start',[older])).rows;
 ok(catchup.map(x=>x.amount_egp),['1100.00','800.00','800.00']);
 ok(catchup.map(x=>x.materials_fee_egp),['300.00','0.00','0.00']);
 await s.query('select public.secretary_refresh_group_dues()');
 ok((await pg.admin.query('select count(*)::int n from public.invoices where student_id=$1',[older])).rows[0].n,3);
 // A failing charge rolls back membership too, instead of admitting an unbilled student.
 const failing='30000000-0000-0000-0000-000000000004';
 await s.query("insert into public.students(id,teacher_id,full_name) values($1,$2,'عبد الرحمن')",[failing,ids.teacher]);
 await s.query('update public.groups set monthly_fee_egp=9999999999,materials_fee_egp=300 where id=$1',[ids.group]);
 await assert.rejects(s.query('select public.secretary_enroll($1,$2)',[ids.group,failing]));checks++;
 ok((await pg.admin.query('select count(*)::int n from public.group_enrollments where student_id=$1',[failing])).rows[0].n,0);
 const target=(await s.query("insert into public.groups(teacher_id,grade_level_id,name,subject_name,capacity,monthly_fee_egp,materials_fee_egp) values($1,'70000000-0000-0000-0000-000000000001','فيزياء','فيزياء',1,700,300) returning id",[ids.teacher])).rows[0].id;
 const occupied=(await s.query('select public.secretary_enroll($1,$2) id',[target,failing])).rows[0].id;
 const source=(await s.query("select id from public.group_enrollments where student_id=$1 and group_id=$2 and status='active'",[older,ids.group])).rows[0].id;
 await assert.rejects(s.query('select public.secretary_transfer($1,$2)',[source,target]));checks++;
 ok((await s.query('select status from public.group_enrollments where id=$1',[source])).rows[0].status,'active');
 await s.query('select public.secretary_enroll($1,$2,$3)',[target,failing,occupied]);
 await s.query('select public.secretary_transfer($1,$2)',[source,target]);
 ok((await s.query('select status from public.group_enrollments where id=$1',[source])).rows[0].status,'inactive');
 ok((await s.query("select count(*)::int n from public.group_enrollments where student_id=$1 and group_id=$2 and status='active'",[older,target])).rows[0].n,1);
 ok((await s.query('select amount_egp from public.invoices where student_id=$1 and group_id=$2',[older,target])).rows[0].amount_egp,'1000.00');
 const simpleGroup='40000000-0000-0000-0000-000000000099',newStudent='30000000-0000-0000-0000-000000000099';
 await s.query("select public.secretary_create_group($1,'فيزياء ٣ ثانوي','فيزياء',700,300)",[simpleGroup]);
 await s.query("select public.secretary_create_group($1,'فيزياء ٣ ثانوي','فيزياء',700,300)",[simpleGroup]);
 ok((await s.query('select capacity from public.groups where id=$1',[simpleGroup])).rows[0].capacity,2147483647);
 await assert.rejects(s.query("select public.secretary_create_student($1,null,'أحمد')",[newStudent]));checks++;
 ok((await s.query('select count(*)::int n from public.students where id=$1',[newStudent])).rows[0].n,0);
 await assert.rejects(other.query("select public.secretary_create_student($1,$2,'أحمد')",[newStudent,simpleGroup]));checks++;
 await s.query("select public.secretary_create_student($1,$2,'أحمد','01012345678','01098765432')",[newStudent,simpleGroup]);
 await s.query("select public.secretary_create_student($1,$2,'أحمد','01012345678','01098765432')",[newStudent,simpleGroup]);
 ok((await s.query('select count(*)::int n from public.students where id=$1',[newStudent])).rows[0].n,1);
 ok((await s.query('select count(*)::int n from public.group_enrollments where student_id=$1',[newStudent])).rows[0].n,1);
 ok((await s.query('select amount_egp from public.invoices where student_id=$1',[newStudent])).rows[0].amount_egp,'1000.00');
 const rejected='30000000-0000-0000-0000-000000000098';
 await s.query('update public.groups set capacity=1 where id=$1',[simpleGroup]);
 await assert.rejects(s.query("select public.secretary_create_student($1,$2,'محمد')",[rejected,simpleGroup]));checks++;
 ok((await s.query('select count(*)::int n from public.students where id=$1',[rejected])).rows[0].n,0);
 console.log(JSON.stringify({suite:'local proposed group pricing',checks,pass:true,hostedWrites:0}));
} finally {await pg.close();}
