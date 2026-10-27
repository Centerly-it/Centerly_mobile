// Apply unchanged canonical migrations only to the owner-created empty project.
import assert from 'node:assert/strict';
import {mkdir,readFile,writeFile,copyFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {execFileSync} from 'node:child_process';
import {environmentQuery} from './environment_database.mjs';
import {management} from './management_api.mjs';
assert.ok(process.argv.includes('--owner-approved'));
const registry=JSON.parse(await readFile('.env.production-admin.json','utf8'));
const ref=registry.projectRef;assert.equal(ref,'ohhwccwwwxfmwpfypfyf');
assert.equal(management('/v1/organizations/'+registry.organization).plan,'free');
const manifest=JSON.parse(await readFile('supabase/schema-manifest.json','utf8'));
assert.equal(manifest.migrations.length,37);
const empty=await environmentQuery(ref,"select (select count(*) from auth.users)::int auth_users,(select count(*) from pg_tables where schemaname='public')::int public_tables");
assert.equal(empty[0].auth_users,0);assert.equal(empty[0].public_tables,0,'Not an empty project; reconcile rather than reset');
const workspace=resolve('build/environments/production-workspace');
await mkdir(workspace+'/supabase/migrations',{recursive:true});
await copyFile('supabase/config.toml',workspace+'/supabase/config.toml');
for(const m of manifest.migrations){
 const data=await readFile('supabase/migrations/'+m.file);
 assert.equal(createHash('sha256').update(data.toString('utf8').replaceAll('\r\n','\n')).digest('hex'),m.sha256);
 await writeFile(workspace+'/supabase/migrations/'+m.file,data);
}
const quote=v=>"'"+v.replaceAll("'","''")+"'";
function cli(args){
 const command='& npx.cmd --offline supabase --agent no '+args.map(quote).join(' ')+' 2>&1 | Out-String; exit $LASTEXITCODE';
 try{return execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',command],{encoding:'utf8',timeout:180000,windowsHide:true,env:{...process.env,SUPABASE_DB_PASSWORD:registry.databasePassword}});}
 catch{throw new Error('Isolated production CLI operation failed; private output suppressed');}
}
cli(['link','--project-ref',ref,'--workdir',workspace]);
const dry=cli(['db','push','--linked','--skip-vault','--dry-run','--workdir',workspace]);
assert.match(dry,/DRY RUN/);
assert.deepEqual([...dry.matchAll(/\b\d{12}_[a-z_]+\.sql\b/g)].map(m=>m[0]),manifest.migrations.map(m=>m.file));
await writeFile('build/environments/production-dry-run.log',dry);
console.log('Dry run verified: exactly 37 canonical migrations on empty production.');
const result=cli(['db','push','--linked','--skip-vault','--yes','--workdir',workspace]);
assert.ok(!result.includes(registry.databasePassword));
await writeFile('build/environments/production-deploy.log',result);
console.log('Production schema command completed; catalog and empty-data verification required.');
