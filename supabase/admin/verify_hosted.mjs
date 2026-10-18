import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { projectRef,keys,api,querySql } from './trusted_cli.mjs';
import { testHostedMutations } from './verify_hosted_mutations.mjs';

if(!process.argv.includes('--approved-development-fixtures')) throw new Error('Owner approval required');
const saved=JSON.parse(await readFile(new URL('../../.env.development-accounts.json',import.meta.url),'utf8'));
assert.equal(saved.projectRef,projectRef);
const {publicKey,adminKey}=keys();
const sessions={};
let count=0;
for(const account of saved.accounts) {
  const result=await api('/auth/v1/token?grant_type=password',{key:publicKey,method:'POST',
    body:{email:account.email,password:account.password}});
  assert.equal(result.status,200,`Synthetic ${account.name} password login`); count++;
  sessions[account.name]={...account,token:result.data.access_token};
}
const request=(actor,path,method='GET',body)=>api(path,{key:publicKey,token:actor?.token,method,body});
const rpc=(actor,name,body)=>request(actor,`/rest/v1/rpc/${name}`,'POST',body);
const admin=async(table,id,body)=>{
  assert.ok(['teachers','secretaries'].includes(table)&&/^[0-9a-f-]{36}$/i.test(id));
  const updates=Object.entries(body).map(([key,value])=>{
    assert.ok(['status','subscription_status'].includes(key)&&['active','inactive'].includes(value));
    return `${key}='${value}'`;
  }).join(',');
  await querySql(`update public.${table} set ${updates} where id='${id}';`);
  return {ok:true};
};
const teacher=sessions['teacher-a'],other=sessions['teacher-b'],secretary=sessions['secretary-a'];
try {
  assert.equal((await rpc(teacher,'get_current_profile',{})).data.role,'teacher'); count++;
  assert.equal((await rpc(secretary,'get_current_profile',{})).data.role,'secretary'); count++;
  const anon=await request(null,'/rest/v1/students?select=id'); assert.ok([401,403].includes(anon.status)); count++;
  const student='30000000-0000-0000-0000-000000000001';
  assert.equal((await request(teacher,'/rest/v1/students?select=id')).data.length,1); count++;
  assert.deepEqual((await request(other,`/rest/v1/students?id=eq.${student}&select=id`)).data,[]); count++;
  assert.deepEqual((await request(sessions['secretary-b'],`/rest/v1/students?id=eq.${student}&select=id`)).data,[]); count++;
  const write=await request(teacher,'/rest/v1/students','POST',{teacher_id:teacher.id,full_name:'Forbidden fixture'});
  assert.equal(write.ok,false); count++;
  const forbidden=await rpc(teacher,'set_attendance',{p_session_id:'50000000-0000-0000-0000-000000000001',p_student_id:student,p_status:'present'});
  assert.equal(forbidden.data.message,'FORBIDDEN_ROLE'); count++;
  const note=await rpc(secretary,'save_teacher_note',{p_student_id:student,p_content:'forbidden'});
  assert.equal(note.data.message,'FORBIDDEN_ROLE'); count++;
  count+=await testHostedMutations({request,rpc,querySql,teacher,other,secretary,student,randomUUID});
  for(const [table,actor,patch,error] of [
    ['teachers',teacher,{subscription_status:'inactive'},'SUBSCRIPTION_INACTIVE'],
    ['teachers',teacher,{status:'inactive'},'ACCOUNT_INACTIVE'],
    ['secretaries',secretary,{status:'inactive'},'ACCOUNT_INACTIVE'],
  ]) {
    assert.ok((await admin(table,actor.id,patch)).ok);
    try {
      assert.equal((await rpc(actor,'get_current_profile',{})).data.message,error); count++;
      assert.deepEqual((await request(actor,'/rest/v1/students?select=id')).data,[]); count++;
    } finally {
      const restore=Object.fromEntries(Object.keys(patch).map(k=>[k,'active']));
      assert.ok((await admin(table,actor.id,restore)).ok);
    }
  }
  console.log(`PASS: ${count} hosted Auth/REST/RPC assertions against approved synthetic fixtures.`);
} finally {
  await Promise.all(Object.values(sessions).map(actor=>request(actor,'/auth/v1/logout?scope=local','POST')));
}
