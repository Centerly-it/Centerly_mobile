// One owner-authorized migration only. No fixture, account or data mutations.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {projectRef,cli} from './trusted_cli.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const file='202610230003_simple_finance_edit.sql';
const sha=b=>createHash('sha256').update(b).digest('hex');
const baseline=JSON.parse(await readFile('build/pilot/baseline.json','utf8'));
assert.equal(baseline.pass,true);assert.equal(baseline.migrations,29);
assert.ok(Date.now()-Date.parse(baseline.at)<15*60000);
const snapshot=JSON.parse(await readFile('build/fin30/pre-data.json','utf8'));
assert.equal(snapshot.fingerprints.length,18);
const body=await readFile('supabase/migrations/'+file);
assert.equal(sha(body),'da8068b9da19e64b201a68491ac8ba38a6dd51fad9a69177df0f097bb0c75813');
assert.equal(sha(await readFile('supabase/reviews/simple-finance-edit-transaction.sql')),'0ddfcdb840777bf871d75212e19552d8807604d9de6d50ea044e399f2802d092');
// Capture stderr as well: CLI prints its migration plan there.
const dry=execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',
 '& npx.cmd --offline supabase --agent no db push --linked --skip-vault --dry-run 2>&1 | Out-String; exit $LASTEXITCODE'],
 {encoding:'utf8',timeout:120000,windowsHide:true});
const planned=[...dry.matchAll(/\b\d{12}_[a-z_]+\.sql\b/g)].map(x=>x[0]);
assert.deepEqual(planned,[file],'Unexpected migration plan; stop');
assert.match(dry,/DRY RUN/);assert.match(dry,/Would push/);
await writeFile('build/fin30/dry-run.log',dry);
console.log('Verified dry run: exactly '+file);
const applied=cli(['db','push','--linked','--skip-vault','--yes']);
await writeFile('build/fin30/deploy.log',applied);
console.log('Deployment command completed; postflight required before activation.');
