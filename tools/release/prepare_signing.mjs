import assert from 'node:assert/strict';
import {randomBytes} from 'node:crypto';
import {mkdir,readFile,writeFile,access} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {resolve} from 'node:path';
assert.ok(process.argv.includes('--owner-approved'));
const key=resolve('android/keystore/centerly-release.jks'),properties=resolve('android/key.properties');
const exists=p=>access(p).then(()=>true,()=>false);
if(await exists(key)||await exists(properties)){
 assert.ok(await exists(key)&&await exists(properties),'Partial signing setup; reconcile securely');
 console.log('Existing signing material retained; no key replacement.');
}else{
 await mkdir('android/keystore',{recursive:true});
 const password=randomBytes(32).toString('hex');
 try{
  execFileSync('keytool',['-genkeypair','-keystore',key,'-storetype','JKS','-alias','centerly-release',
   '-keyalg','RSA','-keysize','4096','-validity','10000','-dname','CN=Centerly, OU=Mobile, O=Centerly, C=EG',
   '-storepass:env','CENTERLY_SIGNING_PASSWORD','-keypass:env','CENTERLY_SIGNING_PASSWORD'],
   {env:{...process.env,CENTERLY_SIGNING_PASSWORD:password},stdio:['ignore','pipe','pipe']});
 }catch{throw new Error('Signing-key creation failed; private output suppressed');}
 await writeFile(properties,'storeFile=keystore/centerly-release.jks\nstorePassword='+password+
  '\nkeyAlias=centerly-release\nkeyPassword='+password+'\n',{mode:0o600});
}
for(const path of [key,properties])execFileSync('icacls',[path,'/inheritance:r','/grant:r',
 `${process.env.USERDOMAIN}\\${process.env.USERNAME}:(F)`,'*S-1-5-18:(F)'],{stdio:'ignore'});
await mkdir('build/release-private',{recursive:true});
const backup=resolve('build/release-private/centerly-signing-backup.zip');
const command='Compress-Archive -LiteralPath '+[key,properties].map(p=>"'"+p.replaceAll("'","''")+"'").join(',')+
 ' -DestinationPath '+"'"+backup.replaceAll("'","''")+"' -Force";
execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',command],{stdio:['ignore','pipe','pipe']});
execFileSync('icacls',[backup,'/inheritance:r','/grant:r',`${process.env.USERDOMAIN}\\${process.env.USERNAME}:(F)`,'*S-1-5-18:(F)'],{stdio:'ignore'});
console.log('Owner-approved signing key and private local backup ready. No credentials printed or uploaded.');
