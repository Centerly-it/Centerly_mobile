# Development hardening deployment verification — 2026-10-20

Owner explicitly approved deployment in this chat: «اعتبرني موافق و انشر».
Target verified through authenticated CLI: centerly-dev, yfeubomyglmhuwizaqoj,
ACTIVE_HEALTHY, already linked. Approval covers the exact six SQL files pinned in
MAIN_HARDENING_CHANGE_REVIEW.md; no production deployment or publishing performed.

## Preflight and application

- Six proposal SHA256 values matched reviewed bytes; copied byte-for-byte into
  supabase/migrations without editing any of the original nineteen files.
- Fresh remote history: exactly19 versions/bodies/names matched. Compared remote
  live function bodies/grants, tables/RLS, policies, constraints, indexes and
  triggers against a disposable local database built from the same19 migrations.
  41 application functions,18 tables,30 policies; no catalog drift detected.
- Existing invalid enrollment timelines:0. No repair/backfill necessary or done.
- Relation sizes preflight: payments147,456 bytes, sessions98,304 bytes,
  group_enrollments65,536 bytes; reviewed ordinary-index lock acceptable for this
  small development dataset. No live capacity/production-load claim.
- Dry run listed exactly202610200001..006 and no other versions; all six hashes
  rechecked immediately before application. CLI applied all six successfully.
- Fresh postflight: all25 remote migration bodies/names matched; live catalog
  matched disposable local25-version schema. 44 application functions,18 tables,
  30 policies; all grants, RLS, function definitions, both new covering indexes,
  unchanged triggers and NOT VALID timeline constraint verified. Invalid rows0.
  NOT VALID remains as approved; no additional VALIDATE/DDL was introduced.
- Updated schema-manifest.json to pin25 versions through202610200006. New managed
  SQL files retain LF bytes; old19 remain unchanged.

## Real hosted tests

- Flutter Supabase SDK:1 PASS covering teacher login, restore, logout and Secretary
  denial using existing ignored development credentials. No password/Auth-setting
  changes, provisioning, admin account-status changes or leaked keys.
- Existing completion regression:98 assertions PASS, synthetic fixtures only.
  Covers seven reads, tenant/anonymous denial, payment/reversal retries, exactly-once
  payment/removal notifications, rollback, null-vs-zero academics, attendance
  finalization/correction, note concurrency, removal handling without deactivation,
  read-notification idempotency and cancellation races.
- New hardening regression:37 assertions PASS. Covers three new finance reads,
  Secretary/anonymous/cross-tenant denial, concurrent payment/reversal retry,
  preservation of a trusted-admin-voided synthetic invoice, two append-only ledger
  rows/net zero and one notification per event; invalid inactive enrollment rejected.
- Ongoing attendance checked in one server-timestamp transaction: inclusive start,
  exclusive end, future/cancelled exclusion, prior-local-date session inclusion,
  independence from selected2030 date, unmarked separate from absence. These
  temporary session/attendance writes were rolled back, then absence verified.
- Retained only approved synthetic finance/academic/session/removal regression
  artifacts and audit/notification history; no real customer data touched. No new
  permission inferred to repair historical data or modify accounts.

## Repository validation and activation limits

Existing audit Flutter240 PASS/1 opt-in SKIP and explicit preview3 PASS are from
immediately preceding code audit; the opt-in SDK test was actually run here and
passed. New deployment changes do not replace those historical full-suite records.
Post-deployment local full25-version foundation/concurrency/detail/profile/
completion/integrity regressions plus baseline-to-proposal finance/hardening
transition tests are recorded in build/hardening-local-*.log. Old transition tests
use an explicit19-version local cutoff to reproduce defects, avoiding double
application; main baseline/regression suites build all25 managed migrations.

Backend scope/timestamp now allows the existing live dashboard to show ongoing
attendance after refresh; «لم يُسجّل» remains separate. No app restart/APK made.
New finance contracts are available and verified, but redesigned finance screens
still use the debug preview adapter. No claim that preview screens are now wired
or that the app is production/pilot ready. Next implementation is production
finance repository/adapters and contract reconciliation, then physical-device and
Secretary cross-app acceptance. No commit or push requested/performed here.

Evidence (ignored local captures, no tokens/passwords):
build/hardening-preflight.json, hardening-postflight.json, hardening-dry-run.log,
hardening-deploy.log, hardening-hosted-result.json, hardening-sdk-auth.log,
hardening-hosted-regression.log; regression result also in
.buildlog/completion_hosted_result.json. SQL review retains exact six hashes.
