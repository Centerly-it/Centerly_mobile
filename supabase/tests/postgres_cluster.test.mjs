import assert from 'node:assert/strict';
import {test} from 'node:test';
import {randomBytes} from 'node:crypto';
import {mkdtemp,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join,relative,resolve} from 'node:path';
import {bootCluster} from './postgres_cluster.mjs';
import {startPostgres} from './postgres.mjs';

test('failed native startup reports PostgreSQL diagnostics without its password',async()=>{
 const directory=await mkdtemp(join(tmpdir(),'centerly-pg-test-'));
 const password=randomBytes(24).toString('hex');
 try {
  // Force a real server startup rejection without opening any TCP listener.
  await assert.rejects(bootCluster({databaseDir:directory,password,port:70000}),error=>{
   assert.ok(error instanceof Error);
   assert.match(error.message,/PostgreSQL.*(?:initialization|startup|start)/s);
   assert.match(error.message,/70000|port|range/i);
   assert.equal(error.message.includes(password),false);
   return true;
  });
 } finally {
  const target=resolve(directory),child=relative(resolve(tmpdir()),target);
  assert.ok(child.startsWith('centerly-pg-test-')&&!child.includes('..'));
  await rm(target,{recursive:true,force:true,maxRetries:30,retryDelay:100});
 }
});

test('native database uses UTF8 and round-trips Arabic independent of OS code page',async()=>{
 const pg=await startPostgres();
 try {
  const value='طالب تجريبي 😀';
  const result=await pg.admin.query("select current_setting('server_encoding') as encoding,$1::text as value",[value]);
  assert.deepEqual(result.rows,[{encoding:'UTF8',value}]);
 } finally {await pg.close();}
});
