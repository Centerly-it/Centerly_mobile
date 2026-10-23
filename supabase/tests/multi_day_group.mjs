import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {randomUUID} from 'node:crypto';
import {startPostgres} from './postgres.mjs';
import {ids} from './completion_context.mjs';
const pg=await startPostgres({through:'202610230004'});let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const denied=async p=>{await assert.rejects(p);checks++;};
try{
 await pg.admin.query(await readFile(new URL('../proposals/202610230005_multi_day_group.sql',import.meta.url),'utf8'));
 const s=await pg.connect(ids.secretary),t=await pg.connect(ids.teacher),other=await pg.connect('20000000-0000-0000-0000-000000000002');
 const id=randomUUID();
 const create=(c,group=id,days=[6,1,3])=>c.query("select public.secretary_create_weekly_group($1,'فيزياء ٣ ث','فيزياء',700,300,$2,'15:00','16:00') id",[group,days]);
 await denied(create(s,randomUUID(),[]));await denied(create(s,randomUUID(),[null]));
 await denied(create(s,randomUUID(),[1,1]));await denied(create(s,randomUUID(),[7]));await denied(create(t));
 eq((await create(s)).rows[0].id,id);
 eq((await s.query('select weekday from public.group_schedules where group_id=$1 order by weekday',[id])).rows.map(r=>r.weekday),[1,3,6]);
 eq((await create(s,id,[1,3,6])).rows[0].id,id);
 eq((await s.query('select count(*)::int n from public.group_schedules where group_id=$1',[id])).rows[0].n,3);
 await denied(create(s,id,[1,3]));await denied(create(other));
 eq((await s.query("select bool_and(effective_from=(now() at time zone 'Africa/Cairo')::date and local_start_time='15:00') ok from public.group_schedules where group_id=$1",[id])).rows[0].ok,true);
 await pg.admin.query("create function private.reject_test_day() returns trigger language plpgsql as $$begin if new.weekday=3 then raise exception 'TEST';end if;return new;end $$;create trigger reject_test_day before insert on public.group_schedules for each row execute function private.reject_test_day()");
 const failed=randomUUID();await denied(create(s,failed));
 eq((await pg.admin.query('select count(*)::int n from public.groups where id=$1',[failed])).rows[0].n,0);
 eq((await pg.admin.query('select count(*)::int n from public.audit_events where entity_id=$1',[failed])).rows[0].n,0);
 console.log(JSON.stringify({pass:true,checks,mode:'local PostgreSQL SQL-role simulation',hostedWrites:0}));
}finally{await pg.close();}
