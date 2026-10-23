// Generates/checks local proposal artifacts only; no hosted capabilities.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
const root=new URL('../',import.meta.url);
const files=['00_schema.sql','01_edit.sql','02_secretary_browse.sql','03_get_teacher_invoice_detail.sql','04_get_teacher_finance.sql','05_list_teacher_finance_dues.sql'];
const body=(await Promise.all(files.map(f=>readFile(new URL('proposals/finance_edit/'+f,root),'utf8')))).join('\n');
for(const [path,text] of [['proposals/202610230003_simple_finance_edit.sql',body],['reviews/simple-finance-edit-transaction.sql','begin;\n'+body+'\ncommit;\n']]){
 if(process.argv[2]==='--write')await writeFile(new URL(path,root),text);
 else assert.equal((await readFile(new URL(path,root),'utf8')).replaceAll('\r\n','\n'),text,'Financial review source drift');
}
console.log('Financial review artifacts match their six focused sources');
