// Manual33 postflight before advancing manifests. Read-only hosted verification.
import assert from 'node:assert/strict';
import {readFile,mkdir,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {querySql,projectRef} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
import {sqlTokens} from './sql_tokens.mjs';
import {startPostgres} from '../tests/postgres.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const report={at:new Date().toISOString(),hostedWrites:0};
let pg;let stage="history";
try {
  const manifest=JSON.parse(await readFile(new URL('../schema-manifest.json',import.meta.url),'utf8'));
  assert.equal(manifest.migrations.length,33);
  manifest.migrations.push({file:'202610240002_direct_attendance.sql',sha256:'41cd3a6a9b06250e721a477579f6575d9e771f8646f13e8687ec190df44d16cb'});
  const history=findField(parseCapture(await querySql('begin read only; select jsonb_agg(jsonb_build_object(\'version\',version,\'name\',name,\'statements\',statements) order by version) as history from supabase_migrations.schema_migrations; commit;',{output:'json'})),'history');
  assert.deepEqual(history.map(r=>r.version),manifest.migrations.map(r=>r.file.split('_')[0]));
  for(const m of manifest.migrations){
    const local=(await readFile(new URL('../migrations/'+m.file,import.meta.url),'utf8')).replaceAll('\r\n','\n');
    assert.equal(createHash('sha256').update(local).digest('hex'),m.sha256);
    assert.deepEqual(sqlTokens(history.find(r=>r.version===m.file.split('_')[0]).statements.join('\n')),sqlTokens(local));
  }
  stage='catalog-read';
  const sql=await readFile(new URL('../tests/hardening_inventory.sql',import.meta.url),'utf8');
  const remote=findField(parseCapture(await querySql(sql,{output:'json'})),'hardening_inventory');
  stage='local-catalog';
  pg=await startPostgres();
  const local=(await pg.admin.query(sql)).find(r=>r.rows?.[0]?.hardening_inventory).rows[0].hardening_inventory;
  const catalog=({sizes,invalid_enrollments,...d})=>({...d,functions:d.functions.map(f=>({...f,definition:sqlTokens(f.definition)}))});
  stage='catalog-compare';
  assert.deepEqual(catalog(remote),catalog(local));
  assert.equal(remote.invalid_enrollments,0);
  Object.assign(report,{pass:true,migrations:history.length,functions:remote.functions.length,tables:remote.tables.length,policies:remote.policies.length,triggers:remote.triggers.length});
} catch (error) {report.pass=false;report.stage=stage;report.failure=String(error.message).split('\n')[0];process.exitCode=1;}
finally {await pg?.close();await mkdir('build/attendance34',{recursive:true});await writeFile('build/attendance34/postflight.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));}
