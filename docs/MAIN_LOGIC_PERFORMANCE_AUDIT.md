# Main logic, calculation and performance audit — 2026-10-20

> Subsequent owner-approved deployment on2026-10-20: exact six SQL proposals
> applied and verified on centerly-dev (25 versions,135 hosted business checks,
> 1 Flutter SDK test). See HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md.
> Audit findings below retain their pre-deployment timing; remaining client
> adapters/device/pilot gates still apply.


## Scope and actual readiness

Audited local main starting at 0577486, with an initially clean tree. Reviewed
production and debug-preview data paths, Auth/session races, cached API reads,
pagination, dashboard cohorts, financial ledger/reversals, attendance semantics,
calendar fixture allocation, images/startup, SQL isolation/grants and CI. Changes
remain local and uncommitted. No push, hosted inspection/deployment/Auth change,
APK creation, device restart or Hot Restart was performed. Existing nineteen
managed migration files and pubspec.lock remain unchanged. No new dependency.

This is hardening, not a production certification. New Figma designs/finance
ledger remain debug-only preview, while release uses existing Live pages. Passing
mock/UI/SQL tests does not establish cross-screen hosted reconciliation. Current
work is suitable for continued UI testing; full production activation remains open.

## Findings and fixes

1. Cache/session safety: a bounded memory-only LRU stores independent JSON copies,
   at most 64 entries, 2 MiB encoded UTF-8 payload total and 256 KiB per entry.
   These are payload limits, not total Dart heap limits. Groups/students TTL30s;
   profile/academics TTL15s. Finance, overview/calendar/attendance, notes,
   notifications and secretaries have no stored TTL; every read revalidates.
   Project/auth-user/token boundaries clear data. Generation guards reject late
   responses after invalidation/logout/token changes. Concurrent identical reads
   share one active RPC but return independent decoded values; parameter snapshots
   cannot mutate cache keys/results. Pending map retains at most64 futures (not a
   global network-concurrency limit). Refresh bypasses stored TTL but may join the
   same active read; writes invalidate and never automatically retry. Clock rollback,
   payload eviction, stale flights, failures, identity rotation and project isolation
   are tested. Cached directory/profile permission revocation can remain visible
   until short TTL/refresh; sensitive reads and writes always hit server guards.
2. Auth: old restore/login completion cannot release the busy state of a newer
   logout. Fresh profile results require matching account/token/operation. One
   same-user token-rotation retry avoids false logout on normal SDK refresh;
   repeated rotation or actual logout fails closed. Legacy logs no longer print
   raw backend bodies/errors. Session persistence remains SDK/secure storage,
   never stored plaintext passwords. Protected routing remains blocked while
   verification is pending; remote profile restore now follows first frame instead
   of blocking the branded UI before runApp. No physical startup timing measured.
3. Finance: complete immutable snapshots build a single O(invoices+movements)
   index, replacing repeated per-invoice full scans. BigInt minor units preserve
   exact arithmetic. Duplicate/missing references, partial/double/cross-invoice
   reversal, wrong method and impossible net balance reject. Live summary/record
   parsing validates invoice reconciliation, exact decimal amounts, signed receipts,
   unique civil daily dates and daily cash sum. Negative period net is legal after
   earlier-period reversals; cash period is independent of due-cohort settlement.
   Complete-ledger validation is NOT suitable for a single remote pagination page.
   Invoice/movement detail uses indexed references. Preview daily rows corrected.
4. Dashboard: calendar/names and monthly finance branch load independently in
   parallel, guarded as one session. Receipt-period cash never substitutes for
   settlement of the month's due invoices. User clarified current attendance means
   ONGOING SESSION marks, independent of selected date, not physical occupancy.
   New local SQL006 uses server statement time, inclusive start/exclusive end,
   excludes cancelled/future/ended sessions and retains overnight sessions. Pending
   stays separate from absence; AR label now «لم يُسجّل». Explicit scope/timestamp
   allows live UI to withhold old all-day totals until this contract is deployed.
   Snapshot shows update time and refreshes on load/date change/pull-to-refresh;
   no realtime subscription or continuous physical check-in/out claim. Overlapping
   sessions count student-session records, not deduplicated physical people.
5. Pagination: strict ordered, bounded, advancing IDs reject broken cursor pages
   instead of repeating loops or losing rows. Group/student synthetic fixtures now
   match the server lexical UUID ordering. Late-search guards retained.
