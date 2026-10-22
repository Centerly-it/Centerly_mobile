# Deployment status — approved and verified on 2026-10-22

The exact reviewed file below is now deployed to centerly-dev as migration26.
SHA256 unchanged. All26 bodies/catalog and read-only pagination/filter/tenant/role
checks passed before manifest pinning and client activation. No account or data
mutations, build or restart occurred. Evidence:
[FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md](FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md).

The original pre-approval review below is retained verbatim as historical context;
its LOCAL ONLY/default-off statements no longer describe current activation.

# One additive read contract for receipt filters — local review, 2026-10-22

Approval requested only for the exact file below on development project
centerly-dev (`yfeubomyglmhuwizaqoj`). Nothing in this review authorizes an account
change, money write, data repair, seed, baseline replay or production deployment.

| Local proposal | SHA256 (LF bytes) |
|---|---|
| `supabase/proposals/teacher_owner_testing/202610220001_finance_movements.sql` | `e59af624e58ddb7875fc59c6f02278806fcdb8eb8c93ec8b0765a17848e2eedf` |

Need: deployed get_teacher_finance supports receipt dates/student/group/collector,
but lacks receipt search/method/collection-versus-correction filters. Applying the
preview's local filters to one fetched page would give wrong rows/counts/net totals.
The new function filters the full scoped dataset before limit+1 UUID pagination and
returns full filtered count, gross, corrections and net as exact decimal strings.

`list_teacher_finance_movements(p_from date,p_to date,p_search text='',p_method
text=null,p_kind text=null,p_secretary_id uuid=null,p_student_id uuid=null,
p_group_id uuid=null,p_cursor uuid=null,p_limit integer=30) -> jsonb`.

- Active teacher/subscription resolved by private.require_actor('teacher').
  Secretary, anonymous and other-tenant identifiers remain denied.
- Existing private window validator: inclusive Cairo civil dates, <=366 days,
  limit1..100. Search <=100 characters; literal substring of student name, invoice
  number or receipt UUID text. No dynamic SQL or LIKE wildcard interpretation.
- Method cash/transfer/other; kind collections/corrections; null means all.
  Optional collector, student and group checked in the same tenant.
- Header summary covers every matching row, independent of cursor. Collections
  and reversals retain positive stored amount and signed reporting amount. Negative
  net is valid. Original and correcting collector attribution remains distinct.
- SECURITY DEFINER with empty search_path, schema-qualified relations, public/anon
  execute revoked; authenticated execute granted with teacher-only actor guard.
  No table/grant/RLS/index/history changes, new triggers, notifications or writes.
- Flutter implementation and tests are prepared behind default-false
  CENTERLY_FINANCE_MOVEMENT_FILTERS. It is not enabled by a historical approval.

Validation: `node supabase/tests/finance_movements.mjs` — 29 assertions PASS on a
disposable local database built from all 25 immutable managed migrations. Covers
full totals across pages, exact cents, corrections/negative net, original/current
actors, method/kind/search (including literal percent), empty reports, tenant/role/
anonymous denial, foreign identifiers, malformed filters and retained invoice
history. Flutter new-endpoint adapter test passes with the flag explicitly true.
No hosted call to this new function has been made; it is not deployed.

Fresh baseline: exact 25 remote migration bodies plus 44 functions,18 tables,
30 policies and grants/RLS/indexes/triggers/constraints matched local baseline.
Enrollment violations0. Existing managed migration hashes unchanged; zero pending
versions in the managed directory. Read-only CLI captures and verification logs
are under ignored build/owner-testing/. No old migration should be redeployed.

After explicit approval: recheck project/history/catalog and proposal hash, copy
only this exact proposal into managed migrations, require a dry run listing only
202610220001, apply once, compare exact body/grants and test authenticated reads,
then pin the new manifest version and enable the Flutter flag for a final build.
If deployed state has drifted, stop for a concrete revised review. Transfer the
same history to Secretary later; do not create a second schema or replay versions.
