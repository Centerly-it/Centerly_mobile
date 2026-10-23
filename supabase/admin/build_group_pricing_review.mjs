// Reproducible local review artifacts. No hosted capabilities.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
const root=new URL('../',import.meta.url);
const files=['00_schema.sql','01_cycles.sql','02_billing.sql','03_triggers.sql','04_membership.sql'];
const body=(await Promise.all(files.map(f=>readFile(new URL('proposals/group_pricing/'+f,root),'utf8')))).join('');
const targets=[['proposals/202610230002_group_pricing.sql',body],['reviews/group-pricing-transaction.sql','begin;\n'+body+'\ncommit;\n']];
for(const [path,text] of targets){
 if(process.argv[2]==='--write')await writeFile(new URL(path,root),text);
 else assert.equal((await readFile(new URL(path,root),'utf8')).replaceAll('\r\n','\n'),text,'Review source drift');
}
console.log('PASS: local pricing review artifacts match their five focused sources');
