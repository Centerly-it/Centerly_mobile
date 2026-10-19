// Exports only disposable synthetic database output. Never connects to Supabase.
import {writeFile,mkdir} from 'node:fs/promises';
import {completionContext,ids} from './completion_context.mjs';
const c=await completionContext();
try {
 const {a,call,date}=c;
 const queries={profile:['public.get_teacher_student_profile($1)',[ids.student]],
  exams:["public.get_teacher_student_academics($1,'exams',$2,$2)",[ids.student,date]],
  assignments:["public.get_teacher_student_academics($1,'assignments',$2,$2)",[ids.student,date]],
  attendance:['public.get_teacher_student_attendance($1,current_date-60,current_date)',[ids.student]],
  invoices:['public.get_teacher_finance($1,$1)',[date]],payments:["public.get_teacher_finance($1,$1,'payments')",[date]],
  note:['public.get_teacher_student_note($1)',[ids.student]],secretaries:['public.list_teacher_secretaries()',[]],
  notifications:['public.list_teacher_notifications()',[]]};
 const result={source:'disposable local PostgreSQL, synthetic only',date};
 for(const [name,[query,args]] of Object.entries(queries))result[name]=await call(a,query,args);
 const dir=new URL('../../test/fixtures/',import.meta.url);await mkdir(dir,{recursive:true});
 await writeFile(new URL('teacher_completion.json',dir),JSON.stringify(result,null,2)+'\n');
 console.log('PASS: exported synthetic SQL contract responses for Flutter boundary tests; no hosted access.');
} finally {await c.pg.close();}
