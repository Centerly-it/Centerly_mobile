import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFile} from 'node:fs/promises';
import {startPostgres} from './postgres.mjs';
import {ids} from './completion_context.mjs';
const pg=await startPostgres({through:'202610240002'});let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
const deny=async(p,message)=>{await assert.rejects(p,e=>!message||e.message.includes(message));checks++;};
try {
 await pg.admin.query(await readFile(new URL('../proposals/202610250001_group_materials.sql',import.meta.url),'utf8'));
 const s=await pg.connect(ids.secretary),teacher=await pg.connect(ids.teacher),other=await pg.connect('20000000-0000-0000-0000-000000000002');
 const preview=async c=>(await c.query('select public.secretary_group_materials_preview($1) result',[ids.group])).rows[0].result;
 const first=await preview(s);eq(first.map(x=>x.id),[ids.student]);
 await deny(preview(teacher),'FORBIDDEN_ROLE');await deny(preview(other),'NOT_FOUND');
 const next=(await s.query('insert into public.students(teacher_id,full_name) values($1,$2) returning id',[ids.teacher,'Second materials student'])).rows[0].id;
 await s.query('select public.secretary_enroll($1,$2)',[ids.group,next]);
 const members=(await preview(s)).map(x=>x.id),request=randomUUID();
 const add=(c,key=request,students=members,amount='125.50',title='ملازم إضافية')=>c.query('select public.secretary_add_group_materials($1,$2,$3,$4,current_date,$5) result',[ids.group,key,title,amount,students]).then(r=>r.rows[0].result);
 await deny(add(s,randomUUID(),[ids.student]),'CONFLICT');
 await deny(add(s,randomUUID(),[]),'VALIDATION_ERROR');await deny(add(s,randomUUID(),[ids.student,ids.student]),'VALIDATION_ERROR');
 await deny(add(s,randomUUID(),members,'1.001'),'VALIDATION_ERROR');
 await deny(add(teacher),'FORBIDDEN_ROLE');await deny(add(other),'NOT_FOUND');
 // Same request concurrently: exact same committed result, no duplicate invoices.
 const s2=await pg.connect(ids.secretary);
 const [result,retry]=await Promise.all([add(s),add(s2)]);eq(result,retry);eq(result.count,2);eq(result.total_egp,'251.00');
 eq((await s.query("select count(*)::int n from public.invoices where invoice_number like $1",['GMAT-'+request+'-%'])).rows[0].n,2);
 await deny(add(s,request,members,'126.00'),'CONFLICT');
 // A later new request legitimately charges a newly named set of materials.
 eq((await add(s,randomUUID(),members,'10.25','مراجعة')).count,2);
 const inv=result.invoice_ids[0],paykey=randomUUID();
 const payment=(await s.query("select public.record_payment($1,25.25,'cash',$2) id",[inv,paykey])).rows[0].id;
 eq((await s.query("select public.record_payment($1,25.25,'cash',$2) id",[inv,paykey])).rows[0].id,payment);
 const balance=async()=> (await s.query("select public.secretary_browse('invoices',jsonb_build_object('id',$1::uuid))->'rows'->0->>'balance_egp' b",[inv])).rows[0].b;
 eq(await balance(),'100.25');await deny(s.query("select public.record_payment($1,100.26,'cash',$2)",[inv,randomUUID()]),'CONFLICT');
 await s.query("select public.reverse_payment($1,'materials correction')",[payment]);eq(await balance(),'125.50');
 eq((await teacher.query('select count(*)::int n from public.invoices where id=any($1)',[result.invoice_ids])).rows[0].n,2);
 eq((await other.query('select count(*)::int n from public.invoices where id=any($1)',[result.invoice_ids])).rows[0].n,0);
 // Simulated failure after one member's invoice: every invoice/audit rolls back.
 await pg.admin.query(`create function private.reject_materials_test() returns trigger language plpgsql as $$begin
 if new.invoice_number like 'GMAT-%' and new.student_id='${members[1]}' then raise exception 'TEST_ROLLBACK';end if;return new;end $$;
 create trigger reject_materials_test before insert on public.invoices for each row execute function private.reject_materials_test()`);
 const failed=randomUUID();await deny(add(s,failed),'TEST_ROLLBACK');
 eq((await pg.admin.query('select count(*)::int n from public.invoices where invoice_number like $1',['GMAT-'+failed+'-%'])).rows[0].n,0);
 eq((await pg.admin.query("select count(*)::int n from public.audit_events where entity_type='group_materials' and entity_id=$1",[failed])).rows[0].n,0);
 await pg.admin.query('drop trigger reject_materials_test on public.invoices');
 // A successful retry reconciles original membership even after membership changes.
 await pg.admin.query('update public.students set archived_at=now() where id=$1',[next]);
 eq((await preview(s)).length,1);eq(await add(s),result);
 await deny(add(s,randomUUID()),'CONFLICT');
 await pg.admin.query("update public.secretaries set status='inactive' where id=$1",[ids.secretary]);await deny(add(s),'ACCOUNT_INACTIVE');
 await pg.admin.query("update public.secretaries set status='active' where id=$1",[ids.secretary]);
 await pg.admin.query("update public.teachers set subscription_status='inactive' where id=$1",[ids.teacher]);await deny(preview(s),'SUBSCRIPTION_INACTIVE');
 console.log(JSON.stringify({pass:true,checks,mode:'disposable native PostgreSQL',hostedWrites:0}));
}finally{await pg.close();}
