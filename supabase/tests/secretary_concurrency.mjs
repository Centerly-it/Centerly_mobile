import assert from 'node:assert/strict';import {startPostgres} from './postgres.mjs';
const pg=await startPostgres();let checks=0;const scalar=async(c,q,p)=>Object.values((await c.query(q,p)).rows[0])[0];const t='10000000-0000-0000-0000-000000000001',s='20000000-0000-0000-0000-000000000001',g='40000000-0000-0000-0000-000000000001',student='30000000-0000-0000-0000-000000000001',session='50000000-0000-0000-0000-000000000001';
try{const a=await pg.connect(s),b=await pg.connect(s);await pg.admin.query(`update public.groups set capacity=2 where id=$1`,[g]);const next=[];for(let i=0;i<2;i++)next.push(await scalar(pg.admin,`insert into public.students(teacher_id,full_name) values($1,$2) returning id`,[t,'race '+i]));
let results=await Promise.allSettled([scalar(a,'select public.secretary_enroll($1,$2)',[g,next[0]]),scalar(b,'select public.secretary_enroll($1,$2)',[g,next[1]])]);assert.equal(results.filter(r=>r.status==='fulfilled').length,1);checks++;assert.equal(await scalar(pg.admin,`select count(*)::int from public.group_enrollments where group_id=$1 and status='active'`,[g]),2);checks++;
let stamp=await scalar(pg.admin,'select updated_at::text from public.attendance where session_id=$1',[session]);results=await Promise.allSettled([scalar(a,"select public.secretary_set_attendance($1,$2,'present',$3)",[session,student,stamp]),scalar(b,"select public.secretary_set_attendance($1,$2,'absent',$3)",[session,student,stamp])]);assert.equal(results.filter(r=>r.status==='fulfilled').length,1);checks++;assert.equal(await scalar(pg.admin,'select count(*)::int from public.attendance_change_log'),1);checks++;
await a.query('select public.finalize_attendance($1)',[session]);stamp=await scalar(pg.admin,'select updated_at::text from public.attendance where session_id=$1',[session]);await assert.rejects(a.query("select public.secretary_set_attendance($1,$2,'excused',$3)",[session,student,stamp]),/ATTENDANCE_CORRECTION_REASON_REQUIRED/);checks++;await a.query("select public.secretary_set_attendance($1,$2,'excused',$3,'correction')",[session,student,stamp]);
const inv=await scalar(a,"select public.create_invoice($1,100.10,current_date,'NATIVE-RACE')",[student]);const key=crypto.randomUUID();results=await Promise.all([scalar(a,"select public.record_payment($1,40.05,'cash',$2)",[inv,key]),scalar(b,"select public.record_payment($1,40.05,'cash',$2)",[inv,key])]);assert.equal(results[0],results[1]);checks++;
const original=results[0];results=await Promise.allSettled([scalar(a,"select public.record_payment($1,60.05,'cash',$2)",[inv,crypto.randomUUID()]),scalar(b,"select public.record_payment($1,60.05,'cash',$2)",[inv,crypto.randomUUID()])]);assert.equal(results.filter(r=>r.status==='fulfilled').length,1);checks++;
assert.equal(await scalar(a,"select public.secretary_browse('invoices',jsonb_build_object('id',$1::text))->'rows'->0->>'balance_egp'",[inv]),'0.00');checks++;
results=await Promise.all([scalar(a,"select public.reverse_payment($1,'correction A')",[original]),scalar(b,"select public.reverse_payment($1,'correction B')",[original])]);assert.equal(results[0],results[1]);checks++;
const teacher=await pg.connect(t);const report=await scalar(teacher,"select public.get_teacher_finance(p_from=>current_date,p_to=>current_date,p_kind=>'invoices',p_student_id=>$1)",[student]);assert.ok(JSON.stringify(report).includes('40.05'));checks++;
const summary=await scalar(a,'select public.secretary_dashboard()');assert.equal(summary.outstanding_egp,'40.05');checks++;

const schedule=await scalar(a,"select public.add_schedule($1,extract(dow from current_date+7)::int,'16:00','17:00',current_date+7)",[g]);
results=await Promise.allSettled([scalar(a,"select public.secretary_revise_schedule($1,current_date+14,extract(dow from current_date+14)::int,'18:00','19:00')",[schedule]),scalar(b,"select public.generate_sessions(current_date+14,current_date+14)")]);
assert.equal(results[1].status,'fulfilled');checks++;
if(results[0].status==='rejected')assert.match(results[0].reason.message,/CONFLICT/);checks++;
assert.equal(await scalar(pg.admin,"select count(*)::int from public.sessions where group_id=$1 and local_date=current_date+14",[g]),1);checks++;
const future=await scalar(pg.admin,"select id from public.sessions where group_id=$1 and local_date=current_date+14",[g]);
stamp=await scalar(pg.admin,'select updated_at::text from public.attendance where session_id=$1 and student_id=$2',[future,student]);
await a.query("select public.secretary_set_attendance($1,$2,'present',$3)",[future,student,stamp]);
results=await Promise.allSettled([a.query("select public.cancel_session($1,'cancel A')",[future]),b.query("select public.cancel_session($1,'cancel B')",[future])]);assert.equal(results.filter(r=>r.status==='fulfilled').length,1);checks++;
assert.equal(await scalar(pg.admin,'select status from public.attendance where session_id=$1 and student_id=$2',[future,student]),'present');checks++;
stamp=await scalar(pg.admin,'select updated_at::text from public.attendance where session_id=$1 and student_id=$2',[future,student]);await assert.rejects(a.query("select public.secretary_set_attendance($1,$2,'absent',$3)",[future,student,stamp]),/CONFLICT/);checks++;
await a.query("insert into public.exams(teacher_id,student_id,title,held_on,score_percent) values($1,$2,'missing',current_date,null),($1,$2,'zero',current_date,0)",[t,student]);
const academic=await scalar(teacher,"select public.get_teacher_student_academics(p_id=>$1,p_kind=>'exams',p_from=>current_date,p_to=>current_date)",[student]);assert.ok(academic.rows.some(r=>r.score_percent===null));checks++;assert.ok(academic.rows.some(r=>r.score_percent!==null&&Number(r.score_percent)===0));checks++;
const first=await scalar(a,"select public.secretary_browse('students','{}','',null,1)");assert.equal(first.rows.length,1);checks++;assert.ok(first.next_cursor);checks++;
const second=await scalar(a,"select public.secretary_browse('students','{}','',$1,1)",[first.next_cursor]);assert.notEqual(second.rows[0].id,first.rows[0].id);checks++;assert.equal(second.total_count,first.total_count);checks++;
assert.equal((await scalar(a,"select public.secretary_browse('students','{}','%')")).total_count,0);checks++;
await pg.admin.query("insert into public.notifications(teacher_id,recipient_id,type) values($1,$2,'session_cancelled'),($1,$1,'session_cancelled')",[t,s]);const notifications=await scalar(a,"select public.secretary_browse('notifications')");assert.equal(notifications.rows.length,1);checks++;assert.equal(notifications.unread_count,1);checks++;
await a.query('select public.mark_notification_read($1)',[notifications.rows[0].id]);assert.equal((await scalar(a,"select public.secretary_browse('notifications')")).unread_count,0);checks++;

for(const [date,weekday,utc] of [['2026-01-01',4,'2026-01-01T16:00:00Z'],['2026-07-01',3,'2026-07-01T15:00:00Z']]){
 const scheduleId=await scalar(a,"select public.add_schedule($1,$2,'18:00','19:00',$3,$3)",[g,weekday,date]);
 assert.equal(await scalar(a,'select public.generate_sessions($1,$1)',[date]),1);checks++;
 assert.equal(await scalar(a,'select public.generate_sessions($1,$1)',[date]),0);checks++;
 const starts=await scalar(pg.admin,'select starts_at from public.sessions where schedule_id=$1',[scheduleId]);assert.equal(starts.toISOString(),utc.replace('Z','.000Z'));checks++;
}
for(const offset of [22,20,21])await pg.admin.query("insert into public.sessions(teacher_id,group_id,local_date,starts_at,ends_at) values($1,$2,current_date+$3::int,(current_date+$3::int+time '18:00') at time zone 'Africa/Cairo',(current_date+$3::int+time '19:00') at time zone 'Africa/Cairo')",[t,g,offset]);
const ordered=await scalar(a,"select public.secretary_browse('sessions',jsonb_build_object('from',current_date+20,'to',current_date+22),'',null,1)");assert.equal(ordered.total_count,3);checks++;
const later=await scalar(a,"select public.secretary_browse('sessions',jsonb_build_object('from',current_date+20,'to',current_date+22),'',$1,1)",[ordered.next_cursor]);assert.ok(ordered.rows[0].starts_at<later.rows[0].starts_at);checks++;
console.log(JSON.stringify({pass:true,checks,engine:'independent PostgreSQL 17 connections',hosted:false,teacherContractReconciliation:true}));}finally{await pg.close();}
