// Reuse the existing operator CLI credential in memory; never log it.
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
export function management(path,{method='GET',bodyFile}={}) {
 const args=['-NoProfile','-NonInteractive','-File',fileURLToPath(new URL('management_request.ps1',import.meta.url)),'-ApiPath',path,'-Method',method];
 if(bodyFile)args.push('-BodyFile',bodyFile);
 try{
  const value=JSON.parse(execFileSync('powershell.exe',args,{encoding:'utf8',timeout:75000,windowsHide:true,stdio:['ignore','pipe','pipe']}));
  return Array.isArray(value?.value)&&Number.isInteger(value?.Count)?value.value:value;
 }
 catch{throw new Error('Management request failed; private response suppressed');}
}
