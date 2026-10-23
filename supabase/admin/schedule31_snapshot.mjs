// Read-only aggregate fingerprints; never exports business rows or credentials.
import assert from 'node:assert/strict';
import {mkdir,writeFile,readFile} from 'node:fs/promises';
import {querySql,projectRef} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const phase=process.argv[2];assert.ok(['pre','post'].includes(phase));
const tables=findField(parseCapture(await querySql("begin read only; select jsonb_agg(tablename order by tablename) names from pg_tables where schemaname='public'; commit;",{output:'json'})),'names');
assert.equal(tables.length,18);assert.ok(tables.every(t=>/^[a-z_]+$/.test(t)));
const parts=tables.map(t=>`select '${t}' name,count(*) n,md5(coalesce(jsonb_agg(v order by v::text)::text,'[]')) digest from (select to_jsonb(t)-'initial_amount_egp' v from public.${t} t) x`);
const sql=`begin read only; select (select jsonb_agg(x order by name) from (${parts.join(' union all ')}) x) fingerprints,
jsonb_build_object('invoice_amount', (select coalesce(sum(amount_egp),0) from public.invoices),
'payment_net',(select coalesce(sum(case when reversal_of is null then amount_egp else -amount_egp end),0) from public.payments)) totals; commit;`;
const result=parseCapture(await querySql(sql,{output:'json'}));
const report={fingerprints:findField(result,'fingerprints'),totals:findField(result,'totals')};
assert.ok(report.fingerprints);assert.ok(report.totals);
await mkdir('build/schedule31',{recursive:true});
if(phase==='post')assert.deepEqual(report,JSON.parse(await readFile('build/schedule31/pre-data.json','utf8')),'Business records changed during deployment');
await writeFile(`build/schedule31/${phase}-data.json`,JSON.stringify(report,null,2));
console.log(JSON.stringify({pass:true,phase,tables:tables.length,businessWrites:0,...(phase==='post'?{allRowsAndFinancialTotalsUnchanged:true}:{})}));
