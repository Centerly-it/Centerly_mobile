# Current shared backend contract

Updated 2026-10-28. Current source and manifests are authoritative; old checkpoints are historical.

## Ownership and versions

Teacher repository owns all SQL in `supabase/migrations`. The two environments have the same contract but independent data: dev `yfeubomyglmhuwizaqoj`, prod `ohhwccwwwxfmwpfypfyf`. Current pin: **40 migrations through 202610280001_group_billing_modes.sql**. Secretary mirrors dev/prod baseline JSONs and an available Teacher commit. Preserve every deployed migration/hash and old immutable proposal bytes; even old NOT DEPLOYED comments may be historically stale.

## Access

Auth UID + database identity derive teacher tenant, role, active status and subscription. Teacher owns scoped historical reads and approved teacher mutations; secretary owns authorized operational writes. Anonymous/inactive/foreign-tenant/wrong-role requests must fail at DB/RPC/RLS, not only UI. Composite tenant foreign keys, privileges, policies, triggers and locks are part of the contract. Neither JWT metadata nor UI role parameters grant permissions. Profiles/seats/subscriptions are trusted-admin controlled.

Deactivation immediately blocks a secretary without deleting Auth/history, atomically handles pending removal/audit. Reactivation checks owning active subscribed teacher and seat availability under locks; duplicate calls are idempotent. Subscription suspension is manual teacher profile subscription_status; it blocks the teacher and linked staff. See [subscription administration](SUBSCRIPTION_ADMIN.md).

## Student/session/history rules

Active student enrollment requires an owned group. Mandatory multi-day recurring schedules coexist with explicit dated manual sessions. Included vs extra session charge is explicit. Session end state follows end timestamp; cancelled is distinct. Attendance is direct; no finalization UI or unmarked-to-absent job. Teacher can read archived attendance/academics/notes/finance, with archived notes read-only and operational edits restricted. Explicit audited historic finance settlement/reversal remains available only where the API permits it. Archive/delete/cancel never erase financial/attendance/audit history.

## Finance and migration 40

Monthly anniversary billing + one-time materials remain idempotent. New groups can choose monthly or per-session; existing modes are not converted. Per-session tariffs/session prices snapshot; explicit financial attendance review differs from attendance approval. Present amounts remain, eligible unpaid absent/unmarked charges are exempt, received cash is retained with settlement flagged. No automatic wallet/refund or fake cash-refund assertion. See [billing release](BILLING_MODES_RELEASE.md) for exact deployed behavior/acceptance limits.

Exact decimal strings/cents are mandatory. Original invoice amount, signed receipt/reversal ledger net and payable balance are separate aliases; void payable is zero without erasing original values/history. Visible money edits invoke audited RPCs; immutable payment/reversal/audit/attendance logs must not be updated/deleted. Stable request IDs reconcile uncertain writes; retries must not duplicate charges or receipts.

## Read/reconciliation behavior

Keep strict role/ownership/response validation, bounded server pages/cursors and query-scope summaries. Cairo timezone governs date windows and display. Cache/coalescing is bounded and identity/token/backend scoped; invalidate on account/access changes. Do not clear verified content for transient background failures. Ambiguous writes reconcile rather than auto-repeat.

## Safe change protocol

For an authorized backend change: verify current host/ref and all baseline bodies/catalog, test the new additive version locally, inspect pre-write data/financial fingerprints as appropriate, require a dry run listing only the new migration, stop on drift, deploy transactionally, verify history/function bodies/grants/policies/triggers and unchanged histories/totals, then update both manifests/contracts and Secretary canonical source pin. Reconcile partial runs; never blindly retry migration/fixture mutations. Run native PG modules serially.

Old reset/provision/deploy/SEC27 scripts are historical, not onboarding. New hosted synthetic writes need a bounded scope; no production fixture copy, Auth reset or customer-data cleanup is implied. [Full handoff](../CODEX_HANDOFF.md) and [operations/recovery](OPERATIONS_AND_RECOVERY.md) define current ownership and remaining acceptance. A source/unit/SQL test pass is not hosted/device acceptance.
