// Explicit owner authorization: create ONE empty Free production project.
// Reconcile by exact project name before creation; never clone test records.
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {resolve} from 'node:path';
import {randomBytes} from 'node:crypto';
import {management} from './management_api.mjs';
import {restrictSecretFile} from './trusted_cli.mjs';
assert.ok(process.argv.includes('--owner-approved'));
const org='bcpdbrqjcpipqclwwytx',dev='yfeubomyglmhuwizaqoj';
const baseline=JSON.parse(await readFile('build/pilot/baseline.json','utf8'));
assert.equal(baseline.pass,true);assert.equal(baseline.migrations,37);
assert.ok(Date.now()-Date.parse(baseline.at)<30*60000);
const organization=management('/v1/organizations/'+org);
assert.equal(organization.plan,'free','No paid resource creation authorized');
const projects=management('/v1/projects');
assert.ok(Array.isArray(projects));
assert.equal(projects.filter(p=>p.id===dev&&p.name==='centerly-dev').length,1);
const existing=projects.filter(p=>p.name==='centerly-prod'&&p.organization_id===org);
assert.ok(existing.length<=1);
const privatePath=resolve('.env.production-admin.json');
let registry;
try {registry=JSON.parse(await readFile(privatePath,'utf8'));}catch{}
if(existing.length){
 assert.equal(registry?.projectRef,existing[0].id,'Unrecognized existing production: stop without wiping it');
 console.log(JSON.stringify({created:false,reconciled:true,projectRef:existing[0].id,status:existing[0].status}));
}else{
 assert.ok(projects.filter(p=>p.status!=='INACTIVE').length<2,'Free project slot unavailable');
 assert.ok(!registry?.projectRef,'Recorded project missing: stop for reconciliation');
 const password=registry?.databasePassword??randomBytes(36).toString('base64url');
 registry={environment:'production',name:'centerly-prod',organization:org,databasePassword:password,createdByThisWorkflow:true};
 await writeFile(privatePath,JSON.stringify(registry,null,2),{mode:0o600});restrictSecretFile(privatePath);
 await mkdir('build/environments',{recursive:true});
 const body=resolve('build/environments/create-project.private.json');
 await writeFile(body,JSON.stringify({name:'centerly-prod',organization_slug:org,db_pass:password,region:'eu-west-3'}),{mode:0o600});restrictSecretFile(body);
 const project=management('/v1/projects',{method:'POST',bodyFile:body});
 assert.ok(/^[a-z]{20}$/.test(project.id));assert.notEqual(project.id,dev);
 registry.projectRef=project.id;
 await writeFile(privatePath,JSON.stringify(registry,null,2),{mode:0o600});restrictSecretFile(privatePath);
 console.log(JSON.stringify({created:true,projectRef:project.id,name:project.name,status:project.status,plan:organization.plan,accountsCreated:0}));
}
