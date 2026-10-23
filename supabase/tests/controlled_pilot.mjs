// Isolated PostgreSQL role simulation, never hosted SDK/browser acceptance.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFile} from 'node:fs/promises';
import {completionContext,ids} from './completion_context.mjs';
const manifest=JSON.parse(await readFile(new URL('../proposals/controlled_pilot/review-manifest.json',import.meta.url),'utf8'));
for(const f of manifest.files)assert.equal(createHash('sha256').update(await readFile(new URL('../../'+f.path,import.meta.url))).digest('hex'),f.sha256);
const {pg,a,b,s,date,call,invoice}=await completionContext({through:'202610220002'});
let checks=0;
const eq=(x,y)=>{assert.deepEqual(x,y);checks++;};
const deny=async(c,q,args=[],error=/CONFLICT/)=>{await assert.rejects(()=>call(c,q,args),error);checks++;};
try {
 const preview=await readFile(new URL('../../'+manifest.deploymentPreview.path,import.meta.url));
 assert.equal(createHash('sha256').update(preview).digest('hex'),manifest.deploymentPreview.sha256);
 await pg.admin.query(preview.toString());
 const note=await call(a,"public.save_teacher_note($1,'History')",[ids.student]);
 const compare=async(expected)=>{
  const detail=(await call(a,'public.get_teacher_invoice_detail($1)',[invoice])).invoice;
  const finance=(await call(a,'public.get_teacher_finance($1,$1)',[date])).rows[0];
  const secretary=(await call(s,"public.secretary_browse('invoices')")).rows[0];
  for(const row of [detail,finance,secretary]) {
   eq(row.original_amount_egp,'100.01');eq(row.ledger_net_egp,expected[0]);eq(row.payable_balance_egp,expected[1]);
  }
  eq(secretary.balance_egp,expected[1]);
 };
 await compare(['0.00','100.01']);
 const paid=await call(s,"public.record_payment($1,40.01,'cash',gen_random_uuid())",[invoice]);
 await compare(['40.01','60.00']);
 const due=(await call(a,'public.list_teacher_finance_dues($1,$1)',[date])).rows[0];
 eq(due.original_amount_egp,'100.01');eq(due.ledger_net_egp,'40.01');eq(due.payable_balance_egp,'60.00');
 await call(s,"public.reverse_payment($1,'Correction')",[paid]);
 await pg.admin.query("update public.invoices set status='void',void_reason='Local test' where id=$1",[invoice]);
 await compare(['0.00','0.00']);
 eq((await call(a,'public.list_teacher_finance_dues($1,$1)',[date])).total_count,0);
 const open=await call(s,"public.create_invoice($1,20,$2,'OPEN')",[ids.student,date]);
 const prior=await call(s,"public.record_payment($1,5,'cash',gen_random_uuid())",[open]);
 await pg.admin.query('update public.students set archived_at=clock_timestamp() where id=$1',[ids.student]);
 eq(await call(s,'public.generate_sessions($1::date-40,$1)',[date]),0);
 const preserved=(await pg.admin.query(`select jsonb_build_object('attendance',(select jsonb_agg(to_jsonb(x)) from public.attendance x),
  'exams',(select jsonb_agg(to_jsonb(x)) from public.exams x),'assignments',(select jsonb_agg(to_jsonb(x)) from public.assignments x),
  'notes',(select jsonb_agg(to_jsonb(x)) from public.teacher_notes x)) value`)).rows[0].value;
 await deny(s,"public.record_payment($1,1,'cash',gen_random_uuid())",[open]);
 await call(s,"public.reverse_payment($1,'Archived correction')",[prior]);
 eq((await call(a,'public.get_teacher_invoice_detail($1)',[open])).invoice.ledger_net_egp,'0.00');
 const history=async()=>({
  profile:await call(a,'public.get_teacher_student_profile($1)',[ids.student]),
  attendance:await call(a,'public.get_teacher_student_attendance($1,$2::date-40,$2)',[ids.student,date]),
  exams:await call(a,"public.get_teacher_student_academics($1,'exams',$2,$2)",[ids.student,date]),
  assignments:await call(a,"public.get_teacher_student_academics($1,'assignments',$2,$2)",[ids.student,date]),
  note:await call(a,'public.get_teacher_student_note($1)',[ids.student]),
  finance:await call(a,"public.get_teacher_finance($2,$2,'invoices',$1)",[ids.student,date]),
 });
 const h=await history();assert.ok(h.profile.student.archived_at);checks++;
 eq(h.attendance.total_count,1);eq(h.exams.total_count,3);eq(h.assignments.total_count,1);
 eq(h.note.note.content,'History');eq(h.finance.total_count,2);
 for(const [q,args] of [
  ['public.get_teacher_student_profile($1)',[ids.student]],
  ['public.get_teacher_student_attendance($1,$2,$2)',[ids.student,date]],
  ["public.get_teacher_student_academics($1,'exams',$2,$2)",[ids.student,date]],
  ['public.get_teacher_student_note($1)',[ids.student]],
  ["public.get_teacher_finance($2,$2,'invoices',$1)",[ids.student,date]],
 ]) {await deny(b,q,args,/NOT_FOUND/);await deny(s,q,args,/FORBIDDEN/);}
 await deny(a,"public.save_teacher_note($1,'Changed',$2)",[ids.student,note]);
 await deny(s,'public.create_invoice($1,10,$2,\'ARCHIVED\')',[ids.student,date]);
 await deny(s,"public.set_attendance($1,$2,'present')",[ids.session,ids.student]);
 await deny(s,'public.secretary_enroll($1,$2)',[ids.group,ids.student]);
 for(const q of ["update public.students set full_name='Changed' where id=$1", "update public.students set archived_at=null where id=$1", "update public.exams set title='Changed' where student_id=$1", "update public.assignments set status='submitted' where student_id=$1"])
  {await assert.rejects(()=>s.query(q,[ids.student]),/CONFLICT/);checks++;}
 eq((await call(a,'public.get_teacher_student_note($1)',[ids.student])).note.content,'History');
 eq((await pg.admin.query("select count(*)::int n from public.audit_events where action='note_saved'")).rows[0].n,1);
 eq((await pg.admin.query(`select jsonb_build_object('attendance',(select jsonb_agg(to_jsonb(x)) from public.attendance x),
  'exams',(select jsonb_agg(to_jsonb(x)) from public.exams x),'assignments',(select jsonb_agg(to_jsonb(x)) from public.assignments x),
  'notes',(select jsonb_agg(to_jsonb(x)) from public.teacher_notes x)) value`)).rows[0].value,preserved);
 await pg.admin.query('set role anon');
 await deny(pg.admin,'public.get_teacher_invoice_detail($1)',[invoice],/permission denied/);
 await pg.admin.query('reset role');
 console.log(JSON.stringify({suite:'controlled-pilot',mode:'local SQL-role simulation',checks,status:'PASS'}));
} finally {await pg.close();}
