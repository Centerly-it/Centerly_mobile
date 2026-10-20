# Logic hardening — LOCAL ONLY, not deployed/approved

> Deployment update — 2026-10-20: owner approved this exact six-file package;
> deployed to centerly-dev through202610200006 and freshly verified (25 bodies,
> catalog/grants/RLS,135 hosted business assertions +1 real Flutter SDK test).
> No production or account/Auth configuration change. Read the historical review
> below as the approved scope; its earlier LOCAL ONLY labels describe pre-approval
> status. Current evidence/limitations: HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md.


The following new proposals require explicit reviewed approval before hosted use.
Existing nineteen managed migrations are unchanged. No account/Auth change,
backfill, invoice deletion, receipt rewrite or attendance conversion is proposed.

| File in supabase/proposals/logic_hardening | SHA256 |
|---|---|
| `202610200004_preserve_void_invoices.sql` | `6ceb7a1b9c3fc331cf186a2e95783a742626a3357deaae2bbbd1fa2126717b20` |
| `202610200006_ongoing_attendance.sql` | `133967844480b543e3ba6611ea334825d5289652a242d5ba203fca268792333b` |
| `202610200005_enrollment_timeline.sql` | `6cb0278715d11f4278130616a633ccc9e88b351a3a09b7d68c0eb6166507839b` |

004 replaces only private.reconcile_invoice: a trusted void invoice remains void
when a receipt is fully reversed. Existing exact signed sums, public RPC locks,
idempotency and notification producers remain intact. The private helper retains
no client execution grants. Local reproduction showed the old function changed a
void invoice to due; the proposed replacement preserves void and append-only rows.

005 adds NOT VALID enrollment_status_timeline: future active memberships require
left_at=null; future inactive memberships require a non-null left_at>=joined_at.
Without this, a direct inactive update can retain left_at=null and schedule
provisioning can incorrectly carry that student into future attendance rosters.
Future Secretary clients must update status/left_at atomically. Existing invalid
rows are not changed; a hosted read-only violation count and owner-reviewed
historical correction are required before validation/production acceptance. An
unrelated update to an invalid existing row will fail until corrected. No date is
inferred and no automatic cleanup is authorized by this proposal. DDL takes a
brief table lock; no table scan/backfill at NOT VALID creation.

Local disposable PostgreSQL: old defects reproduced and 30 assertions passed for
void preservation, full-reversal idempotency/exactly-once notification, unchanged
financial totals, roles/tenant privacy, inaccessible private helper, rejected
malformed future timelines and explicit validation after synthetic repair.
Three exact SQL hashes are verified before starting the test database.
No fresh hosted state was read or mutated. See MAIN_HARDENING_CHANGE_REVIEW.md
for the combined six-file deployment scope and preflight/postflight requirements.

006 changes only overview attendance_counts to marks on non-cancelled sessions
whose starts_at<=statement_timestamp()<ends_at, independent of p_date. Existing
selected-day session and finance fields are preserved. Explicit scope and server
sync timestamp distinguish deployed semantics. No date predicate drops overnight
sessions; overlaps count student-session records, never physical unique occupancy.
Unmarked remains separate from absence. No writes, new grants or notifications.

006 also adds teacher_current_sessions(teacher_id,ends_at,starts_at) INCLUDE(id)
WHERE status<>'cancelled' so current reads can discard ended history via index.
This is an ordinary index build, subject to the same reviewed maintenance window.
