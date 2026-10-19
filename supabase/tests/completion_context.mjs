import {readFile,readdir,access} from 'node:fs/promises';
import {startPostgres} from './postgres.mjs';
export const ids={teacher:'10000000-0000-0000-0000-000000000001',other:'10000000-0000-0000-0000-000000000002',
 secretary:'20000000-0000-0000-0000-000000000001',student:'30000000-0000-0000-0000-000000000001',
 otherStudent:'30000000-0000-0000-0000-000000000002',group:'40000000-0000-0000-0000-000000000001',
 otherGroup:'40000000-0000-0000-0000-000000000002',session:'50000000-0000-0000-0000-000000000001'};
export async function completionContext() {
 const pg=await startPostgres();
 try {
  if (!await access(new URL('../migrations/202610190003_student_profile.sql',import.meta.url)).then(()=>true,()=>false)) await pg.admin.query(await readFile(new URL('../proposals/202610190003_student_profile.sql',import.meta.url),'utf8'));
  for(const file of (await readdir(new URL('../proposals/teacher_completion/',import.meta.url))).filter(f=>f.endsWith('.sql')).sort())
   await pg.admin.query(await readFile(new URL('../proposals/teacher_completion/'+file,import.meta.url),'utf8'));
  const a=await pg.connect(ids.teacher),b=await pg.connect(ids.other),s=await pg.connect(ids.secretary);
  const date=(await pg.admin.query("select (now() at time zone 'Africa/Cairo')::date::text as d")).rows[0].d;
  const call=async(client,sql,args=[])=>(await client.query('select '+sql+' as value',args)).rows[0].value;
  await s.query(`insert into public.exams(teacher_id,student_id,title,held_on,score_percent)
   values($1,$2,'اختبار عربي',$3,null),($1,$2,'صفر حقيقي',$3,0),($1,$2,'Excellent',$3,100)`,[ids.teacher,ids.student,date]);
  await s.query(`insert into public.assignments(teacher_id,student_id,title,due_on,status)
   values($1,$2,'واجب',$3,'late')`,[ids.teacher,ids.student,date]);
  const invoice=await call(s,'public.create_invoice($1,100.01,$2,\'PKG-1\')',[ids.student,date]);
  const payment=await call(s,"public.record_payment($1,25.01,'cash',gen_random_uuid())",[invoice]);
  await call(s,"public.reverse_payment($1,'Local correction')",[payment]);
  return {pg,a,b,s,date,call,invoice,payment};
 } catch(e) {await pg.close();throw e;}
}
