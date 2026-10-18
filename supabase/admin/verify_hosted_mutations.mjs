import assert from 'node:assert/strict';

export async function testHostedMutations({request,rpc,querySql,teacher,other,secretary,student,randomUUID}) {
  const session='50000000-0000-0000-0000-000000000001';
  let count=0;
  const mark=await rpc(secretary,'set_attendance',{p_session_id:session,p_student_id:student,p_status:'present',p_reason:'Hosted fixture initial mark'});
  assert.ok(mark.ok); count++;
  assert.ok((await rpc(secretary,'finalize_attendance',{p_session_id:session})).ok); count++;
  const denied=await rpc(secretary,'set_attendance',{p_session_id:session,p_student_id:student,p_status:'absent'});
  assert.equal(denied.data.message,'ATTENDANCE_CORRECTION_REASON_REQUIRED'); count++;
  assert.ok((await rpc(secretary,'set_attendance',{p_session_id:session,p_student_id:student,p_status:'absent',p_reason:'Hosted fixture audited correction'})).ok); count++;
  const log=await request(teacher,`/rest/v1/attendance_change_log?attendance_id=eq.${mark.data}&select=actor_id,reason`);
  assert.ok(log.data.some(r=>r.actor_id===secretary.id&&r.reason==='Hosted fixture audited correction')); count++;
  const invoice=await rpc(secretary,'create_invoice',{p_student_id:student,p_amount:100,p_due_on:new Date().toISOString().slice(0,10),p_invoice_number:`HOSTED-${randomUUID()}`});
  assert.ok(invoice.ok); count++;
  const key=randomUUID(),body={p_invoice_id:invoice.data,p_amount:40,p_method:'cash',p_idempotency_key:key};
  const paid=await Promise.all([rpc(secretary,'record_payment',body),rpc(secretary,'record_payment',body)]);
  assert.ok(paid.every(r=>r.ok)); count++;
  assert.equal(paid[0].data,paid[1].data); count++;
  const overpay=await Promise.all([1,2].map(()=>rpc(secretary,'record_payment',{
    ...body,p_amount:60,p_idempotency_key:randomUUID()})));
  assert.equal(overpay.filter(r=>r.ok).length,1); count++;
  assert.equal(overpay.find(r=>!r.ok).data.message,'CONFLICT'); count++;
  assert.ok((await rpc(secretary,'reverse_payment',{p_payment_id:paid[0].data,p_reason:'Hosted fixture reversal'})).ok); count++;
  const ledger=await request(teacher,`/rest/v1/payments?invoice_id=eq.${invoice.data}&select=amount_egp,reversal_of`);
  assert.equal(ledger.data.length,3); count++;
  assert.equal(ledger.data.reduce((sum,p)=>sum+(p.reversal_of?-1:1)*Number(p.amount_egp),0),60); count++;
  const future=randomUUID();
  await querySql(`insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at)
    values('${future}','${teacher.id}','40000000-0000-0000-0000-000000000001',
    (now() at time zone 'Africa/Cairo')::date,now()+interval '1 hour',now()+interval '2 hours');`);
  count++;
  assert.equal((await rpc(other,'cancel_session',{p_session_id:future,p_reason:'forbidden'})).data.message,'NOT_FOUND'); count++;
  const cancelled=await Promise.all([teacher,secretary].map(a=>rpc(a,'cancel_session',{p_session_id:future,p_reason:'Hosted race fixture'})));
  assert.equal(cancelled.filter(r=>r.ok).length,1); count++;
  assert.equal(cancelled.find(r=>!r.ok).data.message,'ALREADY_CANCELLED'); count++;
  return count;
}
