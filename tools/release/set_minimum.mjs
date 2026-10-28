// Owner-controlled promotion/withdrawal; never changes APK files or app data.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
const path='../Centerly_secretary/public/updates/android-prod.json';
const policy=JSON.parse(await readFile(path,'utf8'));
const disable=process.argv.includes('--disable');
const minimum=Number(process.argv.find(a=>a.startsWith('--minimum='))?.slice(10)??(disable?policy.minimum_build:NaN));
assert.equal(policy.environment,'production');assert.equal(policy.package_id,'com.centerly.teacher');
assert.ok(Number.isInteger(minimum)&&minimum>=0&&minimum<=policy.latest_build);
if(minimum>policy.minimum_build)assert.ok(process.argv.includes('--owner-tested'),
 'Only promote after owner confirms a real-device upgrade preserved existing data');
if(minimum<policy.minimum_build)assert.ok(process.argv.includes('--emergency-withdrawal'),
 'Lowering a requirement needs an explicit emergency-withdrawal flag');
policy.minimum_build=minimum;
if(disable){assert.ok(process.argv.includes('--emergency-withdrawal'));policy.enabled=false;}
await writeFile(path,JSON.stringify(policy,null,2)+'\n');
console.log('Prepared minimum supported build '+minimum+'. Push and deploy website metadata after review.');
