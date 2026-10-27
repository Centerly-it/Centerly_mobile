import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {environmentQuery} from './environment_database.mjs';
import {sqlTokens} from './sql_tokens.mjs';
const dev='yfeubomyglmhuwizaqoj',prod='ohhwccwwwxfmwpfypfyf';
const manifest=JSON.parse(await readFile('supabase/schema-manifest.json','utf8'));
assert.equal(manifest.migrations.length,39);
const history=await environmentQuery(prod,'select version,name,statements from supabase_migrations.schema_migrations order by version');
assert.deepEqual(history.map(m=>m.version),manifest.migrations.map(m=>m.file.split('_')[0]));
for(const m of manifest.migrations){
 const body=(await readFile('supabase/migrations/'+m.file,'utf8')).replaceAll('\r\n','\n');
 assert.equal(createHash('sha256').update(body).digest('hex'),m.sha256);
 assert.deepEqual(sqlTokens(history.find(h=>h.version===m.file.split('_')[0]).statements.join('\n')),sqlTokens(body));
}
const inventory=await readFile('supabase/tests/hardening_inventory.sql','utf8');
const d=(await environmentQuery(dev,inventory))[0].hardening_inventory;
const p=(await environmentQuery(prod,inventory))[0].hardening_inventory;
const catalog=({sizes,invalid_enrollments,...v})=>({...v,functions:v.functions.map(f=>({...f,definition:sqlTokens(f.definition)}))});
assert.deepEqual(catalog(p),catalog(d),'Production catalog differs from development');
const empty=await environmentQuery(prod,"select (select count(*) from auth.users)::int auth_users,(select count(*) from storage.objects)::int storage_objects,(select count(*) from storage.buckets)::int storage_buckets");
assert.equal(empty[0].auth_users,0);assert.equal(empty[0].storage_objects,0);
assert.ok(p.tables.every(t=>/^[a-z_]+$/.test(t.name)));
const counts=await environmentQuery(prod,p.tables.map(t=>`select '${t.name}' name,count(*)::int rows from public.${t.name}`).join(' union all '));
for(const row of counts){assert.equal(row.rows,0,'Production business data is not empty');}
const report={at:new Date().toISOString(),pass:true,productionRef:prod,developmentRef:dev,migrations:history.length,functions:p.functions.length,tables:p.tables.length,policies:p.policies.length,triggers:p.triggers.length,empty:empty[0],businessCounts:counts,devBusinessWrites:0};
await mkdir('build/environments',{recursive:true});
await writeFile('build/environments/production-verified.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
