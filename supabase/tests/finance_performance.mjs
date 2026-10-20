// Disposable local PostgreSQL only. Reports timings, never asserts wall-clock speed.
import assert from 'node:assert/strict';
import {writeFile,mkdir,readFile} from 'node:fs/promises';
import {startPostgres} from './postgres.mjs';
const pg=await startPostgres({through:'202610190010'});
try {
 const db=pg.admin;
 await db.query("set statement_timeout='60s';set jit=off");
 await db.query(`insert into public.invoices(teacher_id,student_id,invoice_number,amount_egp,due_on,created_by)
 select '10000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',
 'PERF-'||n,1000.00,current_date,'20000000-0000-0000-0000-000000000001' from generate_series(1,1000)n`);
 await db.query(`insert into public.payments(teacher_id,invoice_id,amount_egp,collected_by,method,idempotency_key)
 select i.teacher_id,i.id,1.01,'20000000-0000-0000-0000-000000000001','cash',gen_random_uuid()
 from public.invoices i cross join generate_series(1,20)n where invoice_number like 'PERF-%'`);
 await db.query('vacuum analyze public.payments');await db.query('analyze public.invoices');
 const tenant="'10000000-0000-0000-0000-000000000001'::uuid";
 const query=scoped=>`select sum((select sum(case when p.reversal_of is null then p.amount_egp else -p.amount_egp end)
 from public.payments p where p.invoice_id=i.id ${scoped?'and p.teacher_id=i.teacher_id':''}))::numeric(20,2)::text paid
 from public.invoices i where i.teacher_id=${tenant}`;
 const measure=async()=>{
 const result={};
 for(const [name,scoped] of [['teacher_read',true],['reconcile_payment',false]]) {
 const sql=query(scoped);assert.equal((await db.query(sql)).rows[0].paid,'20200.00');
 const runs=[];let plan;
 for(let n=0;n<3;n++) {plan=(await db.query('explain(analyze,buffers,format json) '+sql)).rows[0]['QUERY PLAN'][0];runs.push(plan['Execution Time']);}
 const nodes=[];const visit=p=>{nodes.push(p['Node Type']);for(const child of p.Plans??[])visit(child);};visit(plan.Plan);
 result[name]={median_ms:runs.sort((a,b)=>a-b)[1],nodes};
 }
 return result;
 };
 await db.query('create index teacher_invoice_movements on public.payments(teacher_id,invoice_id,id)');
 const before=await measure();
 await db.query('drop index public.teacher_invoice_movements');
 const ddl='create index teacher_invoice_movements on public.payments(invoice_id,id) include(teacher_id,amount_egp,reversal_of)';
 assert.ok((await readFile(new URL('../proposals/finance_business/202610200001_finance_overview.sql',import.meta.url),'utf8')).includes(ddl+';'));
 await db.query(ddl);const after=await measure();
 assert.ok(after.teacher_read.nodes.includes('Index Only Scan'));
 assert.ok(after.reconcile_payment.nodes.includes('Index Only Scan'));
 const report={scope:'disposable local PostgreSQL; no hosted access',invoices:1000,payments:20000,before,after,ddl,exact_paid_egp:'20200.00'};
 await mkdir('build',{recursive:true});await writeFile('build/backend_finance_benchmark.json',JSON.stringify(report,null,2));
 console.log(JSON.stringify(report));
} finally {await pg.close();}
