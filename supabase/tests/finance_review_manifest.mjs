import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFile,readdir} from 'node:fs/promises';

// Verify exact reviewed bytes before booting any disposable database.
export async function verifyFinanceReview() {
 const review=await readFile(new URL('../../docs/FINANCE_BACKEND_CHANGE_REVIEW.md',import.meta.url),'utf8');
 const rows=[...review.matchAll(/\| `(20261020\d{4}_[^`]+\.sql)` \| `([a-f0-9]{64})` \|/g)];
 const files=(await readdir(new URL('../proposals/finance_business/',import.meta.url))).filter(f=>f.endsWith('.sql')).sort();
 assert.equal(rows.length,3,'Finance deployment review must pin all three proposals');
 assert.deepEqual(files,rows.map(r=>r[1]).sort(),'Unexpected finance proposal file');
 for(const [,name,expected] of rows) {
  const bytes=await readFile(new URL('../proposals/finance_business/'+name,import.meta.url));
  assert.equal(createHash('sha256').update(bytes).digest('hex'),expected,'Changed SQL requires revised review: '+name);
 }
 console.log('Finance review: three exact proposal hashes PASS; no hosted access.');
}
