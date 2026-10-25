import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {startPostgres} from './postgres.mjs';
import {ids} from './completion_context.mjs';
const pg=await startPostgres();let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
try {
 const teacher=await pg.connect(ids.teacher),s=await pg.connect(ids.secretary),other=await pg.connect('20000000-0000-0000-0000-000000000002');
 const session=randomUUID(),reason='ظرف طارئ عند المدرس';
 await pg.admin.query("insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at) values($1,$2,$3,(now() at time zone 'Africa/Cairo')::date,now()+interval '1 hour',now()+interval '2 hours')",[session,ids.teacher,ids.group]);
 await teacher.query('select public.cancel_session($1,$2)',[session,reason]);
 const n=(await s.query("select public.secretary_browse('notifications') result")).rows[0].result.rows.find(x=>x.payload.session_id===session);
 eq(n.type,'session_cancelled');eq(n.recipient_id,ids.secretary);eq(Object.keys(n.payload),['session_id']);
 const row=(await s.query("select public.secretary_browse('sessions',jsonb_build_object('id',$1::uuid)) result",[n.payload.session_id])).rows[0].result.rows[0];
 eq(row.cancel_reason,reason);eq(row.status,'cancelled');
 eq((await other.query("select public.secretary_browse('notifications') result")).rows[0].result.rows.some(x=>x.id===n.id),false);
 eq((await other.query("select public.secretary_browse('sessions',jsonb_build_object('id',$1::uuid)) result",[session])).rows[0].result.rows.length,0);
 console.log(JSON.stringify({pass:true,checks,mode:'disposable native PostgreSQL',hostedWrites:0}));
}finally{await pg.close();}
