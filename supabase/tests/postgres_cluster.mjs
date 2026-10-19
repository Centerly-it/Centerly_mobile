import EmbeddedPostgres from 'embedded-postgres';
import {spawn} from 'node:child_process';
import {open,readFile} from 'node:fs/promises';
import {join} from 'node:path';

export async function bootCluster({databaseDir,password,port}) {
 const messages=[];
 const log=message=>{messages.push(String(message));if(messages.length>25)messages.shift();};
 const server=new EmbeddedPostgres({databaseDir,user:'postgres',password,port,
  persistent:true,postgresFlags:['-h','127.0.0.1'],onLog:log,onError:log});
 const diagnostic=error=>[error?.message,...messages].filter(Boolean).join('\n')
  .replaceAll(password,'[REDACTED]').slice(-6000);
 // pg_ctl starts PostgreSQL with a restricted Windows token. Direct postgres.exe
 // startup can fail under elevated CI runners; embedded-postgres rejects undefined
 // on early exit, losing stderr. Keep the same pinned PostgreSQL 17 binaries.
 if(process.platform==='win32') {
  const {pg_ctl}=await import('@embedded-postgres/windows-x64');
  const logFile=join(databaseDir,'postgres.log');
  let running=false;
  const control=async args=>{
   // A detached server can inherit pipe handles from pg_ctl. File descriptors
   // avoid waiting forever for pipe EOF after the controller itself has exited.
   const output=await open(join(databaseDir,'pg_ctl.log'),'a');
   try {
    await new Promise((resolve,reject)=>{
     const child=spawn(pg_ctl,['-D',databaseDir,...args],{
      windowsHide:true,stdio:['ignore',output.fd,output.fd],
      env:{...process.env,LC_MESSAGES:'C'},
     });
     const timer=setTimeout(()=>{child.kill();reject(new Error('pg_ctl timed out'));},45000);
     child.once('error',error=>{clearTimeout(timer);reject(error);});
     child.once('exit',code=>{clearTimeout(timer);code===0?resolve():reject(new Error(`pg_ctl exited ${code}`));});
    });
   } finally {await output.close();}
  };
  server.start=async()=>{
   try {
    await control(['-l',logFile,'-o',`-h 127.0.0.1 -p ${port}`,'-w','-t','30','start']);
    running=true;
   } catch(error) {
    log(await readFile(logFile,'utf8').catch(()=>''));
    log(await readFile(join(databaseDir,'pg_ctl.log'),'utf8').catch(()=>''));
    await control(['-m','immediate','-w','-t','10','stop']).catch(()=>{});
    throw new Error('Disposable PostgreSQL startup failed:\n'+diagnostic(error));
   }
  };
  server.stop=async()=>{
   if(!running)return;
   await control(['-m','fast','-w','-t','15','stop']);running=false;
  };
 }
 try {
  await server.initialise();
  await server.start();
  return server;
 } catch(error) {
  await server.stop().catch(()=>{});
  throw new Error('Disposable PostgreSQL initialization/start failed:\n'+diagnostic(error));
 }
}
