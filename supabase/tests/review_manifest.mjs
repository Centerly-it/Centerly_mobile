import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFile,readdir} from 'node:fs/promises';
export async function verifyReviewedSql(reviewUrl,folderUrl,count) {
 const review=await readFile(reviewUrl,'utf8');
 const rows=[...review.matchAll(/\| `(\d{12}_[^`]+\.sql)` \| `([a-f0-9]{64})` \|/g)];
 const files=(await readdir(folderUrl)).filter(f=>f.endsWith('.sql')).sort();
 assert.equal(rows.length,count,'Review must pin every proposal');
 assert.deepEqual(files,rows.map(r=>r[1]).sort(),'Unexpected proposal file');
 for(const [,file,expected] of rows) {
 const bytes=await readFile(new URL(file,folderUrl));
 assert.equal(createHash('sha256').update(bytes).digest('hex'),expected,'Changed SQL requires revised review: '+file);
 }
 console.log(`Exact SQL review: ${count} proposal hashes PASS; no hosted access.`);
}
