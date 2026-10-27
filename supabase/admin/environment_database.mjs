import assert from 'node:assert/strict';
import {mkdir,writeFile} from 'node:fs/promises';
import {randomUUID} from 'node:crypto';
import {resolve} from 'node:path';
import {management} from './management_api.mjs';
export async function environmentQuery(ref,query,{write=false}={}) {
 assert.ok(/^[a-z]{20}$/.test(ref));
 if(write)assert.equal(ref,'ohhwccwwwxfmwpfypfyf','Writes allowed only to newly created production');
 await mkdir('build/environments/requests',{recursive:true});
 const file=resolve('build/environments/requests/'+randomUUID()+'.json');
 await writeFile(file,JSON.stringify({query,read_only:!write}),{mode:0o600});
 return management('/v1/projects/'+ref+'/database/query',{method:'POST',bodyFile:file});
}
