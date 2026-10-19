// Existing synthetic users only. No admin key, provisioning or Auth configuration.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {projectRef,api} from './trusted_cli.mjs';
export async function hostedContext() {
 if(!process.argv.includes('--approved-development-fixtures')) throw new Error('Synthetic-fixture authorization required');
 const credentials=JSON.parse(await readFile(new URL('../../.env.development-accounts.json',import.meta.url),'utf8'));
 const config=JSON.parse(await readFile(new URL('../../.env.local.json',import.meta.url),'utf8'));
 assert.equal(credentials.projectRef,projectRef);
 assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
 assert.equal(new URL(config.SUPABASE_URL).host,`${projectRef}.supabase.co`);
 const actors={};
 try {
  for(const account of credentials.accounts) {
   assert.ok(['teacher-a','teacher-b','secretary-a','secretary-b'].includes(account.name));
   assert.match(account.id,/^[0-9a-f-]{36}$/i);
   const response=await api('/auth/v1/token?grant_type=password',{key:config.SUPABASE_PUBLISHABLE_KEY,
    method:'POST',body:{email:account.email,password:account.password}});
   assert.equal(response.status,200,'Synthetic account login failed');
   actors[account.name]={id:account.id,token:response.data.access_token};
  }
 } catch(e) {await close();throw e;}
 const request=(actor,path,method='GET',body)=>api(path,{key:config.SUPABASE_PUBLISHABLE_KEY,token:actor?.token,method,body});
 const rpc=(actor,name,body)=>request(actor,`/rest/v1/rpc/${name}`,'POST',body);
 async function close() {
  await Promise.all(Object.values(actors).map(actor=>api('/auth/v1/logout?scope=local',{
   key:config.SUPABASE_PUBLISHABLE_KEY,token:actor.token,method:'POST'})));
 }
 return {actors,request,rpc,close,teacher:actors['teacher-a'],other:actors['teacher-b'],secretary:actors['secretary-a'],
  student:'30000000-0000-0000-0000-000000000001',group:'40000000-0000-0000-0000-000000000001'};
}
