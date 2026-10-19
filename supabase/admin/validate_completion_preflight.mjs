import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {sqlTokens} from './sql_tokens.mjs';
import {readCapture,findField} from './read_capture.mjs';
const root=new URL('../',import.meta.url);
const manifest=JSON.parse(await readFile(new URL('schema-manifest.json',root),'utf8'));
const pin=JSON.parse(await readFile(new URL('completion-package-manifest.json',root),'utf8'));
assert.equal((await readFile(new URL('.temp/project-ref',root),'utf8')).trim(),pin.projectRef);
const post=process.argv.includes('--post-deploy');
const base=manifest.migrations.filter(r=>r.file.split('_')[0]<='202610190003');
assert.equal(base.length,12);assert.equal(pin.migrations.length,7);
const report=findField(await readCapture(process.argv[2]),'teacher_read_preflight');
assert.ok(report,'Missing read-only inventory');
const expected=post?[...base,...pin.migrations]:base;
assert.deepEqual(report.migration_history.map(r=>r.version),expected.map(r=>r.file.split('_')[0]));
for(const row of [...base,...pin.migrations]) {
 const proposal=row.file.split('_')[0]>'202610190003';
 const sql=(await readFile(new URL((proposal?'proposals/teacher_completion/':'migrations/')+row.file,root),'utf8')).replaceAll('\r\n','\n');
 assert.equal(createHash('sha256').update(sql).digest('hex'),row.sha256,'Reviewed hash drift: '+row.file);
 const remote=report.migration_history.find(r=>r.version===row.file.split('_')[0]);
 if(remote) {
  assert.equal(remote.name,row.file.replace(/^\d+_/,'').replace(/\.sql$/,''));
  assert.deepEqual(sqlTokens(remote.statements.join('\n')),sqlTokens(sql),'Remote body drift: '+row.file);
 }
 if(post&&proposal) {
  const managed=(await readFile(new URL('migrations/'+row.file,root),'utf8')).replaceAll('\r\n','\n');
  assert.equal(managed,sql,'Managed/proposal differs');
 }
}
for(const [key,value] of Object.entries({application_tables:18,policy_count:30,tables_without_forced_rls:0,
 unsafe_definers:0,anonymous_rpc_execute:0,new_functions_present:3,detail_function_present:1,
 profile_function_present:1,auth_user_count:4,approved_account_count:4,platform_helper_preserved:true}))
 assert.equal(report[key],value,'Unexpected remote state: '+key);
if(post) {
 const meta=findField(await readCapture(process.argv[3]),'completion_metadata');
 assert.equal(meta.functions.length,12);
 for(const fn of meta.functions) {
  assert.equal(fn.public_execute,false);assert.equal(fn.anon_execute,false);
  assert.equal(fn.authenticated_execute,fn.schema==='public');
  assert.ok(fn.config.includes('search_path=""'));
  assert.equal(fn.definer,!['check_teacher_window','teacher_page'].includes(fn.name));
 }
 assert.deepEqual(meta.indexes,['teacher_assignment_history','teacher_attendance_history','teacher_exam_history',
  'teacher_invoice_history','teacher_notification_page','teacher_payment_history']);
 assert.equal(meta.triggers.length,2);
 assert.ok(meta.triggers.every(t=>t.enabled==='O'));
 for(const trigger of meta.triggers) {
  assert.equal(trigger.function,trigger.name);
  assert.ok(trigger.definition.includes(trigger.name==='notify_teacher_payment'?'AFTER INSERT ON public.payments':'AFTER UPDATE ON public.secretary_removal_requests'));
  assert.ok(trigger.definition.includes('EXECUTE FUNCTION private.'+trigger.name+'()'));
 }
}
console.log(`PASS: ${expected.length} exact remote SQL bodies, reviewed package hashes${post?', functions/grants/indexes/triggers':''}.`);
