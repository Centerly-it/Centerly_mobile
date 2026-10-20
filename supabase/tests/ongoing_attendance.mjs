import assert from 'node:assert/strict';

export async function verifyOngoingAttendance({pg,a,b,s,date,call}) {
 const teacher='10000000-0000-0000-0000-000000000001';
 // One SQL statement fixes the server boundary for every assertion in this block.
 await pg.admin.query(`do $$ declare t timestamptz:=statement_timestamp(); r jsonb; begin
 perform set_config('request.jwt.claim.sub','${teacher}',true);
 update public.sessions set status='upcoming',starts_at=t,ends_at=t+interval '1 hour',
  local_date=(t at time zone 'Africa/Cairo')::date-1 where teacher_id='${teacher}';
 r:=public.get_teacher_overview('2030-01-01');
 assert r->>'attendance_scope'='ongoing_sessions';
 assert (r->'attendance_counts'->>'not_marked')::int=1,'inclusive start / selected date independence';
 assert (r->'attendance_counts'->>'absent')::int=0,'unmarked never absent';
 update public.attendance set status='present' where teacher_id='${teacher}';
 r:=public.get_teacher_overview('2030-01-01');
 assert (r->'attendance_counts'->>'present')::int=1,'current marks included';
 update public.sessions set starts_at=t-interval '1 hour',ends_at=t where teacher_id='${teacher}';
 r:=public.get_teacher_overview('2030-01-01');
 assert (r->'attendance_counts'->>'present')::int=0,'exclusive end';
 update public.sessions set starts_at=t+interval '1 second',ends_at=t+interval '1 hour' where teacher_id='${teacher}';
 r:=public.get_teacher_overview('2030-01-01');
 assert (r->'attendance_counts'->>'present')::int=0,'future excluded';
 update public.sessions set starts_at=t-interval '1 hour',ends_at=t+interval '1 hour',
 status='cancelled',cancelled_by='${teacher}',cancelled_at=t,cancel_reason='Synthetic' where teacher_id='${teacher}';
 r:=public.get_teacher_overview('2030-01-01');
 assert (r->'attendance_counts'->>'present')::int=0,'cancelled excluded';
 end $$;`);
 const empty={present:0,absent:0,excused:0,not_marked:0};
 assert.deepEqual((await call(b,'public.get_teacher_overview($1)',[date])).attendance_counts,empty);
 await assert.rejects(()=>call(s,'public.get_teacher_overview($1)',[date]),/FORBIDDEN_ROLE/);
 await pg.admin.query('set role anon');
 try {await assert.rejects(()=>call(pg.admin,'public.get_teacher_overview($1)',[date]),/permission denied/);}
 finally {await pg.admin.query('reset role');}
 const latest=await call(a,'public.get_teacher_overview($1)',[date]);
 assert.equal(latest.date,date);
 assert.ok(Date.parse(latest.attendance_synced_at));
 assert.match((await pg.admin.query("select indexdef from pg_indexes where indexname='teacher_current_sessions'")).rows[0].indexdef,/ends_at, starts_at/);
 return 13;
}
