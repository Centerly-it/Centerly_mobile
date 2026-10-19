import assert from 'node:assert/strict';
import {ids} from './completion_context.mjs';
export async function checkReads(c,eq) {
 const {a,s,pg,call,date}=c;
 const academic=(kind='exams',cursor=null)=>call(a,'public.get_teacher_student_academics($1,$2,$3,$3,null,$4,1)',[ids.student,kind,date,cursor]);
 let d=await academic();eq(d.total_count,3);eq(d.rows.length,1);eq(d.summary.missing,1);
 eq(d.summary.scored,2);eq(d.summary.average_percent,'50.00');eq(d.summary.below_50,1);eq(d.summary.from_80_to_100,1);
 const seen=[];while(d) {seen.push(...d.rows);d=d.next_cursor?await academic('exams',d.next_cursor):null;}
 eq(seen.length,3);eq(new Set(seen.map(r=>r.id)).size,3);
 eq(seen.find(r=>r.title==='صفر حقيقي').score_percent,'0.00');eq(seen.find(r=>r.title==='اختبار عربي').score_percent,null);
 d=await academic('assignments');eq(d.summary.late,1);eq(d.rows[0].status,'late');
 d=await call(a,'public.get_teacher_student_academics($1,\'exams\',$2,$2,$3)',[ids.student,date,ids.group]);eq(d.rows,[]);
 const history=()=>call(a,"public.get_teacher_student_attendance($1,current_date-60,current_date)",[ids.student]);
 d=await history();eq(d.summary.not_marked,1);eq(d.summary.marked_denominator,0);
 await call(s,"public.finalize_attendance($1)",[ids.session]);
 await call(s,"public.set_attendance($1,$2,'excused','Local audited correction')",[ids.session,ids.student]);
 d=await history();eq(d.summary.excused,1);eq(d.summary.marked_denominator,1);eq(d.rows[0].marked_by_name,'Test secretary A');
 await pg.admin.query(`update public.sessions set status='cancelled',cancel_reason='Retain',cancelled_by=$1,cancelled_at=now() where id=$2`,[ids.teacher,ids.session]);
 d=await history();eq(d.rows.length,1);eq(d.summary.excused,0);eq(d.summary.marked_denominator,0);eq(d.summary.cancelled_records,1);
 let f=await call(a,'public.get_teacher_finance($1,$1)',[date]);
 eq(f.summary.invoiced_egp,'100.01');eq(f.summary.outstanding_egp,'100.01');eq(f.summary.period_net_collected_egp,'0.00');
 eq(f.rows[0].net_paid_egp,'0.00');eq(f.rows[0].outstanding_egp,'100.01');
 f=await call(a,"public.get_teacher_finance($1,$1,'payments')",[date]);
 eq(f.rows.length,2);eq(f.rows.find(r=>r.reversal_of).signed_amount_egp,'-25.01');eq(f.rows[0].collected_by_name,'Test secretary A');
 f=await call(a,"public.get_teacher_finance($1,$1,'invoices',null,$2)",[date,ids.group]);eq(f.rows,[]);eq(f.summary.invoiced_egp,'0.00');
 d=await call(a,'public.get_teacher_student_note($1)',[ids.student]);eq(d.note,null);
 const stamp=await call(a,"public.save_teacher_note($1,'ملاحظة محلية')",[ids.student]);
 d=await call(a,'public.get_teacher_student_note($1)',[ids.student]);eq(d.note.content,'ملاحظة محلية');assert.ok(d.note.updated_at);
 await assert.rejects(call(a,"public.save_teacher_note($1,'stale',null)",[ids.student]),/CONFLICT/);eq(true,true);
 await call(a,"public.save_teacher_note($1,'Updated',$2)",[ids.student,d.note.updated_at]);
 const removal=await call(a,'public.request_secretary_removal($1)',[ids.secretary]);
 eq(await call(a,'public.request_secretary_removal($1)',[ids.secretary]),removal);
 d=await call(a,'public.list_teacher_secretaries()');eq(d.rows[0].email,'a@example.invalid');eq(d.rows[0].removal_request.status,'pending');
 await pg.admin.query(`insert into public.notifications(teacher_id,recipient_id,type,payload) values
  ($1,$1,'admin_event','{"secret":"must not leak","session_id":"sample"}'),($1,$2,'private_secretary','{}')`,[ids.teacher,ids.secretary]);
 d=await call(a,'public.list_teacher_notifications()');eq(d.rows.length,3);
 eq(d.rows.find(r=>r.type==='admin_event').payload,{session_id:'sample'});eq(d.unread_count,3);
 eq(d.rows.filter(r=>r.type==='payment_collected').length,1);eq(d.rows.filter(r=>r.type==='payment_reversed').length,1);
 for(const row of d.rows) await call(a,'public.mark_notification_read($1)',[row.id]);
 eq((await call(a,'public.list_teacher_notifications()')).unread_count,0);
 d=await call(a,'public.get_teacher_calendar(current_date-60,current_date)');eq(d.sessions[0].status,'cancelled');
 await pg.admin.query(`insert into public.sessions(teacher_id,group_id,local_date,starts_at,ends_at)
 values($1,$2,current_date,now()-interval '1 hour',now()+interval '1 hour'),
 ($1,$2,current_date,now()+interval '1 day',now()+interval '2 days'),
 ($1,$2,current_date,now()-interval '2 days',now()-interval '1 day')`,[ids.teacher,ids.group]);
 d=await call(a,'public.get_teacher_calendar(current_date,current_date)');eq(d.sessions.map(r=>r.status).sort(),['completed','ongoing','upcoming']);
 eq(d.sessions.every(r=>r.stored_status==='upcoming'),true);eq(typeof d.synced_at,'string');
}
