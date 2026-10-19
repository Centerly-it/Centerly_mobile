// Local disposable PostgreSQL only. Does not read app env, credentials or hosted state.
import assert from 'node:assert/strict';
import {completionContext,ids} from './completion_context.mjs';
import {checkReads} from './completion_reads.mjs';
const c=await completionContext();let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const deny=async(p,pattern)=>{await assert.rejects(p,pattern);checks++;};
try {
 const {a,b,s,pg,call,date}=c;
 await checkReads(c,eq);
 const queries=[['public.get_teacher_student_profile($1)',[ids.student]],
  ["public.get_teacher_student_academics($1,'exams',$2,$2)",[ids.student,date]],
  ['public.get_teacher_student_attendance($1,$2,$2)',[ids.student,date]],
  ['public.get_teacher_finance($1,$1)',[date]],['public.get_teacher_student_note($1)',[ids.student]],
  ['public.list_teacher_secretaries()',[]],['public.list_teacher_notifications()',[]],
  ['public.get_teacher_calendar($1,$1)',[date]]];
 for(const [query,args] of queries) {
  await deny(call(s,query,args),/FORBIDDEN_ROLE/);
  await pg.admin.query('set role anon');await deny(call(pg.admin,query,args),/permission denied/);await pg.admin.query('reset role');
 }
 for(const [query,args] of queries.filter(([q])=>q.includes('student_'))) await deny(call(b,query,args),/NOT_FOUND/);
 eq((await call(b,'public.get_teacher_finance($1,$1)',[date])).rows,[]);
 eq((await call(b,'public.list_teacher_notifications()')).rows,[]);
 await deny(call(a,"public.get_teacher_finance($1,$1,'invoices',$2)",[date,ids.otherStudent]),/NOT_FOUND/);
 await deny(call(a,"public.get_teacher_finance($1,$1,'payments',null,null,$2)",[date,'20000000-0000-0000-0000-000000000002']),/NOT_FOUND/);
 await deny(call(a,"public.get_teacher_student_academics($1,'exams',$2,$2,$3)",[ids.student,date,ids.otherGroup]),/NOT_FOUND/);
 for(const query of ["public.get_teacher_student_academics($1,'invalid',current_date,current_date)",
  'public.get_teacher_student_attendance($1,current_date,current_date+366)',
  "public.get_teacher_student_attendance($1,current_date,current_date,null,'invalid')"])
  await deny(call(a,query,[ids.student]),/VALIDATION_ERROR/);
 await deny(call(a,"public.get_teacher_finance(current_date,current_date,'invalid')"),/VALIDATION_ERROR/);
 await deny(call(a,'public.list_teacher_secretaries(null,101)'),/VALIDATION_ERROR/);
 await deny(call(a,'public.list_teacher_notifications(null,0)'),/VALIDATION_ERROR/);
 await deny(call(a,'public.get_teacher_calendar(current_date,current_date+62)'),/VALIDATION_ERROR/);
 const metadata=(await pg.admin.query(`select count(*)::int as n from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname in ('get_teacher_student_profile','get_teacher_student_academics',
  'get_teacher_student_attendance','get_teacher_finance','get_teacher_student_note','list_teacher_secretaries',
  'list_teacher_notifications','get_teacher_calendar') and prosecdef and proconfig @> array['search_path=""']
  and not has_function_privilege('anon',p.oid,'EXECUTE') and has_function_privilege('authenticated',p.oid,'EXECUTE')`)).rows[0];eq(metadata.n,8);
 await pg.admin.query("update public.teachers set status='inactive' where id=$1",[ids.teacher]);
 for(const [q,args] of queries) await deny(call(a,q,args),/ACCOUNT_INACTIVE/);
 await pg.admin.query("update public.teachers set status='active',subscription_status='inactive' where id=$1",[ids.teacher]);
 for(const [q,args] of queries) await deny(call(a,q,args),/SUBSCRIPTION_INACTIVE/);
 console.log(`PASS: ${checks} completion-package assertions; all proposals local only.`);
} finally {await c.pg.close();}