6. Calendar/image cost: calendar marker scans no longer materialize full synthetic
   rosters for every cell; visited-day cancellation edits remain consistent. Avatar
   dimensions are checked before decode (24M-pixel ceiling), saved normalized PNG
   at max512 edge, metadata removed, decode/display bounded; resources disposed.
   Existing invalid-image/identity persistence behavior remains tested.
7. Local SQL defects reproduced: original reversal helper resurrected a void
   invoice as due; proposed004 preserves void without changing append-only receipt
   retry/exactly-once notifications. Enrollment inactive/left_at=NULL could leak
   into future provisioned rosters; proposed005 checks future timelines atomically.
   Historical invalid rows are not silently guessed/repaired. Finance001 index
   now serves tenant-validated private per-invoice sums as well as teacher reads.
   See the exact six-file MAIN_HARDENING_CHANGE_REVIEW.md. NOT APPROVED/DEPLOYED.

## Fresh validation

- Full Flutter: 240 PASS, one hosted opt-in SKIP. Initial full run found one test
  fixture's unsorted numeric IDs; corrected fixture to server ordering and full
  suite rerun passed. No weakened validator or ignored failing assertion.
- Explicit CENTERLY_UI_PREVIEW transport/navigation: 3 PASS. Cache/auth race,
  finance reference arithmetic/malformed snapshot, summary boundaries, keyset,
  avatar/calendar and dashboard parallelism coverage is included in full suite.
- Flutter analyzer: no issues. Repository Dart format: 449 files, zero changes.
  Enforced offline lockfile PASS; lockfile unchanged. build_runner PASS (9 outputs,
  same generated business sources); intentional localization regeneration only.
  git diff --check PASS. Localization final spot checks recorded separately.
- Disposable local PostgreSQL: baseline90 + concurrency11 + detail33 + profile21
  + completion98 + integrity22 + finance68 =343 assertions PASS. Hardening30 PASS,
  total373. Exact proposal byte guards PASS; nineteen manifest hashes unchanged,
  zero new managed versions. Windows PostgreSQL launcher tests2 PASS.
- Local load benchmark: 1,000 invoices/20,000 receipts, exact total20,200.00 EGP.
  EXPLAIN/ANALYZE verifies covering index-only plans. Initial median for 1,000
  repeated private invoice aggregates fell from2411.789ms to13.442ms; teacher read
  14.545ms vs15.735ms (no demonstrated teacher-read speedup in that run). Repeated
  under concurrent local test load:5570.643ms vs17.222ms, teacher32.647 vs22.081ms.
  These are local aggregate workloads, NOT latency of one payment RPC or hosted
  concurrency capacity. Index-only heap behavior depends on vacuum/visibility.
- Dart JIT benchmark same scale: naive233,565us vs indexed construction+sum42,915us
  median of3, matching exact97,980,000 minor-unit outstanding checksum. About5.4x
  in this workload, NOT whole-app/device acceleration. No timing thresholds in CI.

Reproduction: flutter test --no-pub; explicit preview test command from CI;
node supabase/tests/logic_hardening.mjs; node supabase/tests/finance_business.mjs;
node supabase/tests/finance_performance.mjs; dart run benchmark/finance_snapshot_benchmark.dart.
PostgreSQL suites share local port55439 and must run sequentially. Log artifacts
under ignored build/audit-*.log and build/backend_finance_benchmark.json.

## Remaining work and exact eligible order

1. Review/approve exact six-file SQL package; read-only hosted baseline/index and
   enrollment-data preflight, exact dry-run, then approved deployment and synthetic
   authenticated postflight. No old migration approval covers revised proposal001
   or new004..006. Preserve shared migration ownership/history for Secretary.
2. Connect debug designs to production repositories, particularly new invoice/
   dues/detail/attribution/receipt filters. Do not build a full client ledger from
   partial server pages. Require hosted tenant/permission/sum reconciliation.
3. Live teacher display name is still generic; group notes are in-memory only
   pending a defined persistence contract; contacts/QR remain preview. Separate
   student/group/session samples do not prove whole-tenant business consistency.
   Schedule revision semantics and Secretary atomic enrollment changes need
   cross-app acceptance. Do not infer or rewrite past attendance.
4. Device Android lifecycle/rotation, startup/frame/memory/network measurements,
   secure storage/revocation/offline recovery, cancellation during refresh, slow
   networks, financial volumes and Secretary two-client updates remain pilot gates.
   No fresh device/APK/hosted-security acceptance was run here. Historical hosted
   records remain historical. Keep production activation and pilot acceptance
   separate from visual preview completion.
