import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFile,access} from 'node:fs/promises';
import {completionContext,ids} from './completion_context.mjs';
const proposal=await readFile(new URL('../proposals/teacher_owner_testing/202610220001_finance_movements.sql',import.meta.url),'utf8');
const review=await readFile(new URL('../../docs/TEACHER_OWNER_BACKEND_REVIEW.md',import.meta.url),'utf8');
assert.ok(review.includes(createHash('sha256').update(proposal).digest('hex')),'Proposal bytes differ from review');
const {pg,a,b,s,date,call,invoice,payment}=await completionContext();
let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++;};
try {
 const managed=new URL('../migrations/202610220001_finance_movements.sql',import.meta.url);
 if(await access(managed).then(()=>true,()=>false)) assert.equal(await readFile(managed,'utf8'),proposal);
 else await pg.admin.query(proposal);
 const read=(client=a,options={})=>call(client,'public.list_teacher_finance_movements($1,$1,$2,$3,$4,$5,$6,$7,$8,$9)',
  [date,options.search??'',options.method??null,options.kind??null,options.actor??null,options.student??null,options.group??null,options.cursor??null,options.limit??1]);
 let data=await read();eq(data.total_count,2);eq(data.rows.length,1);eq(data.summary,{net_egp:'0.00',gross_egp:'25.01',corrections_egp:'25.01'});
 let next=await read(a,{cursor:data.next_cursor});eq(next.rows.length,1);eq(next.next_cursor,null);eq(next.summary,data.summary);assert.notEqual(next.rows[0].id,data.rows[0].id);checks++;
 data=await read(a,{kind:'corrections'});eq(data.total_count,1);eq(data.summary.net_egp,'-25.01');eq(data.rows[0].reversal_of,payment);assert.ok(data.rows[0].original_collected_by_name);checks++;
 data=await read(a,{kind:'collections'});eq(data.summary.net_egp,'25.01');assert.ok(data.rows[0].correction_receipt_number);checks++;
 eq((await read(a,{method:'transfer'})).total_count,0);
 eq((await read(a,{search:'PKG-1'})).total_count,2);
 eq((await read(a,{search:'%'})).total_count,0);
 eq((await read(a,{search:'not found'})).summary.net_egp,'0.00');
 eq((await read(a,{actor:ids.secretary})).total_count,2);
 eq((await read(a,{student:ids.student})).total_count,2);
 eq((await read(b)).total_count,0);
 for (const options of [{method:'bad'},{kind:'bad'},{search:'x'.repeat(101)},{limit:101},{student:ids.otherStudent},{group:ids.otherGroup}]) {
  await assert.rejects(()=>read(a,options));checks++;
 }
 await assert.rejects(()=>read(s),/FORBIDDEN_ROLE/);checks++;
 await pg.admin.query('set role anon');
 await assert.rejects(()=>read(pg.admin),/permission denied/);checks++;
 await pg.admin.query('reset role');
 eq((await call(a,'public.get_teacher_invoice_detail($1)',[invoice])).total_count,2);
 console.log(`PASS: ${checks} finance movement proposal assertions; disposable local database only.`);
} finally {await pg.close();}
