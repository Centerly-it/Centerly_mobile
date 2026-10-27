import {querySql} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
import {mkdir,writeFile} from 'node:fs/promises';
const sql="begin read only; select jsonb_agg(jsonb_build_object('version',version,'name',name,'statements',statements) order by version) history from supabase_migrations.schema_migrations where version>'202610240002'; commit;";
const history=findField(parseCapture(await querySql(sql,{output:'json'})),'history');
await mkdir('build/environments',{recursive:true});
await writeFile('build/environments/recovered-history.json',JSON.stringify(history,null,2));
console.log(JSON.stringify({readOnly:true,recoveredVersions:history.map(row=>({version:row.version,name:row.name,statements:row.statements.length}))}));
