// Only run after explicit human approval for hosted development account/data creation.
import { randomBytes } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { projectRef,url,keys,api,cli,restrictSecretFile } from './trusted_cli.mjs';

if(!process.argv.includes('--approved-development-fixtures')) {
  throw new Error('Explicit owner approval and --approved-development-fixtures are required');
}
const path=new URL('../../.env.development-accounts.json',import.meta.url);
const {adminKey}=keys();
let saved;
try { saved=JSON.parse(await readFile(path,'utf8')); } catch { saved={projectRef,url,accounts:[]}; }
if(saved.projectRef!==projectRef) throw new Error('Credential file belongs to another project');
for(const name of ['teacher-a','teacher-b','secretary-a','secretary-b']) {
  if(saved.accounts.some(a=>a.name===name)) continue;
  const email=`${name}@centerly.test`,password=randomBytes(30).toString('base64url');
  const result=await api('/auth/v1/admin/users',{key:adminKey,method:'POST',body:{email,password,email_confirm:true}});
  if(!result.ok) throw new Error(`Auth provisioning failed for synthetic ${name}: HTTP ${result.status}`);
  saved.accounts.push({name,email,password,id:result.data.id});
  await writeFile(path,JSON.stringify(saved,null,2),{mode:0o600});
  restrictSecretFile(path);
}
let sql=await readFile(new URL('../tests/fixtures.sql',import.meta.url),'utf8');
sql=sql.replace(/insert into auth\.users\(id\) values[\s\S]*?;/,'');
const sourceIds=['10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002'];
for(const [i,name] of ['teacher-a','teacher-b','secretary-a','secretary-b'].entries()) {
  const id=saved.accounts.find(a=>a.name===name).id;
  if(!/^[0-9a-f-]{36}$/i.test(id)) throw new Error('Invalid Auth UUID');
  sql=sql.replaceAll(sourceIds[i],id);
}
sql=sql.replace(/;(\s*(?:insert|$))/g,' on conflict do nothing;$1');
const fixturePath=resolve('supabase/.temp/approved_development_fixture.sql');
await writeFile(fixturePath,'begin;\n'+sql+'\ncommit;\n');
cli(['db','query','--linked','--file',fixturePath]);
console.log('Provisioned four synthetic accounts and two-tenant fixtures. Credentials saved only in ignored local file.');
