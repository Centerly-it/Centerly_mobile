import {readFile} from 'node:fs/promises';
export async function readCapture(path) {
 return parseCapture(await readFile(path,'utf8'));
}
export function parseCapture(raw) {
 const text=raw.replace(/^\uFEFF/,'');
 // CLI diagnostics can precede JSON; decode only the complete structured result.
 for(let i=0;i<text.length;i++) if(text[i]==='['||text[i]==='{') {
  try {return JSON.parse(text.slice(i));} catch { /* Try next structured opening. */ }
 }
 throw new Error('No valid complete CLI JSON result');
}
export function findField(value,key) {
 if(value && typeof value==='object') {
  if(Object.hasOwn(value,key)) return value[key];
  for(const child of Object.values(value)) {const found=findField(child,key);if(found!==undefined)return found;}
 }
}
