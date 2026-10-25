# GMAT35 — group-wide additional materials review

Status: exact candidate deployed to centerly-dev after explicit owner approval on 25 October 2026. All 35 history bodies/catalog and unchanged business fingerprints verified. Hosted financial mutation acceptance remains pending separate approval. See GMAT35_DEPLOYMENT.json.
Canonical baseline: Teacher main 76975a7fca04b2e57b90597982144bcd9f257fe7, 34 migrations through 202610240002_direct_attendance. Original Teacher checkout is untouched by this package. Work lives in the detached canonical review worktree.

Candidate: supabase/proposals/202610250001_group_materials.sql
SHA256: 94813e07c1f600da7f1011a6bcfe27d6347f71492a815d2ef9096eae15cbff07
Promoted unchanged to supabase/migrations/202610250001_group_materials.sql after approval; both manifests advanced after successful postflight.

## Behavior and contracts

- secretary_group_materials_preview(uuid) returns the full active, nonarchived student roster of an active tenant group, with IDs and names. No page-size truncation.
- secretary_add_group_materials(uuid,uuid,text,numeric,date,uuid[]) accepts group, stable request ID, materials title, exact per-student EGP price, due date and reviewed student IDs. It compares the current roster to the preview and rejects stale membership. Empty/duplicate rosters and invalid prices/titles are rejected.
- A single server transaction creates one invoice for each current student through existing create_invoice. Failure rolls back every invoice and its audit records. Group/enrollment/student row locks stabilize admission/lifecycle changes; serialization/deadlock errors are safe failed transactions and the same request can be retried.
- Tenant-scoped advisory request locks and immutable audit request/result replay prevent duplicate invoices from concurrent same-key submissions or lost responses. Reusing the key with changed arguments fails. A successful replay returns the original result even after roster changes.
- Existing payment/partial payment/reversal, exact balances, attribution and Teacher reads apply. Existing bills are not modified. Later new materials require a new explicit request; future joiners are not automatically billed for previously issued group materials.
- Both APIs require an active subscribed secretary via private.require_actor; anonymous execution is revoked and Teacher operations remain denied. No RLS relaxation or existing function replacement.

## Evidence

- node supabase/tests/group_materials.mjs: PASS, 29 native disposable PostgreSQL checks, including two simultaneous same-request clients, stale/empty/duplicate roster denial, validation, Teacher/foreign tenant/inactive identity/subscription denial, atomic injected-failure rollback, partial payment, overpayment, payment retry and reversal.
- node supabase/tests/run.mjs with candidate applied: PASS, 90 existing authorization/business assertions.
- Secretary component tests cover review before write, same-request reconciliation after network failure and safe unavailable API state.
- Desktop 1440px and mobile 390px Chromium: group-details action, review total, confirmation and returned success exercised with only the TWO new APIs simulated and all other business writes blocked. This is NOT hosted end-to-end acceptance.
- Before deployment, hosted GET-only availability probe returned PGRST202. After deployment, six real GET-only checks passed; connected browser preview forms worked at desktop/mobile widths. No hosted financial/fixture/Auth mutations or publication performed.

## Approval boundary

Request approval to deploy ONLY the exact candidate above to centerly-dev (yfeubomyglmhuwizaqoj), after checking all 34 current migration bodies/catalog and a dry run containing only 202610250001. Stop on drift. Postflight must check migration 35, both function signatures/grants and unchanged Teacher access. Deployment authorization does not authorize hosted fixture or financial writes, Auth changes, production or publishing.

Separate proposed synthetic acceptance scope (NOT authorized): in tenant A, create one uniquely prefixed GMAT35 group and three synthetic students; enroll two, leave the third unenrolled. Preview and issue 12.50 EGP materials to the two active students (25.00 total); retry same request, collect 5.25 on one invoice, reverse that collection and reconcile balances/history and Teacher reads. Change roster by withdrawing one and enrolling the third; reject the stale roster before charging, then explicitly approve a new 2.00 set for the current two. Use tenant B and Teacher A only for denial/read checks. Cleanup preserves history: reverse outstanding synthetic collections, void unpaid synthetic invoices through trusted authorized local/test cleanup scope, withdraw synthetic memberships, archive synthetic students/group; retain immutable audit/payment/reversal records. No real records or account/password changes. Before execution, inventory exact created IDs and verify the approved cleanup API/process exists; do not perform raw hosted cleanup ad hoc. Owner approval of this scope is separate from migration approval.
