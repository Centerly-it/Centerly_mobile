import {bootCluster} from './postgres_cluster.mjs';
import { Client } from 'pg';
import { randomBytes } from 'node:crypto';
import { mkdtemp, readFile, readdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve, relative } from 'node:path';

export async function startPostgres({through}={}) {
  const password=randomBytes(24).toString('hex');
  const databaseDir=await mkdtemp(join(tmpdir(),'centerly-pg-'));
  const port=55439;
  const server=await bootCluster({databaseDir,password,port});
  const clients=[];
  const connect=async actor=>{
    const c=new Client({host:'127.0.0.1',port,user:'postgres',password,database:'postgres'});
    await c.connect(); clients.push(c);
    if(actor) {
      await c.query("select set_config('request.jwt.claim.sub',$1,false)",[actor]);
      await c.query('set role authenticated');
    }
    await c.query("set statement_timeout='8s'; set lock_timeout='5s'");
    return c;
  };
  const admin=await connect();
  await admin.query(`create role anon; create role authenticated; create schema auth;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
    grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated;`);
  for(const name of (await readdir(new URL('../migrations/',import.meta.url))).sort()) {
    if(through && name.split('_')[0]>through) continue;
    await admin.query(await readFile(new URL('../migrations/'+name,import.meta.url),'utf8'));
  }
  await admin.query(await readFile(new URL('fixtures.sql',import.meta.url),'utf8'));
  return {admin,connect,close:async()=>{
    await Promise.all(clients.map(c=>c.end())); await server.stop();
    const target=resolve(databaseDir), child=relative(resolve(tmpdir()),target);
    if(child.startsWith('centerly-pg-') && !child.includes('..')) {
      await rm(target,{recursive:true,force:true,maxRetries:30,retryDelay:100});
    }
  }};
}
