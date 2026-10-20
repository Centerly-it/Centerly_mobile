# Finance business read-model — LOCAL ONLY, 2026-10-20

> Deployment update — 2026-10-20: owner approved this exact six-file package;
> deployed to centerly-dev through202610200006 and freshly verified (25 bodies,
> catalog/grants/RLS,135 hosted business assertions +1 real Flutter SDK test).
> No production or account/Auth configuration change. Read the historical review
> below as the approved scope; its earlier LOCAL ONLY labels describe pre-approval
> status. Current evidence/limitations: HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md.


Not approved for deployment, not copied to managed migrations, not linked or pushed
by this task. Existing nineteen migration bodies are untouched. This review does
not imply a fresh hosted baseline/hash verification. Future deployment requires
owner approval of these exact bytes, remote baseline inspection, an exact dry run
and authenticated postflight before any live Flutter activation.

| File under `supabase/proposals/finance_business/` | SHA256 |
|---|---|
| `202610200001_finance_overview.sql` | `a678fa4f06d43b8dc28439d5a0723bcc05c2b508906481c3aa70447dcec19206` |
| `202610200002_invoice_detail.sql` | `dfc4e1ab01a986b818caa366976ee163406997424348f8a9999d1a987d8219df` |
| `202610200003_finance_dues.sql` | `47f0467802e6a10f67c7ea7d2943d5e450acac6bec1bf626a26a652cfd17ae60` |

Effects: three additive teacher-only, stable SECURITY DEFINER read RPCs and one
`public.payments(invoice_id,id) INCLUDE (teacher_id,amount_egp,reversal_of)` covering index. No tables, writes, backfill,
triggers, notifications, accounts, Auth settings or financial-write changes.

- `get_teacher_finance_overview(date,date)`: due-date invoice cohort and receipt-date
  collections, gross/corrections/net, overdue/due-today/future balances, actual
  recording actors (including inactive secretaries), methods and daily totals.
- `get_teacher_invoice_detail(uuid,uuid=null,integer=30)`: all-time invoice balance,
  creator attribution, bounded receipt history, original and correction references,
  original actor and amount. Archived student/group history remains readable.
- `list_teacher_finance_dues(date,date,text='all',text='',uuid=null,uuid=null,uuid=null,integer=30)`:
  status and literal name/invoice-number search before pagination. Full filtered
  count/amounts are independent of page size. Student/group filters reject another
  tenant; void invoices excluded. Partial and overdue filters intentionally overlap.

Every function resolves the active teacher/subscription through `require_actor`,
has empty search_path, explicit tenant joins, no caller-supplied tenant and no
PUBLIC/anon execution. Authenticated secretaries are denied by role checks.
Date windows <=366 inclusive days; pages 1..100; maximum search length 100.
UUID keyset cursors are stable; clients must not assume date-sorted pages. Invoice
balances include all recorded receipts; this is not a historical as-of ledger.
Overdue uses server Cairo today, including for a past selected reporting period.
Amounts are decimal strings; no floating point financial arithmetic.

Local validation: `node supabase/tests/finance_business.mjs` — 68 assertions PASS
on disposable PostgreSQL, with existing nineteen migrations applied first.
Covers cents, cohort/receipt differences, full reversal, different correcting
actor, negative actor net, Cairo midnight boundaries, keyset pages and full totals,
tenant/role/anon/inactive/subscription denial, historical attribution, archived
students, empty search, literal percent search, grants/search_path/index and no
notification side effects from reads. No hosted reads or writes were performed.

Remaining before integration: reviewed deployment/postflight, paginated live
adapters, server-side receipt method/kind/search filtering with full filtered totals
(the existing payment RPC only supports collector/student/group/date filters),
error/retry/session-guard regression, device acceptance and large-tenant query plans.
The debug preview filters a complete local snapshot; never port those filters onto
one partially loaded remote page. Teacher remains read-only for financial writes.
Migration ownership remains temporarily here; transfer the existing history to the
Secretary repository without replay or duplicate versions.


Pre-push hardening: finance_business.mjs now verifies all three exact review hashes
before starting PostgreSQL; CI runs this test explicitly. A scoped .gitattributes
rule keeps these pinned proposal bytes at LF on Windows/Linux. The above SQL
hashes and nineteen managed migration bodies remain unchanged.


Revision 2 — 2026-10-20 deep performance audit: the UNDEPLOYED 001 proposal index
now leads with invoice_id and covers tenant/amount/reversal. Private settlement
queries omit a tenant predicate after locking a tenant-validated globally unique
invoice, so the previous tenant-leading proposal did not help that lookup. The
new shape supports both read and settlement plans. Its hash above is revised;
no previous approval covers these new bytes. Review/approval and exact dry run are
still required before any hosted application. See MAIN_LOGIC_PERFORMANCE_AUDIT.md
for measured local results and limits. The other two SQL hashes are unchanged.
