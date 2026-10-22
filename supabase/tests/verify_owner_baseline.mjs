// Compare fresh read-only CLI captures with the immutable local baseline.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {sqlTokens} from '../admin/sql_tokens.mjs';
import {startPostgres} from './postgres.mjs';
const history=JSON.parse(await readFile(process.argv[2],'utf8')).rows;
const inventoryRows=JSON.parse(await readFile(process.argv[3],'utf8')).rows;
const remote=inventoryRows.find(r=>r.hardening_inventory)?.hardening_inventory;
assert.ok(remote);
const manifest=JSON.parse(await readFile(new URL('../schema-manifest.json',import.meta.url),'utf8'));
const expected=[...manifest.migrations];
if(process.argv.includes('--include-approved-finance-movements')) {
 assert.equal(expected.length,25);
 const file='202610220001_finance_movements.sql';
 const bytes=await readFile(new URL('../migrations/'+file,import.meta.url));
 const sha256=createHash('sha256').update(bytes).digest('hex');
 assert.equal(sha256,'e59af624e58ddb7875fc59c6f02278806fcdb8eb8c93ec8b0765a17848e2eedf');
 expected.push({file,sha256});
}
assert.deepEqual(history.map(r=>r.version),expected.map(r=>r.file.split('_')[0]));
for(const entry of expected) {
 const row=history.find(r=>r.version===entry.file.split('_')[0]);
 const local=await readFile(new URL('../migrations/'+entry.file,import.meta.url),'utf8');
 assert.deepEqual(sqlTokens(row.statements.join('\n')),sqlTokens(local),entry.file);
}
const pg=await startPostgres();
try {
 const sql=await readFile(new URL('hardening_inventory.sql',import.meta.url),'utf8');
 const local=(await pg.admin.query(sql)).find(r=>r.rows?.[0]?.hardening_inventory).rows[0].hardening_inventory;
 const catalog=({invalid_enrollments,sizes,...data})=>({...data,functions:data.functions.map(f=>({...f,definition:sqlTokens(f.definition)}))});
 assert.deepEqual(catalog(remote),catalog(local));
 console.log(JSON.stringify({pass:true,exactMigrationBodies:history.length,functions:remote.functions.length,tables:remote.tables.length,policies:remote.policies.length,invalidEnrollments:remote.invalid_enrollments}));
} finally {await pg.close();}
