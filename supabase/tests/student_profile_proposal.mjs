// Disposable local PostgreSQL only; no hosted configuration or business writes.
import assert from 'node:assert/strict';
import {readFile,access} from 'node:fs/promises';
import {startPostgres} from './postgres.mjs';
const pg=await startPostgres(); let count=0;
const eq=(a,b)=>{assert.deepEqual(a,b);count++;};
try {
  if (!await access(new URL('../migrations/202610190003_student_profile.sql',import.meta.url)).then(()=>true,()=>false)) await pg.admin.query(await readFile(new URL('../proposals/202610190003_student_profile.sql',import.meta.url),'utf8'));
  const teacher='10000000-0000-0000-0000-000000000001',other='10000000-0000-0000-0000-000000000002';
  const student='30000000-0000-0000-0000-000000000001',secretary='20000000-0000-0000-0000-000000000001';
  const a=await pg.connect(teacher),b=await pg.connect(other),s=await pg.connect(secretary);
  const profile=async(client=a,args=[student,null,30])=>(await client.query(
    'select public.get_teacher_student_profile($1,$2,$3) as value',args)).rows[0].value;
  let d=await profile();
  eq(d.student.full_name,'Synthetic student A');eq(d.memberships.length,1);eq(d.next_cursor,null);
  eq(d.student.guardian_phone,null);eq(d.student.phone,null);
  eq(d.student.qr_code_value,undefined);eq(d.student.teacher_id,undefined);
  await assert.rejects(profile(b),/NOT_FOUND/);count++;
  await assert.rejects(profile(s),/FORBIDDEN_ROLE/);count++;
  for(const args of [[null,null,30],[student,null,0],[student,null,101]]) {
    await assert.rejects(profile(a,args),/VALIDATION_ERROR/);count++;
  }
  await pg.admin.query(`insert into public.group_enrollments(teacher_id,student_id,group_id,status,left_at)
    values('${teacher}','${student}','40000000-0000-0000-0000-000000000001','inactive',now())`);
  const first=await profile(a,[student,null,1]);
  const second=await profile(a,[student,first.next_cursor,1]);
  eq(first.memberships.length,1);eq(second.memberships.length,1);eq(second.next_cursor,null);
  assert.notEqual(first.memberships[0].id,second.memberships[0].id);count++;
  eq(first.membership_count,2);
  await pg.admin.query(`update public.groups set archived_at=now() where id='40000000-0000-0000-0000-000000000001'`);
  d=await profile();assert.ok(d.memberships.every(r=>r.group_archived_at));count++;
  await pg.admin.query(`update public.students set archived_at=now() where id='${student}'`);
  await assert.rejects(profile(),/NOT_FOUND/);count++;
  await pg.admin.query(`update public.students set archived_at=null where id='${student}';
    update public.teachers set status='inactive' where id='${teacher}'`);
  await assert.rejects(profile(),/ACCOUNT_INACTIVE/);count++;
  const metadata=(await pg.admin.query(`select prosecdef,proconfig,
    has_function_privilege('anon',oid,'EXECUTE') as anon,
    has_function_privilege('authenticated',oid,'EXECUTE') as auth
    from pg_proc where oid='public.get_teacher_student_profile(uuid,uuid,integer)'::regprocedure`)).rows[0];
  eq(metadata,{prosecdef:true,proconfig:['search_path=""'],anon:false,auth:true});
  console.log(`PASS: ${count} local student-profile proposal assertions. Not deployed.`);
} finally {await pg.close();}
