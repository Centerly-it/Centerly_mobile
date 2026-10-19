// Isolated native PostgreSQL only. Never uses hosted config/credentials or CLI.
import assert from 'node:assert/strict';
import {startPostgres} from './postgres.mjs';
const pg=await startPostgres();
let count=0;
const eq=(actual,expected)=>{assert.deepEqual(actual,expected);count++;};
try {
  // startPostgres applies the immutable managed migration, including session detail.
  const teacher='10000000-0000-0000-0000-000000000001',other='10000000-0000-0000-0000-000000000002';
  const secretary='20000000-0000-0000-0000-000000000001',session='50000000-0000-0000-0000-000000000001';
  const a=await pg.connect(teacher),b=await pg.connect(other),s=await pg.connect(secretary);
  const detail=async(client=a,params=[session,null,null,30])=>(await client.query(
    'select public.get_teacher_session_detail($1,$2,$3,$4) as value',params)).rows[0].value;
  let result=await detail();
  eq(result.session.group_name,'A'); eq(result.attendance_counts.not_marked,1);
  eq(result.attendance[0].status,'not_marked'); eq(result.attendance_counts.absent,0);
  eq(result.next_cursor,null); eq(result.filtered_count,1);
  await assert.rejects(detail(b),/NOT_FOUND/);count++;
  await assert.rejects(detail(s),/FORBIDDEN_ROLE/);count++;
  await assert.rejects(detail(a,[null,null,null,30]),/VALIDATION_ERROR/);count++;
  await assert.rejects(detail(a,[session,'unknown',null,30]),/VALIDATION_ERROR/);count++;
  await assert.rejects(detail(a,[session,null,null,101]),/VALIDATION_ERROR/);count++;
  await assert.rejects(detail(a,[session,null,null,0]),/VALIDATION_ERROR/);count++;
  eq((await detail(a,[session,'absent',null,30])).attendance,[]);
  await pg.admin.query(`insert into public.students(id,teacher_id,full_name)
    values('30000000-0000-0000-0000-000000000099','${teacher}','Second local student');
    insert into public.attendance(teacher_id,session_id,student_id)
    values('${teacher}','${session}','30000000-0000-0000-0000-000000000099')`);
  const first=await detail(a,[session,null,null,1]);
  const second=await detail(a,[session,null,first.next_cursor,1]);
  eq(first.attendance.length,1);eq(second.attendance.length,1);eq(second.next_cursor,null);
  assert.notEqual(first.attendance[0].id,second.attendance[0].id);count++;
  await s.query('select public.finalize_attendance($1)',[session]);
  await s.query('select public.set_attendance($1,$2,$3,$4)',[
    session,'30000000-0000-0000-0000-000000000099','excused','Audited local correction']);
  result=await detail();
  eq(result.attendance_counts.not_marked,1);eq(result.attendance_counts.excused,1);
  eq(result.attendance.find(r=>r.status==='excused').marked_by_name,'Test secretary A');
  assert.ok(result.session.attendance_finalized_at&&result.synced_at);count++;
  const pending=await detail(a,[session,'not_marked',null,30]);
  eq(pending.filtered_count,1);eq(pending.attendance.length,1);
  await pg.admin.query(`update public.sessions set status='cancelled',cancelled_by='${teacher}',
    cancel_reason='Local retained history',cancelled_at=now() where id='${session}'`);
  result=await detail();
  eq(result.attendance.length,2);eq(result.attendance_counts.not_marked,1);
  eq(result.session.cancelled_by_name,'Test teacher A');eq(result.session.cancel_reason,'Local retained history');
  const grants=(await pg.admin.query(`select has_function_privilege('anon',
    'public.get_teacher_session_detail(uuid,text,uuid,integer)','EXECUTE') as anon,
    has_function_privilege('authenticated','public.get_teacher_session_detail(uuid,text,uuid,integer)','EXECUTE') as auth`)).rows[0];
  eq(grants,{anon:false,auth:true});
  const safety=(await pg.admin.query(`select prosecdef,proconfig from pg_proc
    where oid='public.get_teacher_session_detail(uuid,text,uuid,integer)'::regprocedure`)).rows[0];
  eq(safety,{prosecdef:true,proconfig:['search_path=""']});
  await pg.admin.query(`insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at)
    values('50000000-0000-0000-0000-000000000099','${teacher}','40000000-0000-0000-0000-000000000001',
      current_date,now(),now()+interval '1 hour')`);
  const empty=await detail(a,['50000000-0000-0000-0000-000000000099',null,null,30]);
  eq(empty.attendance,[]);eq(empty.attendance_counts,{present:0,absent:0,excused:0,not_marked:0});
  await pg.admin.query(`update public.teachers set status='inactive' where id='${teacher}'`);
  await assert.rejects(detail(),/ACCOUNT_INACTIVE/);count++;
  await pg.admin.query(`update public.teachers set status='active',subscription_status='inactive' where id='${teacher}'`);
  await assert.rejects(detail(),/SUBSCRIPTION_INACTIVE/);count++;
  console.log(`PASS: ${count} isolated session-detail proposal assertions; no hosted access; only disposable local data.`);
} finally {await pg.close();}
