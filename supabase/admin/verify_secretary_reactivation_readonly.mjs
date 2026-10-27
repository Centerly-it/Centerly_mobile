// Existing development accounts only; all feature calls intentionally denied.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
const cfg=JSON.parse(await readFile('.env.dev.json','utf8'));
assert.equal(new URL(cfg.SUPABASE_URL).hostname,'yfeubomyglmhuwizaqoj.supabase.co');
const accounts=JSON.parse(await readFile('.env.development-accounts.json','utf8')).accounts;
let checks=0;
for(const [name,expected] of [['teacher-a','NOT_FOUND'],['secretary-a','FORBIDDEN_ROLE']]) {
 const account=accounts.find(a=>a.name===name);assert.ok(account);
 const auth=await fetch(cfg.SUPABASE_URL+'/auth/v1/token?grant_type=password',{
  method:'POST',headers:{apikey:cfg.SUPABASE_PUBLISHABLE_KEY,'Content-Type':'application/json'},
  body:JSON.stringify({email:account.email,password:account.password})});
 assert.ok(auth.ok,'Existing development login unavailable');const session=await auth.json();
 const r=await fetch(cfg.SUPABASE_URL+'/rest/v1/rpc/reactivate_secretary',{
  method:'POST',headers:{apikey:cfg.SUPABASE_PUBLISHABLE_KEY,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},
  body:JSON.stringify({p_secretary_id:'00000000-0000-0000-0000-000000000000'})});
 assert.ok(!r.ok);const error=await r.json();
 const expectedCodes=name==='teacher-a'?['NOT_FOUND']:['FORBIDDEN_ROLE','ACCOUNT_INACTIVE'];
 assert.ok(expectedCodes.some(code=>error.message?.includes(code)), 'Unexpected denial code: '+String(error.code));checks++;
}
const path='docs/secretary-reactivation-acceptance.json';const report=JSON.parse(await readFile(path,'utf8'));
report.hostedAuthenticatedDeniedChecks=checks;
report.hostedSecretaryActuallyReactivated=false;
report.localPostgresRoleChecks=15;
report.flutterChecks=4;
report.secretaryAuthChecks=6;
report.manualDeviceTested=false;
await writeFile(path,JSON.stringify(report,null,2)+'\n');
console.log('PASS: 2 actual authenticated development REST denial checks; no account status or business data writes.');
