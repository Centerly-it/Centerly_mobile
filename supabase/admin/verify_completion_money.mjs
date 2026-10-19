import {randomUUID} from 'node:crypto';
import {querySql} from './trusted_cli.mjs';
import {parseCapture,findField} from './read_capture.mjs';
export async function verifyCompletionMoney(c,eq) {
 const {rpc,request,teacher,secretary,student,date}=c;
 const invoice=await rpc(secretary,'create_invoice',{p_student_id:student,p_amount:10.01,p_due_on:date,p_invoice_number:`MVP-${randomUUID()}`});
 eq(invoice.ok,true);
 const key=randomUUID(), body={p_invoice_id:invoice.data,p_amount:4.01,p_method:'cash',p_idempotency_key:key};
 const paid=await Promise.all([rpc(secretary,'record_payment',body),rpc(secretary,'record_payment',body)]);
 eq(paid.every(r=>r.ok),true);eq(paid[0].data,paid[1].data);
 const eventCount=async id=>{const r=await request(teacher,`/rest/v1/notifications?select=id&payload->>payment_id=eq.${id}`);eq(r.ok,true);return r.data.length;};
 eq(await eventCount(paid[0].data),1);
 const reverse=()=>rpc(secretary,'reverse_payment',{p_payment_id:paid[0].data,p_reason:'MVP synthetic reversal'});
 const reversed=await Promise.all([reverse(),reverse()]);eq(reversed.every(r=>r.ok),true);eq(reversed[0].data,reversed[1].data);
 eq(await eventCount(reversed[0].data),1);
 const conflict=await rpc(secretary,'record_payment',{...body,p_amount:1});eq(conflict.data.message,'CONFLICT');
 const ledger=await request(teacher,`/rest/v1/payments?invoice_id=eq.${invoice.data}&select=id,amount_egp,reversal_of`);
 eq(ledger.data.length,2);
 const finance=await request(teacher,`/rest/v1/invoices?id=eq.${invoice.data}&select=status`);eq(finance.data[0].status,'due');
 const rollbackKey=randomUUID();
 const before=await request(teacher,'/rest/v1/notifications?select=id');eq(before.ok,true);
 // All inputs are generated or validated UUIDs; no arbitrary customer SQL/values.
 for(const id of [invoice.data,secretary.id,rollbackKey]) if(!/^[0-9a-f-]{36}$/i.test(id)) throw new Error('Invalid synthetic UUID');
 const result=parseCapture(await querySql(`begin;
 set local role authenticated;select set_config('request.jwt.claim.sub','${secretary.id}',true);
 select public.record_payment('${invoice.data}',1.01,'cash','${rollbackKey}');reset role;
 do $$ begin
 if (select count(*) from public.payments where idempotency_key='${rollbackKey}')<>1
 or (select count(*) from public.notifications where payload->>'payment_id' in
 (select id::text from public.payments where idempotency_key='${rollbackKey}'))<>1
 then raise exception 'TRANSACTION_VISIBILITY_FAILURE'; end if; end $$;
 rollback;
 select jsonb_build_object('payments',(select count(*) from public.payments where idempotency_key='${rollbackKey}'),
 'events',(select count(*) from public.notifications where teacher_id='${teacher.id}' and recipient_id='${teacher.id}'),
 'invoice_status',(select status from public.invoices where id='${invoice.data}')) as transaction_rollback;`,{output:'json'}));
 eq(findField(result,'transaction_rollback'),{payments:0,events:before.data.length,invoice_status:'due'});
 c.invoice=invoice.data;
}
