// Isolated PGlite snapshot drill; not a hosted PostgreSQL backup certification.
import assert from 'node:assert/strict';
import {readFile,readdir,mkdir,writeFile} from 'node:fs/promises';
import {PGlite} from '@electric-sql/pglite';
const db=new PGlite();let restored;
const report={at:new Date().toISOString(),scope:'isolated PGlite binary snapshot; synthetic data only',hosted:false};
const scalar=async(c,sql,args)=>Object.values((await c.query(sql,args)).rows[0])[0];
try {
 await db.exec(`create role anon;create role authenticated;create schema auth;create table auth.users(id uuid primary key);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema auth to authenticated;grant execute on function auth.uid() to authenticated;`);
 for(const name of (await readdir(new URL('../migrations/',import.meta.url))).sort())await db.exec(await readFile(new URL('../migrations/'+name,import.meta.url),'utf8'));
 await db.exec(await readFile(new URL('fixtures.sql',import.meta.url),'utf8'));
 await db.exec("select set_config('request.jwt.claim.sub','20000000-0000-0000-0000-000000000001',false);set role authenticated");
 const invoice=await scalar(db,"select public.create_invoice('30000000-0000-0000-0000-000000000001',100.10,current_date,'RESTORE-DRILL')");
 const payment=await scalar(db,"select public.record_payment($1,40.05,'cash','ce990600-0000-4000-8000-000000000001')",[invoice]);
 await db.query("select public.reverse_payment($1,'isolated restore drill')",[payment]);
 await db.exec('reset role');
 const dump=await db.dumpDataDir('gzip');await mkdir('build/pilot',{recursive:true});
 await writeFile('build/pilot/isolated-snapshot.tar.gz',Buffer.from(await dump.arrayBuffer()));
 const started=Date.now(),persisted=await readFile('build/pilot/isolated-snapshot.tar.gz');
 restored=new PGlite({loadDataDir:new Blob([persisted])});await restored.waitReady;
 const inventory=await readFile(new URL('hardening_inventory.sql',import.meta.url),'utf8');
 const snapshot=async c=>(await c.exec(inventory)).find(r=>r.rows?.[0]?.hardening_inventory).rows[0].hardening_inventory;
 const strip=({sizes,...rest})=>rest;assert.deepEqual(strip(await snapshot(restored)),strip(await snapshot(db)));
 for(const table of ['students','groups','group_enrollments','sessions','attendance','attendance_change_log','invoices','payments','notifications','audit_events']){
  const rows=async c=>scalar(c,`select coalesce(jsonb_agg(to_jsonb(t) order by id),'[]') from public.${table} t`);
  assert.deepEqual(await rows(restored),await rows(db),table+' restored');
 }
 await restored.exec("select set_config('request.jwt.claim.sub','20000000-0000-0000-0000-000000000001',false);set role authenticated");
 assert.equal(await scalar(restored,"select public.secretary_browse('invoices',jsonb_build_object('id',$1::text))->'rows'->0->>'balance_egp'",[invoice]),'100.10');
 await restored.exec("reset role;select set_config('request.jwt.claim.sub','20000000-0000-0000-0000-000000000002',false);set role authenticated");
 assert.equal(await scalar(restored,"select public.secretary_browse('invoices',jsonb_build_object('id',$1::text))->>'total_count'",[invoice]),'0');
 Object.assign(report,{pass:true,restoreMs:Date.now()-started,verifiedTables:10,fullCatalog:true,ledgerAndTenantIsolation:true,bytes:persisted.length,limitations:['Native pg_dump/pg_restore tools unavailable; production provider restore drill still required']});
}finally{await restored?.close();await db.close();await writeFile('build/pilot/recovery.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));}
