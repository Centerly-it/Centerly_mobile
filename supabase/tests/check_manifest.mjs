import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile,readdir } from 'node:fs/promises';

const root=new URL('../',import.meta.url);
const manifest=JSON.parse(await readFile(new URL('schema-manifest.json',root),'utf8'));
const names=(await readdir(new URL('migrations/',root))).filter(n=>n.endsWith('.sql')).sort();
assert.deepEqual(names.slice(0,manifest.migrations.length),manifest.migrations.map(r=>r.file));
for(const row of manifest.migrations) {
  const sql=(await readFile(new URL('migrations/'+row.file,root),'utf8')).replaceAll('\r\n','\n');
  assert.equal(createHash('sha256').update(sql).digest('hex'),row.sha256,`Deployed migration was edited: ${row.file}`);
}
console.log(`PASS: ${manifest.migrations.length} deployed migration hashes unchanged; ${names.length-manifest.migrations.length} new pending versions.`);
