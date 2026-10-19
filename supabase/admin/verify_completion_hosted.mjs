import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {randomUUID} from 'node:crypto';
import {hostedContext} from './completion_hosted_context.mjs';
import {verifyCompletionReads} from './verify_completion_reads.mjs';
import {verifyCompletionMoney} from './verify_completion_money.mjs';
import {verifyCompletionWorkflows} from './verify_completion_workflows.mjs';
import {testHostedMutations} from './verify_hosted_mutations.mjs';
import {querySql} from './trusted_cli.mjs';
const c=await hostedContext();let checks=0;
const eq=(actual,expected)=>{assert.deepEqual(actual,expected);checks++;};
try {
 const calendar=await c.rpc(c.teacher,'get_teacher_calendar',{p_from:'2026-10-19',p_to:'2026-10-19'});
 eq(calendar.ok,true);c.date=calendar.data.server_date;
 await verifyCompletionReads(c,eq);
 await verifyCompletionMoney(c,eq);
 await verifyCompletionWorkflows(c,eq);
 checks+=await testHostedMutations({...c,querySql,randomUUID});
 const report={date:c.date,project:'centerly-dev',checks,passed:true,
  syntheticOnly:true,accountOrAuthChanges:false,invoice:c.invoice,historySession:c.historySession,
  coverage:['real password roles','seven read contracts','tenant and anonymous denial','payment/reversal idempotency',
   'exactly-once payment and removal events','payment/event/invoice rollback','null versus zero scores',
   'manual attendance after thirty days','finalization correction','note optimistic conflict','removal without deactivation',
   'notification read idempotency','cancellation race']};
 await writeFile(new URL('../../.buildlog/completion_hosted_result.json',import.meta.url),JSON.stringify(report,null,2));
 console.log(`PASS: ${checks} hosted completion assertions; only approved synthetic fixtures, no account/Auth changes.`);
} finally {await c.close();}
