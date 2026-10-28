import assert from 'node:assert/strict';
import {github} from './github_api.mjs';
const path='/repos/Centerly-it/Centerly-releases';
let repo=await github(path);
if(!repo)repo=await github('/orgs/Centerly-it/repos',{method:'POST',body:{
 name:'Centerly-releases',description:'Official Centerly Android APK downloads. No application source or customer data.',
 private:false,auto_init:true,has_issues:false,has_projects:false,has_wiki:false}});
assert.equal(repo.full_name,'Centerly-it/Centerly-releases');
assert.equal(repo.private,false);
console.log('Verified approved public downloads repository: '+repo.html_url);
