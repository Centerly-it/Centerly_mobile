// Public/anonymous guard checks only: production deliberately has no accounts yet.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
let checks=0;
for(const [name,ref] of [['dev','yfeubomyglmhuwizaqoj'],['prod','ohhwccwwwxfmwpfypfyf']]){
 const c=JSON.parse(await readFile('.env.'+name+'.json','utf8'));
 assert.equal(new URL(c.SUPABASE_URL).hostname,ref+'.supabase.co');checks++;
 const headers={apikey:c.SUPABASE_PUBLISHABLE_KEY,'Content-Type':'application/json'};
 const response=await fetch(c.SUPABASE_URL+'/rest/v1/rpc/get_current_profile',{
  method:'POST',headers,body:'{}',signal:AbortSignal.timeout(25000)});
 const result=await response.json();
 assert.equal(response.ok,false);assert.match(result.message,/AUTH_REQUIRED|permission denied for function get_current_profile/);checks++;
 const settings=await fetch(c.SUPABASE_URL+'/auth/v1/settings',{headers,signal:AbortSignal.timeout(25000)});
 assert.equal(settings.ok,true);checks++;
}
const report={at:new Date().toISOString(),pass:true,checks,mode:'actual hosted anonymous REST guards; no user accounts created',businessWrites:0,authenticatedProductionChecks:'unavailable until the owner provisions a real account'};
await writeFile('build/environments/rest-smoke.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
