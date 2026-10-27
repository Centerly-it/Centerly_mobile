// Owner-approved feature deployment. No account or business-row mutations.
import assert from 'node:assert/strict';
import {readFile,writeFile,copyFile,mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {resolve} from 'node:path';
import {environmentQuery} from './environment_database.mjs';
import {sqlTokens} from './sql_tokens.mjs';
assert.ok(process.argv.includes('--owner-approved'));
const file='202610270002_secretary_reactivation.sql';
const hash='0f5d0844d932675707495310f2d9919ceef690d7aef89a255384242ac6e0da4c';
const sql=(await readFile('supabase/migrations/'+file,'utf8')).replaceAll('\r\n','\n');
assert.equal(createHash('sha256').update(sql).digest('hex'),hash);
const baseline=JSON.parse(await readFile('supabase/schema-manifest.json','utf8'));
const expected=baseline.migrations.filter(m=>m.file!==file);assert.equal(expected.length,38);
const report={at:new Date().toISOString(),migration:file,sha256:hash,projects:[]};
for(const ref of ['yfeubomyglmhuwizaqoj','ohhwccwwwxfmwpfypfyf']) {
 const history=await environmentQuery(ref,'select version,statements from supabase_migrations.schema_migrations order by version');
 assert.deepEqual(history.map(h=>h.version),expected.map(m=>m.file.split('_')[0]));
 for(const m of expected){const source=(await readFile('supabase/migrations/'+m.file,'utf8')).replaceAll('\r\n','\n');
  assert.equal(createHash('sha256').update(source).digest('hex'),m.sha256);
  assert.deepEqual(sqlTokens(history.find(h=>h.version===m.file.split('_')[0]).statements.join('\n')),sqlTokens(source));}
 const tables=await environmentQuery(ref,"select tablename from pg_tables where schemaname='public' order by tablename");
 assert.equal(tables.length,18);
 const snapshotSql=tables.map(({tablename:t})=>{assert.match(t,/^[a-z_]+$/);return `select '${t}' name,count(*)::int rows,md5(coalesce(jsonb_agg(to_jsonb(x) order by to_jsonb(x)::text)::text,'[]')) digest from public.${t} x`;}).join(' union all ');
 const before=await environmentQuery(ref,snapshotSql);
 const workspace=ref===baseline.projectRef?resolve('.'):resolve('build/environments/production-workspace');
 await mkdir(workspace+'/supabase/migrations',{recursive:true});
 if(ref!==baseline.projectRef)await copyFile('supabase/migrations/'+file,workspace+'/supabase/migrations/'+file);
 const env={...process.env};
 if(ref!==baseline.projectRef)env.SUPABASE_DB_PASSWORD=JSON.parse(await readFile('.env.production-admin.json','utf8')).databasePassword;
 const quote=v=>"'"+v.replaceAll("'","''")+"'";
 const cli=args=>{try{return execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command','& npx.cmd --offline supabase --agent no '+args.map(quote).join(' ')+' 2>&1 | Out-String; exit $LASTEXITCODE'],{env,encoding:'utf8',timeout:180000,windowsHide:true});}catch{throw new Error('Migration CLI failed; private output suppressed');}};
 assert.equal((await readFile(workspace+'/supabase/.temp/project-ref','utf8')).trim(),ref);
 const args=['db','push','--linked','--skip-vault','--workdir',workspace];
 const dry=cli([...args,'--dry-run']);
 assert.match(dry,/DRY RUN/);assert.deepEqual([...dry.matchAll(/\b\d{12}_[a-z_]+\.sql\b/g)].map(m=>m[0]),[file]);
 console.log(ref+': unchanged 38-version baseline; dry run lists only secretary reactivation.');
 cli([...args,'--yes']);
 const after=await environmentQuery(ref,snapshotSql);assert.deepEqual(after,before,'Business data changed during schema deployment');
 const row=(await environmentQuery(ref,"select statements from supabase_migrations.schema_migrations where version='202610270002'"))[0];
 assert.deepEqual(sqlTokens(row.statements.join('\n')),sqlTokens(sql));
 const permissions=(await environmentQuery(ref,"select has_function_privilege('anon','public.reactivate_secretary(uuid)','execute') anon,has_function_privilege('authenticated','public.reactivate_secretary(uuid)','execute') authenticated,(select prosecdef from pg_proc where oid='public.reactivate_secretary(uuid)'::regprocedure) security_definer"))[0];
 assert.deepEqual(permissions,{anon:false,authenticated:true,security_definer:true});
 report.projects.push({ref,migrations:39,allBusinessRowsUnchanged:true,permissions});
 console.log(ref+': deployed; history/body/grants verified; all business rows unchanged.');
}
await writeFile('docs/secretary-reactivation-acceptance.json',JSON.stringify(report,null,2)+'\n');
