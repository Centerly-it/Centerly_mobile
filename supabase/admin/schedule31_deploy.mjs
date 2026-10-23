// One owner-authorized migration only. No fixture, account or data mutations.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {projectRef,cli} from './trusted_cli.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const file='202610230004_required_group_schedule.sql';
const sha=b=>createHash('sha256').update(b).digest('hex');
const baseline=JSON.parse(await readFile('build/pilot/baseline.json','utf8'));
assert.equal(baseline.pass,true);assert.equal(baseline.migrations,30);
assert.ok(Date.now()-Date.parse(baseline.at)<15*60000);
const snapshot=JSON.parse(await readFile('build/schedule31/pre-data.json','utf8'));
assert.equal(snapshot.fingerprints.length,18);
const body=await readFile('supabase/migrations/'+file);
assert.equal(sha(body),'006e350c0847773da71f68af2f9d8b36d278d2d8a95f06590af38ccbb621e6c6');
assert.equal(sha(await readFile('supabase/reviews/required-group-schedule-transaction.sql')),'7e971ccaa01698421413e20454302b743f5a02ff47105027717360f82b4ce5b1');
// Capture stderr as well: CLI prints its migration plan there.
const dry=execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',
 '& npx.cmd --offline supabase --agent no db push --linked --skip-vault --dry-run 2>&1 | Out-String; exit $LASTEXITCODE'],
 {encoding:'utf8',timeout:120000,windowsHide:true});
const planned=[...dry.matchAll(/\b\d{12}_[a-z_]+\.sql\b/g)].map(x=>x[0]);
assert.deepEqual(planned,[file],'Unexpected migration plan; stop');
assert.match(dry,/DRY RUN/);assert.match(dry,/Would push/);
await writeFile('build/schedule31/dry-run.log',dry);
console.log('Verified dry run: exactly '+file);
const applied=cli(['db','push','--linked','--skip-vault','--yes']);
await writeFile('build/schedule31/deploy.log',applied);
console.log('Deployment command completed; postflight required before activation.');
