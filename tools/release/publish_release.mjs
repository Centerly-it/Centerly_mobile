// Upload binary only. All artifacts are inspected before a public release exists.
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {inspectArtifact} from './inspect_artifact.mjs';
import {github} from './github_api.mjs';
assert.ok(process.argv.includes('--owner-approved'));
const info=await inspectArtifact();
const base='/repos/Centerly-it/Centerly-releases';
let release=await github(base+'/releases/tags/'+info.tag);
if(!release)release=await github(base+'/releases',{method:'POST',body:{tag_name:info.tag,name:'Centerly '+info.version,
 draft:true,prerelease:false,body:`Signed Centerly Android production APK.\n\nApplication ID: ${info.packageId}\nVersion: ${info.version} (${info.build})\nAPK SHA256: ${info.sha256}\nSigning certificate SHA256: ${info.fingerprint}\n\nInstall over a previous production release using Android's confirmation screen. No accounts, credentials, or source code are distributed here.`}});
let asset=release.assets.find(a=>a.name===info.name);
if(asset){assert.equal(asset.size,info.size);assert.equal(asset.digest,'sha256:'+info.sha256,'Existing asset differs; use a higher build instead of overwriting');}
else{
 assert.equal(release.draft,true,'Never mutate a published version');
 asset=await github(base+`/releases/${release.id}/assets?name=${encodeURIComponent(info.name)}`,{
  method:'POST',upload:true,bytes:await readFile(info.apk)});
 assert.equal(asset.size,info.size);assert.equal(asset.digest,'sha256:'+info.sha256);
}
if(!process.argv.includes('--publish')){
 console.log('Verified draft binary uploaded; no update policy changed.');
}else{
 if(release.draft)release=await github(base+'/releases/'+release.id,{method:'PATCH',body:{draft:false,make_latest:'true'}});
 const response=await fetch(info.url,{signal:AbortSignal.timeout(300000)});
 assert.equal(response.status,200,'Public download not available; do not activate policy');
 const digest=createHash('sha256');let size=0;
 for await(const chunk of response.body){size+=chunk.length;assert.ok(size<=info.size);digest.update(chunk);}
 assert.equal(size,info.size);assert.equal(digest.digest('hex'),info.sha256);
 const minimum=Number(process.argv.find(a=>a.startsWith('--minimum='))?.slice(10)??1);
 assert.ok(Number.isInteger(minimum)&&minimum>=0&&minimum<=info.build);
 const folder='../Centerly_secretary/public/updates';await mkdir(folder,{recursive:true});
 const policy={schema:1,enabled:true,environment:'production',package_id:info.packageId,
  latest_build:info.build,minimum_build:minimum,version:info.version,url:info.url,sha256:info.sha256,size:info.size,min_sdk:info.minSdk};
 const existing=await readFile(folder+'/android-prod.json','utf8').then(JSON.parse,()=>null);
 if(existing?.enabled && minimum>existing.minimum_build)assert.ok(process.argv.includes('--owner-tested'),'Required rollout needs owner device acceptance');
 await writeFile(folder+'/android-prod.json',JSON.stringify(policy,null,2)+'\n');
 await writeFile(folder+'/android-dev.json',JSON.stringify({schema:1,enabled:false,environment:'development',package_id:'com.centerly.teacher.dev'},null,2)+'\n');
 await writeFile('build/release/published.json',JSON.stringify({release:release.html_url,asset:info.url,...policy},null,2)+'\n');
 console.log('Published verified production APK and prepared policy files: '+info.url);
}
