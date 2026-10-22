import assert from 'node:assert/strict';import {readFile,readdir} from 'node:fs/promises';import {createHash} from 'node:crypto';
import {PGlite} from '@electric-sql/pglite';
const canonical=new URL('../',import.meta.url);
const manifest=JSON.parse(await readFile(new URL('../schema-manifest.json',import.meta.url),'utf8'));
const db=new PGlite();let checks=0;
try{
await db.exec(`create role anon;create role authenticated;create schema auth;create table auth.users(id uuid primary key);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema auth to authenticated;grant execute on function auth.uid() to authenticated;`);
assert.deepEqual((await readdir(new URL('migrations/',canonical))).sort().slice(0,manifest.migrations.length),manifest.migrations.map(m=>m.file));checks++;
for(const m of manifest.migrations){const s=await readFile(new URL('migrations/'+m.file,canonical),'utf8');assert.equal(createHash('sha256').update(s.replaceAll('\r\n','\n')).digest('hex'),m.sha256);await db.exec(s);checks++;}
await db.exec(await readFile(new URL('tests/fixtures.sql',canonical),'utf8'));
const scalar=async(sql,args)=>Object.values((await db.query(sql,args)).rows[0])[0];
const actor=async id=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[id]);await db.exec('set role authenticated');};
const deny=async(sql,message)=>{await assert.rejects(db.query(sql),e=>!message||e.message.includes(message));checks++;};
const eq=async(sql,value)=>{assert.equal(await scalar(sql),value);checks++;};
const t='10000000-0000-0000-0000-000000000001',s='20000000-0000-0000-0000-000000000001',foreign='20000000-0000-0000-0000-000000000002',student='30000000-0000-0000-0000-000000000001',group='40000000-0000-0000-0000-000000000001',session='50000000-0000-0000-0000-000000000001';
await actor(t);await deny("select public.secretary_dashboard()",'FORBIDDEN_ROLE');await deny("select public.secretary_browse('students')",'FORBIDDEN_ROLE');await deny(`select public.secretary_enroll('${group}','${student}')`,'FORBIDDEN_ROLE');
await actor(foreign);await eq(`select (public.secretary_browse('students','{"id":"${student}"}')->>'total_count')::int`,0);await deny(`select public.secretary_set_attendance('${session}','${student}','present')`,'NOT_FOUND');
await actor(s);await eq("select (public.secretary_browse('students')->>'total_count')::int",1);await deny("select public.secretary_browse('teachers')",'VALIDATION_ERROR');await deny("select public.secretary_browse('students','{\"teacher_id\":\"x\"}')",'VALIDATION_ERROR');await deny("select public.secretary_browse('students','{}','',null,101)",'VALIDATION_ERROR');
let a=await scalar(`select updated_at::text from public.attendance where session_id='${session}' and student_id='${student}'`);
await db.query(`select public.secretary_set_attendance($1,$2,'present',$3)`,[session,student,a]);checks++;
await deny(`select public.secretary_set_attendance('${session}','${student}','absent','${a}')`,'CONFLICT');
await db.query(`select public.finalize_attendance('${session}')`);a=await scalar(`select updated_at::text from public.attendance where session_id='${session}'`);
await deny(`select public.secretary_set_attendance('${session}','${student}','absent','${a}')`,'ATTENDANCE_CORRECTION_REASON_REQUIRED');
await db.query(`select public.secretary_set_attendance($1,$2,'absent',$3,'register correction')`,[session,student,a]);await eq('select count(*)::int from public.attendance_change_log',2);
const inv=await scalar(`select public.create_invoice('${student}',100.10,current_date,'SECRETARY-TEST')`);const key='60000000-0000-0000-0000-000000000099';
const payment=await scalar(`select public.record_payment('${inv}',40.05,'cash','${key}')`);await eq(`select public.record_payment('${inv}',40.05,'cash','${key}')`,payment);await deny(`select public.record_payment('${inv}',60.06,'cash',gen_random_uuid())`,'CONFLICT');
await eq(`select public.secretary_browse('invoices','{"id":"${inv}"}')->'rows'->0->>'balance_egp'`,'60.05');
await db.query(`select public.reverse_payment('${payment}','correction')`);await eq(`select public.secretary_browse('invoices','{"id":"${inv}"}')->'rows'->0->>'balance_egp'`,'100.10');
await deny('update public.payments set amount_egp=1');await deny(`select public.save_teacher_note('${student}','forbidden')`,'FORBIDDEN_ROLE');
await db.exec('reset role');await db.query(`update public.groups set capacity=1 where id='${group}'`);const next=await scalar(`insert into public.students(teacher_id,full_name) values('${t}','other') returning id`);await actor(s);await deny(`select public.secretary_enroll('${group}','${next}')`,'CONFLICT');
const enrollment=await scalar(`select id from public.group_enrollments where group_id='${group}'`);await db.query(`select public.secretary_enroll('${group}','${student}','${enrollment}')`);await eq(`select status from public.group_enrollments where id='${enrollment}'`,'inactive');await eq(`select left_at is not null from public.group_enrollments where id='${enrollment}'`,true);
await db.exec('reset role');await db.query(`update public.secretaries set status='inactive' where id='${s}'`);await actor(s);await deny('select public.secretary_dashboard()','ACCOUNT_INACTIVE');await db.exec('reset role');await db.exec(`update public.secretaries set status='active' where id='${s}';update public.teachers set subscription_status='inactive' where id='${t}'`);await actor(s);await deny('select public.secretary_dashboard()','SUBSCRIPTION_INACTIVE');
console.log(JSON.stringify({pass:true,checks,baselineMigrations:manifest.migrations.length,backend:'disposable PGlite',hosted:false}));
}finally{await db.close();}
