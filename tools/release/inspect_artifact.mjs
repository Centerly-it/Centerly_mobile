import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,stat,readdir} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
export async function inspectArtifact(){
 const apk='build/app/outputs/flutter-apk/app-prod-release.apk';
 const properties=await readFile('android/local.properties','utf8');
 const sdk=properties.split(/\r?\n/).find(l=>l.startsWith('sdk.dir=')).slice(8).replaceAll('\\\\','\\');
 const installed=(await readdir(sdk+'/build-tools')).filter(n=>/^\d+(?:\.\d+)*$/.test(n)).sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
 assert.ok(installed.length);const tools=sdk+'/build-tools/'+installed.at(-1)+'/';
 const badging=execFileSync(tools+'aapt.exe',['dump','badging',apk],{encoding:'utf8'});
 const match=badging.match(/package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'/);
 assert.ok(match);assert.equal(match[1],'com.centerly.teacher');
 const build=Number(match[2]),version=match[3];assert.match(version,/^\d+\.\d+\.\d+$/);assert.ok(build>0);
 const signature=execFileSync('java',['-jar',tools+'lib/apksigner.jar','verify','--print-certs',apk],{encoding:'utf8'});
 const fingerprint=signature.match(/Signer #1 certificate SHA-256 digest: ([a-fA-F0-9:]+)/)?.[1].replaceAll(':','').toLowerCase();
 assert.ok(fingerprint);assert.ok(!signature.includes('Android Debug'));
 const signing=Object.fromEntries((await readFile('android/key.properties','utf8')).trim().split(/\r?\n/).map(l=>[l.slice(0,l.indexOf('=')),l.slice(l.indexOf('=')+1)]));
 const certificate=execFileSync('keytool',['-exportcert','-alias',signing.keyAlias,'-keystore',resolve('android',signing.storeFile),'-storepass:env','CENTERLY_SIGNING_PASSWORD'],
  {env:{...process.env,CENTERLY_SIGNING_PASSWORD:signing.storePassword},stdio:['ignore','pipe','pipe']});
 assert.equal(fingerprint,createHash('sha256').update(certificate).digest('hex'));
 const scan=JSON.parse(execFileSync('python',['tools/release/scan_apk.py',apk],{encoding:'utf8'}));assert.equal(scan.pass,true);
 const size=(await stat(apk)).size;assert.ok(size<=300*1024*1024);
 const sha256=createHash('sha256').update(await readFile(apk)).digest('hex');
 const name=`centerly-${version}-${build}.apk`,tag=`v${version}-build.${build}`;
 const report={apk,packageId:match[1],build,version,minSdk:Number(badging.match(/sdkVersion:'(\d+)'/)?.[1]),
  size,sha256,fingerprint,name,tag,url:`https://github.com/Centerly-it/Centerly-releases/releases/download/${tag}/${name}`,scan};
 await mkdir('build/release',{recursive:true});
 await writeFile('build/release/artifact.json',JSON.stringify(report,null,2)+'\n');
 return report;
}
if(process.argv.includes('--inspect'))console.log(JSON.stringify(await inspectArtifact(),null,2));
