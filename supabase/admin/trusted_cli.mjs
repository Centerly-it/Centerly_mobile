import { execFileSync } from 'node:child_process';
import { readFile,writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';

export const projectRef=(await readFile(new URL('../.temp/project-ref',import.meta.url),'utf8')).trim();
if(!/^[a-z]{20}$/.test(projectRef)) throw new Error('Invalid linked project reference');
export const url=`https://${projectRef}.supabase.co`;
export function cli(args) {
  // Commands are internal constants plus a validated ref/path, never user SQL text.
  if(process.platform!=='win32') throw new Error('Use the documented Windows operator workflow');
  const quote=value=>`'${String(value).replaceAll("'","''")}'`;
  const command='& npx.cmd '+['--yes','supabase','--agent','no',...args].map(quote).join(' ')+'; exit $LASTEXITCODE';
  try { return execFileSync('powershell.exe',['-NoProfile','-NonInteractive','-Command',command],
    {encoding:'utf8',stdio:['ignore','pipe','pipe']}); }
  catch { throw new Error('Trusted Supabase CLI operation failed; inspect CLI access separately.'); }
}
export function keys() {
  const rows=JSON.parse(cli(['projects','api-keys','--project-ref',projectRef,'--output','json']));
  const publicKey=rows.find(r=>r.type==='publishable')?.api_key;
  const adminKey=rows.find(r=>r.name==='service_role')?.api_key;
  if(!publicKey || !adminKey) throw new Error('Required project keys unavailable');
  return {publicKey,adminKey}; // Process memory only; never log this result.
}
export async function api(path,{key,token,method='GET',body}={}) {
  const response=await fetch(url+path,{method,headers:{apikey:key,
    Authorization:`Bearer ${token ?? key}`,'Content-Type':'application/json'},
    body:body===undefined?undefined:JSON.stringify(body)});
  const data=await response.json().catch(()=>null);
  return {status:response.status,ok:response.ok,data};
}
export async function querySql(sql) {
  const path=resolve(`supabase/.temp/approved_fixture_${randomUUID()}.sql`);
  await writeFile(path,sql);
  return cli(['db','query','--linked','--file',path]);
}
export function restrictSecretFile(path) {
  if(process.platform==='win32') {
    execFileSync('icacls.exe',[path instanceof URL?fileURLToPath(path):path,
      '/inheritance:r','/grant:r',`${process.env.USERDOMAIN}\\${process.env.USERNAME}:(F)`,
      '*S-1-5-18:(F)'],{stdio:'ignore'});
  }
}
