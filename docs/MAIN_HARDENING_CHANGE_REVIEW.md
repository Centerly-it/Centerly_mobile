# Main hardening deployment review — 2026-10-20

> Deployment update — 2026-10-20: owner approved this exact six-file package;
> deployed to centerly-dev through202610200006 and freshly verified (25 bodies,
> catalog/grants/RLS,135 hosted business assertions +1 real Flutter SDK test).
> No production or account/Auth configuration change. Read the historical review
> below as the approved scope; its earlier LOCAL ONLY labels describe pre-approval
> status. Current evidence/limitations: HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md.


LOCAL PROPOSALS ONLY. This is not deployment authorization. Prior approval for
202610190004–010 does not cover these six new/revised files. No hosted database,
account, Auth setting, migration history or customer data was read or changed by
this audit. Existing nineteen managed migration bodies pass their pinned manifest.

## Exact files (SHA256 of LF bytes)

| File | SHA256 |
|---|---|
| `supabase/proposals/finance_business/202610200001_finance_overview.sql` | `a678fa4f06d43b8dc28439d5a0723bcc05c2b508906481c3aa70447dcec19206` |
| `supabase/proposals/finance_business/202610200002_invoice_detail.sql` | `dfc4e1ab01a986b818caa366976ee163406997424348f8a9999d1a987d8219df` |
| `supabase/proposals/finance_business/202610200003_finance_dues.sql` | `47f0467802e6a10f67c7ea7d2943d5e450acac6bec1bf626a26a652cfd17ae60` |
| `supabase/proposals/logic_hardening/202610200004_preserve_void_invoices.sql` | `6ceb7a1b9c3fc331cf186a2e95783a742626a3357deaae2bbbd1fa2126717b20` |
| `supabase/proposals/logic_hardening/202610200005_enrollment_timeline.sql` | `6cb0278715d11f4278130616a633ccc9e88b351a3a09b7d68c0eb6166507839b` |
| `supabase/proposals/logic_hardening/202610200006_ongoing_attendance.sql` | `133967844480b543e3ba6611ea334825d5289652a242d5ba203fca268792333b` |

## Effects

- 001: teacher-only aggregate finance RPC and one covering payments index on
  (invoice_id,id) INCLUDE (teacher_id,amount_egp,reversal_of). The index shape
  changed during this audit; its revised hash requires new approval.
- 002: teacher-only invoice detail with attributed, signed, paginated receipt and
  full-reversal history. 003: teacher-only filtered/paginated invoice dues.
  All require live teacher role/tenant; authenticated Secretary calls rejected.
  Invoice due cohort and cash receipt period remain distinct. No teacher writes.
- 004: replace private.reconcile_invoice so receipt reversal preserves void
  invoices; same signed sum, idempotency, locking and notification producers.
  No direct client EXECUTE privilege on the helper.
- 005: NOT VALID enrollment timeline CHECK for future writes/updates. Active
  means left_at NULL; inactive means left_at >= joined_at and not NULL. No inferred
  exit date/backfill. Future Secretary must set status and exit timestamp together.
  Existing invalid rows remain; any later update requires a valid timeline.
- 006: replace get_teacher_overview's attendance aggregate with non-cancelled
  ongoing sessions using starts_at <= statement_timestamp() < ends_at, independent
  of selected p_date. Timestamp/scope fields identify the new semantics. Overnight
  sessions are retained without a local_date filter. Unmarked never becomes absent.
  Counts are per student-session mark; overlapping sessions can count a student
  twice and do not establish physical occupancy. Other dashboard fields unchanged.

No new account/Auth operation, tables, data backfill, financial row rewrite,
notification producer, tenant grant, or deletion. Functions use qualified names,
empty search_path and explicit role guard; tenant joins preserve isolation.

## Validation and deployment conditions

Fresh disposable PostgreSQL: existing 19-version foundation plus all baseline,
concurrency, detail, profile, completion, integrity and finance suites PASS
(343 assertions); hardening suite PASS (30 assertions), including exact hashes,
boundary/cancellation/date/role tests, void/reversal retry, one notification,
private helper privacy and enrollment timeline constraints. No hosted tests run.
See MAIN_LOGIC_PERFORMANCE_AUDIT.md for Flutter results and measured local plans.

Before deployment: obtain explicit approval of all six exact bytes; safely verify
linked centerly-dev identity and actual nineteen-version remote bodies/grants;
read-only count existing enrollment timeline violations and inspect index/name/RPC
conflicts. Stop on drift, extra pending migrations, SQL/hash mismatch or unexpected
objects. Copy approved bytes into managed migrations only after approval; dry run
must list exactly 202610200001..006. New ordinary index creation takes a write lock;
review table size and maintenance window first. CHECK creation also takes a brief
lock; NOT VALID avoids scanning/repairing historical rows. Do not silently switch
to concurrent index DDL or change SQL under the same approval.

Postflight: verify 25 bodies, grants, index definition, NOT VALID constraint and
unchanged RLS; run Auth/SDK tenant/role/receipt/idempotency/notification/cancellation
cases only against previously approved synthetic fixtures. Verify current-session
counts across start/end/cancelled boundaries and refresh with a different selected
day. No data repair or fixture expansion is implicitly approved. Validation of
existing enrollment rows requires owner-reviewed correction if violations exist.
Only then integrate/activate finance adapters. Overview scope detection is fail-
closed for semantics: old server counts are not shown as current attendance.

Rollback: record migration failure/transaction outcome; do not delete migration
history, money records or audit logs. Prefer a separately reviewed forward repair.
Secretary migration ownership transfers with the same history, never replays it.

006 also adds teacher_current_sessions(teacher_id,ends_at,starts_at) INCLUDE(id)
WHERE status<>'cancelled' so current reads can discard ended history via index.
This is an ordinary index build, subject to the same reviewed maintenance window.
