// Exact approved package plus live catalog comparison; no hosted writes.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {querySql,projectRef} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
import {sqlTokens} from './sql_tokens.mjs';
import {startPostgres} from '../tests/postgres.mjs';
const post=process.argv.includes('--post-deploy');
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const root=new URL('../../',import.meta.url);
const review=await readFile(new URL('docs/MAIN_HARDENING_CHANGE_REVIEW.md',root),'utf8');
const proposals=[...review.matchAll(/\| `(supabase\/proposals\/[^`]+\.sql)` \| `([a-f0-9]{64})` \|/g)];
assert.equal(proposals.length,6);
const manifest=JSON.parse(await readFile(new URL('supabase/schema-manifest.json',root),'utf8'));
const baseline=manifest.migrations.filter(r=>r.file.split('_')[0]<='202610190010');
assert.equal(baseline.length,19);
const expected=[...baseline];
for(const [,path,hash] of proposals) {
 const bytes=await readFile(new URL(path,root));
 assert.equal(createHash('sha256').update(bytes).digest('hex'),hash,'Approved hash mismatch: '+path);
 if(post) expected.push({file:path.split('/').at(-1),sha256:hash});
}
const history=findField(parseCapture(await querySql(`begin read only; select jsonb_agg(jsonb_build_object('version',version,'name',name,'statements',statements) order by version) as history from supabase_migrations.schema_migrations; commit;`,{output:'json'})),'history');
assert.deepEqual(history.map(r=>r.version),expected.map(r=>r.file.split('_')[0]));
for(const row of expected) {
 const sql=await readFile(new URL('supabase/migrations/'+row.file,root),'utf8');
 assert.equal(createHash('sha256').update(sql.replaceAll('\r\n','\n')).digest('hex'),row.sha256);
 const remote=history.find(r=>r.version===row.file.split('_')[0]);
 assert.equal(remote.name,row.file.replace(/^\d+_/,'').replace(/\.sql$/,''));
 assert.deepEqual(sqlTokens(remote.statements.join('\n')),sqlTokens(sql),'Remote migration drift: '+row.file);
}
const sql=await readFile(new URL('supabase/tests/hardening_inventory.sql',root),'utf8');
const remote=findField(parseCapture(await querySql(sql,{output:'json'})),'hardening_inventory');
await writeFile(new URL(`build/hardening-${post?'postflight':'preflight'}.json`,root),JSON.stringify({history,inventory:remote},null,2));
const pg=await startPostgres();
try {
 const local=(await pg.admin.query(sql)).find(r=>r.rows?.[0]?.hardening_inventory)?.rows[0].hardening_inventory;
 const canonical=data=>({...data,functions:data.functions.map(f=>({...f,definition:sqlTokens(f.definition)}))});
 const catalog=data=>{const {invalid_enrollments,sizes,...rest}=canonical(data);return rest;};
 assert.deepEqual(catalog(remote),catalog(local),'Hosted catalog differs from local managed migrations');
 assert.equal(remote.invalid_enrollments,0,'Historical enrollment violations require reviewed repair');
 console.log(JSON.stringify({pass:true,project:projectRef,phase:post?'postflight':'preflight',exactMigrationBodies:expected.length,
 functions:remote.functions.length,tables:remote.tables.length,policies:remote.policies.length,
 invalidEnrollments:remote.invalid_enrollments,sizes:remote.sizes}));
} finally {await pg.close();}
