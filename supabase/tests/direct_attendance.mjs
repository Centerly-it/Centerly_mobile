// Isolated SQL-role simulation. No hosted fixtures are modified.
import assert from 'node:assert/strict';
import {startPostgres} from './postgres.mjs';
import {ids} from './completion_context.mjs';
const pg=await startPostgres();let checks=0;
try {
 const s=await pg.connect(ids.secretary),t=await pg.connect(ids.teacher),other=await pg.connect('20000000-0000-0000-0000-000000000002');
 await pg.admin.query('update public.sessions set attendance_finalized_at=now(),attendance_finalized_by=$2 where id=$1',[ids.session,ids.secretary]);
 const mark=async(c,status,stamp)=>(await c.query('select public.secretary_set_attendance($1,$2,$3,$4)',[ids.session,ids.student,status,stamp])).rows[0];
 const stamp=async()=>(await pg.admin.query('select updated_at::text from public.attendance where session_id=$1',[ids.session])).rows[0].updated_at;
 const initial=await stamp();await mark(s,'present',initial);checks++;
 await assert.rejects(mark(s,'absent',initial),/CONFLICT/);checks++;
 await mark(s,'absent',await stamp());checks++;
 assert.equal((await pg.admin.query('select count(*)::int n from public.attendance_change_log')).rows[0].n,2);checks++;
 await assert.rejects(s.query('select public.finalize_attendance($1)',[ids.session]),/permission denied/);checks++;
 for(const c of [t,other]){await assert.rejects(mark(c,'excused',await stamp()));checks++;}
 await pg.admin.query("update public.sessions set status='cancelled',cancel_reason='local test',cancelled_by=attendance_finalized_by,cancelled_at=now() where id=$1",[ids.session]);
 await assert.rejects(mark(s,'excused',await stamp()),/CONFLICT/);checks++;
 assert.equal((await pg.admin.query('select attendance_finalized_at is not null retained from public.sessions where id=$1',[ids.session])).rows[0].retained,true);checks++;
 console.log(JSON.stringify({pass:true,checks,mode:'local PostgreSQL SQL-role simulation',hostedWrites:0}));
}finally{await pg.close();}
