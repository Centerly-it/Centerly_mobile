// One owner-authorized migration only. No fixture, account or data mutations.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {projectRef,cli} from './trusted_cli.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const file='202610240001_manual_sessions.sql';
const sha=b=>createHash('sha256').update(b).digest('hex');
const baseline=JSON.parse(await readFile('build/pilot/baseline.json','utf8'));
assert.equal(baseline.pass,true);assert.equal(baseline.migrations,32);
assert.ok(Date.now()-Date.parse(baseline.at)<15*60000);
const snapshot=JSON.parse(await readFile('build/manual33/pre-data.json','utf8'));
assert.equal(snapshot.fingerprints.length,18);
const body=await readFile('supabase/migrations/'+file);
assert.equal(sha(body),'2fdf329a8abae1545c4e08e2a9cc6c7c8daf695a4845f3e4ac61496c4af76da4');
assert.equal(sha(await readFile('supabase/reviews/manual-sessions-transaction.sql')),'61039345fbc739fb6c1a7916783d7c56aad2ec6d26cf6c6d371f714461b1dfc1');
// Capture stderr as well: CLI prints its migration plan there.
const dry=execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',
 '& npx.cmd --offline supabase --agent no db push --linked --skip-vault --dry-run 2>&1 | Out-String; exit $LASTEXITCODE'],
 {encoding:'utf8',timeout:120000,windowsHide:true});
const planned=[...dry.matchAll(/\b\d{12}_[a-z_]+\.sql\b/g)].map(x=>x[0]);
assert.deepEqual(planned,[file],'Unexpected migration plan; stop');
assert.match(dry,/DRY RUN/);assert.match(dry,/Would push/);
await writeFile('build/manual33/dry-run.log',dry);
console.log('Verified dry run: exactly '+file);
const applied=cli(['db','push','--linked','--skip-vault','--yes']);
await writeFile('build/manual33/deploy.log',applied);
console.log('Deployment command completed; postflight required before activation.');
