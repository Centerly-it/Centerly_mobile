import assert from 'node:assert/strict';
import { startPostgres } from './postgres.mjs';

const pg=await startPostgres();
try {
  const t='10000000-0000-0000-0000-000000000001',s='20000000-0000-0000-0000-000000000001';
  const student='30000000-0000-0000-0000-000000000001',session='50000000-0000-0000-0000-000000000001';
  const [a,b,teacher]=await Promise.all([pg.connect(s),pg.connect(s),pg.connect(t)]);
  const scalar=async(c,sql)=>Object.values((await c.query(sql)).rows[0])[0];
  const invoice=await scalar(a,`select public.create_invoice('${student}',100,current_date,'RACE')`);
  const key='60000000-0000-0000-0000-000000000099';
  // Hold transaction A while B attempts the same key; B must wait, not duplicate.
  await a.query('begin');
  const payment=await scalar(a,`select public.record_payment('${invoice}',40,'cash','${key}')`);
  const waiting=b.query(`select public.record_payment('${invoice}',40,'cash','${key}')`);
  await a.query('commit');
  assert.equal(Object.values((await waiting).rows[0])[0],payment);
  assert.equal(await scalar(a,`select count(*)::int from public.payments`),1);
  const overpay=await Promise.allSettled([a,b].map(c=>c.query(
    `select public.record_payment('${invoice}',60,'cash',gen_random_uuid())`)));
  assert.equal(overpay.filter(r=>r.status==='fulfilled').length,1);
  assert.match(overpay.find(r=>r.status==='rejected').reason.message,/CONFLICT/);
  assert.equal(await scalar(a,`select sum(amount_egp)::text from public.payments`),'100.00');
  await assert.rejects(a.query(`select public.finalize_attendance('${session}')`),/permission denied/);
  await a.query('begin');
  await a.query(`select public.set_attendance('${session}','${student}','present','first correction')`);
  const correction=b.query(`select public.set_attendance('${session}','${student}','excused','second correction')`);
  await a.query('commit'); await correction;
  const log=(await a.query('select previous_status,next_status,reason from public.attendance_change_log order by changed_at')).rows;
  assert.deepEqual(log.map(r=>[r.previous_status,r.next_status]),[['not_marked','present'],['present','excused']]);

  await pg.admin.query(`update public.sessions set starts_at=now()+interval '1 hour',ends_at=now()+interval '2 hours' where id='${session}'`);
  const cancelled=await Promise.allSettled([teacher,a].map(c=>c.query(`select public.cancel_session('${session}','race test')`)));
  assert.equal(cancelled.filter(r=>r.status==='fulfilled').length,1);
  assert.match(cancelled.find(r=>r.status==='rejected').reason.message,/ALREADY_CANCELLED/);
  assert.equal(await scalar(a,'select count(*)::int from public.attendance_change_log'),2);
  assert.equal(await scalar(a,`select count(*)::int from public.audit_events where action='cancelled'`),1);
  console.log('PASS: 11 independent-connection PostgreSQL concurrency assertions.');
} finally { await pg.close(); }
