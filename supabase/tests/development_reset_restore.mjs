// Local PostgreSQL recovery drill. This file has no hosted connection capability.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {startPostgres} from './postgres.mjs';
const dir=new URL('../../build/owner-reset-20261023/',import.meta.url);
const bytes=await readFile(new URL('backup.json',dir));
const receipt=JSON.parse(await readFile(new URL('completed.json',dir),'utf8'));
assert.equal(createHash('sha256').update(bytes).digest('hex'),receipt.backupSha256);
const backup=JSON.parse(bytes),tables=Object.keys(backup).filter(t=>!['teachers','secretaries'].includes(t));
const pg=await startPostgres({through:'202610230001'});
try {
 await pg.admin.query('begin');
 await pg.admin.query("set local timezone='UTC'");
 await pg.admin.query('truncate table '+tables.map(t=>'public.'+t).join(','));
 // Privileged restore is confined to this disposable local cluster, never hosted.
 await pg.admin.query("set local session_replication_role='replica'");
 for(const id of [...backup.teachers,...backup.secretaries].map(r=>r.id))
  await pg.admin.query('insert into auth.users(id) values($1) on conflict do nothing',[id]);
 for(const t of ['teachers','secretaries',...tables])
  await pg.admin.query(`insert into public.${t} select * from jsonb_populate_recordset(null::public.${t},$1::jsonb)`,[JSON.stringify(backup[t])]);
 await pg.admin.query("set local session_replication_role='origin'");
 for(const t of tables){
  const restored=(await pg.admin.query(`select coalesce(jsonb_agg(to_jsonb(x) order by id),'[]') data from public.${t} x`)).rows[0].data;
  assert.deepEqual(restored,backup[t],t);
 }
 // Revalidate all FK relationships after restoring in dependency-independent order.
 const constraints=(await pg.admin.query("select conrelid::regclass::text t,conname n,pg_get_constraintdef(oid) d from pg_constraint where contype='f' and connamespace='public'::regnamespace")).rows;
 for(const c of constraints){
  await pg.admin.query(`alter table ${c.t} drop constraint "${c.n}"`);
  await pg.admin.query(`alter table ${c.t} add constraint "${c.n}" ${c.d}`);
 }
 await pg.admin.query('rollback');
 console.log(JSON.stringify({pass:true,restoredBusinessTables:tables.length,backupSha256:receipt.backupSha256,hostedWrites:0}));
} finally {await pg.close();}
