import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {sqlTokens} from './sql_tokens.mjs';

const manifest=JSON.parse(await readFile(new URL('../schema-manifest.json',import.meta.url),'utf8'));
const linked=(await readFile(new URL('../.temp/project-ref',import.meta.url),'utf8')).trim();
assert.equal(linked,manifest.projectRef,'Linked target differs from approved development project');
const path=process.argv[2];
const postDeploy=process.argv.includes('--post-deploy');
const expected=manifest.migrations.filter(row=>row.file.startsWith('20261018'));
assert.equal(expected.length,9,'Original baseline must contain nine versions');
if(postDeploy) expected.push({file:'202610190001_teacher_browse.sql',sha256:'6830529e9cc9bbd9812f406bd7ce272492e199807e0126d5cc45ae2271f817b8'});
if(!path) throw new Error('Pass captured read-only preflight JSON; no remote commands run by this validator');
function findReport(value) {
  if(value && typeof value==='object') {
    if(value.teacher_read_preflight) return value.teacher_read_preflight;
    for(const child of Object.values(value)) { const found=findReport(child); if(found) return found; }
  }
}
const report=findReport(JSON.parse(await readFile(path,'utf8')));
assert.ok(report,'Unrecognized CLI result; stop rather than guessing');
assert.deepEqual(report.migration_history.map(row=>row.version),expected.map(row=>row.file.split('_')[0]));
for(const [index,row] of expected.entries()) {
  const sql=(await readFile(new URL('../migrations/'+row.file,import.meta.url),'utf8')).replaceAll('\r\n','\n');
  assert.equal(createHash('sha256').update(sql).digest('hex'),row.sha256,'Original local migration drift');
  const remote=report.migration_history[index];
  assert.equal(remote.name,row.file.replace(/^\d+_/,'').replace(/\.sql$/,''),'Remote migration name drift');
  assert.ok(Array.isArray(remote.statements),'Remote migration SQL unavailable: stop');
  if(JSON.stringify(sqlTokens(sql))!==JSON.stringify(sqlTokens(remote.statements.join('\n')))) {
    throw new Error('Historical remote SQL differs at '+remote.version+'; stop for review');
  }
}
for(const [key,expected] of Object.entries({application_tables:18,policy_count:30,
  tables_without_forced_rls:0,unsafe_definers:0,anonymous_rpc_execute:0,
  new_functions_present:postDeploy?3:0,approved_account_count:4,auth_user_count:4,platform_helper_preserved:true})) {
  assert.equal(report[key],expected,'Unexpected remote state: '+key);
}
const names=(await readdir(new URL('../migrations/',import.meta.url))).filter(n=>n.endsWith('.sql')).sort();
assert.deepEqual(names.slice(expected.length),postDeploy?[]:['202610190001_teacher_browse.sql']);
console.log(postDeploy?'PASS: all ten remote migration SQL bodies match; expected post-deploy structure.':'PASS: historical SQL and hashes match; expected remote baseline; exactly one approved pending file. Dry run still required.');
