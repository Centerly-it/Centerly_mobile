// Read-only public business-table fingerprints; no records/credentials exported.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {querySql,projectRef} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
assert.equal(projectRef,'yfeubomyglmhuwizaqoj');
const phase=process.argv[2];assert.ok(['before','after'].includes(phase));
const tables=['teachers','secretaries','grade_levels','groups','students','group_enrollments','group_schedules','sessions','attendance','exams','assignments','invoices','payments','teacher_notes','notifications','secretary_removal_requests','attendance_change_log','audit_events'];
const parts=tables.map(t=>`select '${t}' name,count(*)::int count,md5(coalesce(string_agg(to_jsonb(x)::text,E'\\n' order by id),'')) hash from public.${t} x`);
const sql=`begin read only; select jsonb_agg(to_jsonb(v) order by name) snapshot from (${parts.join(' union all ')}) v; commit;`;
const snapshot=findField(parseCapture(await querySql(sql,{output:'json'})),'snapshot');
await writeFile(`build/pilot/history-${phase}.json`,JSON.stringify(snapshot,null,2)+'\n');
if(phase==='after')assert.deepEqual(snapshot,JSON.parse(await readFile('build/pilot/history-before.json','utf8')),'Business history drift');
console.log(JSON.stringify({phase,readOnly:true,tables:snapshot.length,unchanged:phase==='after'}));
