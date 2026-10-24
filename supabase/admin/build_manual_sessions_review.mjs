import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
const root=new URL('../',import.meta.url),folder=new URL('proposals/manual_sessions/',root);
const names=(await readdir(folder)).filter(n=>n.endsWith('.sql')).sort();
const body=(await Promise.all(names.map(n=>readFile(new URL(n,folder),'utf8')))).join('\n');
for(const [name,content] of [['proposals/202610240001_manual_sessions.sql',body],['migrations/202610240001_manual_sessions.sql',body],['reviews/manual-sessions-transaction.sql','begin;\n'+body+'\ncommit;\n']])assert.equal((await readFile(new URL(name,root),'utf8')).replaceAll('\r\n','\n'),content.replaceAll('\r\n','\n'),'Manual session source drift');
console.log('Manual session deployed artifacts match seven focused sources');
