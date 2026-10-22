// Read-only hosted history/catalog verification; no deployment or fixture changes.
import assert from 'node:assert/strict';
import {readFile,mkdir,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {querySql,projectRef} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
import {sqlTokens} from './sql_tokens.mjs';
import {startPostgres} from '../tests/postgres.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const report={at:new Date().toISOString(),hostedWrites:0};
let pg;
try {
  const manifest=JSON.parse(await readFile(new URL('../schema-manifest.json',import.meta.url),'utf8'));
  const history=findField(parseCapture(await querySql('begin read only; select jsonb_agg(jsonb_build_object(\'version\',version,\'name\',name,\'statements\',statements) order by version) as history from supabase_migrations.schema_migrations; commit;',{output:'json'})),'history');
  assert.deepEqual(history.map(r=>r.version),manifest.migrations.map(r=>r.file.split('_')[0]));
  for(const m of manifest.migrations){
    const local=(await readFile(new URL('../migrations/'+m.file,import.meta.url),'utf8')).replaceAll('\r\n','\n');
    assert.equal(createHash('sha256').update(local).digest('hex'),m.sha256);
    assert.deepEqual(sqlTokens(history.find(r=>r.version===m.file.split('_')[0]).statements.join('\n')),sqlTokens(local));
  }
  const sql=await readFile(new URL('../tests/hardening_inventory.sql',import.meta.url),'utf8');
  const remote=findField(parseCapture(await querySql(sql,{output:'json'})),'hardening_inventory');
  pg=await startPostgres();
  const local=(await pg.admin.query(sql)).find(r=>r.rows?.[0]?.hardening_inventory).rows[0].hardening_inventory;
  const catalog=({sizes,invalid_enrollments,...d})=>({...d,functions:d.functions.map(f=>({...f,definition:sqlTokens(f.definition)}))});
  assert.deepEqual(catalog(remote),catalog(local));
  assert.equal(remote.invalid_enrollments,0);
  Object.assign(report,{pass:true,migrations:history.length,functions:remote.functions.length,tables:remote.tables.length,policies:remote.policies.length,triggers:remote.triggers.length});
} catch {report.pass=false;report.failure='Hosted history/catalog verification unavailable or mismatched; no hosted change attempted';process.exitCode=1;}
finally {await pg?.close();await mkdir('build/pilot',{recursive:true});await writeFile('build/pilot/baseline.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));}
