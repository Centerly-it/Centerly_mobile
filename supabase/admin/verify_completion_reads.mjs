import assert from 'node:assert/strict';
export async function verifyCompletionReads(c,check) {
 const {rpc,request,teacher,other,student,date,actors}=c;
 const reads=[['get_teacher_student_academics',{p_id:student,p_kind:'exams',p_from:date,p_to:date}],
  ['get_teacher_student_attendance',{p_id:student,p_from:date,p_to:date}],
  ['get_teacher_finance',{p_from:date,p_to:date}],['get_teacher_student_note',{p_id:student}],
  ['list_teacher_secretaries',{}],['list_teacher_notifications',{}],['get_teacher_calendar',{p_from:date,p_to:date}]];
 for(const [name,body] of reads) {
  check((await rpc(teacher,name,body)).ok,true);
  for(const actor of [actors['secretary-a'],actors['secretary-b']])
   check((await rpc(actor,name,body)).data.message,'FORBIDDEN_ROLE');
  check([401,403].includes((await rpc(null,name,body)).status),true);
  const result=await rpc(other,name,body);
  if(name.includes('student_')) check(result.data.message,'NOT_FOUND');
  else {
   check(result.ok,true);
   const rows=result.data.rows??result.data.sessions;
   const table={get_teacher_finance:'invoices',list_teacher_secretaries:'secretaries',
    list_teacher_notifications:'notifications',get_teacher_calendar:'sessions'}[name];
   const allowed=await request(other,`/rest/v1/${table}?select=id`);check(allowed.ok,true);
   const ids=new Set(allowed.data.map(r=>r.id));check(rows.every(r=>ids.has(r.id)),true);
  }
 }
 check((await request(other,`/rest/v1/students?id=eq.${student}&select=id`)).data,[]);
 assert.equal((await rpc(teacher,'get_current_profile',{})).data.teacher_id,teacher.id);
}
