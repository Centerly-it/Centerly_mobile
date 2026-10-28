// Reuse Git's existing credential in RAM only; never echo credentials or API bodies.
import {execFileSync} from 'node:child_process';
let token;
function credential(){
 if(!token){
  const text=execFileSync('git',['credential','fill'],{input:'protocol=https\nhost=github.com\n\n',encoding:'utf8',stdio:['pipe','pipe','pipe']});
  token=text.split(/\r?\n/).find(l=>l.startsWith('password='))?.slice(9);
  if(!token)throw new Error('Existing Git credential unavailable');
 }
 return token;
}
export async function github(path,{method='GET',body,bytes,upload=false}={}) {
 if(!path.startsWith('/'))throw new Error('Invalid API path');
 const response=await fetch('https://'+(upload?'uploads.github.com':'api.github.com')+path,{
  method,headers:{Authorization:'Bearer '+credential(),Accept:'application/vnd.github+json',
   'X-GitHub-Api-Version':'2022-11-28','Content-Type':bytes?'application/vnd.android.package-archive':'application/json'},
  body:bytes??(body===undefined?undefined:JSON.stringify(body)),signal:AbortSignal.timeout(bytes?300000:30000)});
 if(response.status===404)return null;
 if(!response.ok)throw new Error('GitHub API request failed: HTTP '+response.status);
 return response.status===204?null:response.json();
}
