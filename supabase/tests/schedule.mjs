import assert from 'node:assert/strict';

export async function testSchedule(db, actor, t1, s1, student, session) {
  const value=async sql=>Object.values((await db.query(sql)).rows[0])[0];
  await actor(s1);
  await db.query(`select public.add_schedule('40000000-0000-0000-0000-000000000001',0,'23:30','00:30','2026-10-18')`);
  assert.equal(await value(`select public.generate_sessions('2026-10-18','2026-10-18')`),1);
  assert.equal(await value(`select public.generate_sessions('2026-10-18','2026-10-18')`),0);
  assert.equal(await value(`select extract(epoch from (ends_at-starts_at))::int from public.sessions where schedule_id is not null`),3600);
  await actor(t1);
  assert.equal(await value(`select count(*)::int from public.list_students()`),1);
  assert.equal(await value(`select (public.get_teacher_dashboard(current_date)->>'outstanding_egp')::numeric`),'40.00');
  await assert.rejects(db.query(`select public.generate_sessions('2026-10-18','2026-10-18')`),/FORBIDDEN_ROLE/);
  await assert.rejects(db.query(`select public.list_sessions('2026-01-01','2026-12-31')`),/VALIDATION_ERROR/);
  await db.exec('reset role');
  await db.query(`insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at)
    values('50000000-0000-0000-0000-000000000003','${t1}','40000000-0000-0000-0000-000000000001',current_date+1,now()+interval '1 day',now()+interval '25 hours')`);
  await actor(t1);
  await db.query(`select public.cancel_session('50000000-0000-0000-0000-000000000003','test cancellation')`);
  await assert.rejects(db.query(`select public.cancel_session('50000000-0000-0000-0000-000000000003','duplicate')`),/ALREADY_CANCELLED/);
  await assert.rejects(db.query(`select public.cancel_session('${session}','completed')`),/CONFLICT/);
  await actor(s1);
  await assert.rejects(db.query(`select public.set_attendance('50000000-0000-0000-0000-000000000003','${student}','present')`),/CONFLICT/);
  assert.equal(await value(`select count(*)::int from public.attendance where session_id='${session}'`),1);
  return 11;
}
