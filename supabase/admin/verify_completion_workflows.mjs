import {randomUUID} from 'node:crypto';
import {querySql} from './trusted_cli.mjs';
export async function verifyCompletionWorkflows(c,eq) {
 const {rpc,request,teacher,secretary,student,group,date}=c;
 const title=`MVP-${randomUUID()}`;
 const exams=await request(secretary,'/rest/v1/exams','POST',[null,0].map(score=>({teacher_id:teacher.id,
  student_id:student,group_id:group,title:title+(score===null?'-missing':'-zero'),held_on:date,score_percent:score})));
 eq(exams.ok,true);
 const assignment=await request(secretary,'/rest/v1/assignments','POST',{teacher_id:teacher.id,
  student_id:student,group_id:group,title,due_on:date,status:'pending'});eq(assignment.ok,true);
 const academic=await rpc(teacher,'get_teacher_student_academics',{p_id:student,p_kind:'exams',p_from:date,p_to:date,p_limit:100});
 eq(academic.data.rows.some(r=>r.title===title+'-missing'&&r.score_percent===null),true);
 eq(academic.data.rows.some(r=>r.title===title+'-zero'&&r.score_percent==='0.00'),true);
 const session=randomUUID();
 for(const id of [teacher.id,group,student,session]) if(!/^[0-9a-f-]{36}$/i.test(id)) throw new Error('Invalid synthetic UUID');
 await querySql(`begin;insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at)
 values('${session}','${teacher.id}','${group}',((now()-interval '30 days') at time zone 'Africa/Cairo')::date,
 now()-interval '30 days',now()-interval '30 days'+interval '1 hour');
 insert into public.attendance(teacher_id,session_id,student_id) values('${teacher.id}','${session}','${student}');commit;`);
 let detail=await rpc(teacher,'get_teacher_session_detail',{p_id:session});eq(detail.data.attendance[0].status,'not_marked');
 eq((await rpc(secretary,'finalize_attendance',{p_session_id:session})).ok,true);
 eq((await rpc(secretary,'set_attendance',{p_session_id:session,p_student_id:student,p_status:'present'})).data.message,'ATTENDANCE_CORRECTION_REASON_REQUIRED');
 eq((await rpc(secretary,'set_attendance',{p_session_id:session,p_student_id:student,p_status:'excused',p_reason:'MVP correction after thirty days'})).ok,true);
 detail=await rpc(teacher,'get_teacher_session_detail',{p_id:session});eq(detail.data.attendance[0].status,'excused');
 const note=(await rpc(teacher,'get_teacher_student_note',{p_id:student})).data.note;
 const stamp=await rpc(teacher,'save_teacher_note',{p_student_id:student,p_content:'MVP hosted synthetic note',p_expected_updated_at:note?.updated_at??null});eq(stamp.ok,true);
 try {
  eq((await rpc(teacher,'get_teacher_student_note',{p_id:student})).data.note.content,'MVP hosted synthetic note');
  eq((await rpc(teacher,'save_teacher_note',{p_student_id:student,p_content:'stale',p_expected_updated_at:note?.updated_at??null})).data.message,'CONFLICT');
 } finally {
  const restored=await rpc(teacher,'save_teacher_note',{p_student_id:student,p_content:note?.content??'',p_expected_updated_at:stamp.data});eq(restored.ok,true);
 }
 const requests=await Promise.all([1,2].map(()=>rpc(teacher,'request_secretary_removal',{p_secretary_id:secretary.id})));
 eq(requests.every(r=>r.ok),true);eq(requests[0].data,requests[1].data);
 const id=requests[0].data;if(!/^[0-9a-f-]{36}$/i.test(id)) throw new Error('Invalid synthetic request');
 await querySql(`update public.secretary_removal_requests set status='handled',handled_at=now()
 where id='${id}' and teacher_id='${teacher.id}' and secretary_id='${secretary.id}';
 update public.secretary_removal_requests set handled_at=handled_at where id='${id}' and teacher_id='${teacher.id}';`);
 const events=await request(teacher,`/rest/v1/notifications?select=id&payload->>request_id=eq.${id}`);eq(events.data.length,1);
 const record=(await rpc(teacher,'list_teacher_secretaries',{})).data.rows.find(r=>r.id===secretary.id);
 eq(record.status,'active');eq(record.removal_request.status,'handled');
 eq((await rpc(teacher,'mark_notification_read',{p_id:events.data[0].id})).ok,true);
 eq((await rpc(teacher,'mark_notification_read',{p_id:events.data[0].id})).ok,true);
 const read=await request(teacher,`/rest/v1/notifications?select=read_at&id=eq.${events.data[0].id}`);eq(read.data[0].read_at!==null,true);
 eq((await rpc(c.other,'mark_notification_read',{p_id:events.data[0].id})).data.message,'NOT_FOUND');
 c.historySession=session;
}
