import assert from 'node:assert/strict';

export async function testSecurity(db, actor, t1, t2, s1, student) {
  let count=0;
  const value=async sql=>Object.values((await db.query(sql)).rows[0])[0];
  await db.exec('reset role');
  const tables=(await db.query(`select tablename from pg_tables where schemaname='public' order by tablename`)).rows;
  assert.equal(tables.length,18); count++;
  assert.equal(await value(`select count(*)::int from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r' and (not c.relrowsecurity or not c.relforcerowsecurity)`),0); count++;
  await actor(t2);
  for (const {tablename} of tables.filter(t=>t.tablename!=='teachers')) {
    assert.equal(await value(`select count(*)::int from public.${tablename} where teacher_id='${t1}'`),0); count++;
  }
  await actor(s1);
  await assert.rejects(db.query(`update public.teachers set secretary_seats=99`)); count++;
  await assert.rejects(db.query(`insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key)
    values('${t1}',gen_random_uuid(),1,'${s1}','cash',gen_random_uuid())`)); count++;
  await assert.rejects(db.query(`select public.create_invoice('${student}','NaN',current_date,'NAN')`)); count++;
  await db.exec('reset role; set role anon');
  await assert.rejects(db.query('select * from public.students')); count++;
  await assert.rejects(db.query('select public.get_current_profile()')); count++;
  await db.exec('reset role');
  await assert.rejects(db.query('delete from public.payments')); count++;
  await assert.rejects(db.query('delete from public.attendance_change_log')); count++;
  await assert.rejects(db.query('delete from public.audit_events')); count++;
  return count;
}
