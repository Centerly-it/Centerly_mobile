## Separate dev/prod environments — 27 October 2026

Owner-authorized creation of one new Free centerly-prod project (ohhwccwwwxfmwpfypfyf), retaining centerly-dev (yfeubomyglmhuwizaqoj) and all test records. Reconciled 3 missing canonical migrations from commit 6f86568; verified 37-version development catalog before copying the unchanged schema to a proven empty production project. Postflight: 85 functions, 18 tables, 30 policies, 30 triggers, matching grants/indexes/constraints. All 18 production tables and Auth users empty; development row fingerprints and financial totals unchanged. No paid resources, fixture replay, account creation, app restart/install/build or website publication.

Teacher VS Code modes dev/prod use ignored .env.dev.json/.env.prod.json; shared production configuration removed and cross-environment guards restored. Secretary mode files, public build guards and host-scoped sessions prepared. Config tests: 7 dev and 6 prod; 77 web tests; 90 isolated SQL-role checks; actual anonymous REST guards passed. Production authenticated/manual acceptance is unavailable until owner provisions real accounts. See docs/ENVIRONMENTS.md and docs/environment-acceptance.json; empty production/config readiness does not claim public launch or backup readiness.

## 2026-10-24 — Direct attendance, development migration 34

Owner-requested removal of attendance approval: Secretary has no finalize action, manual-mode notice, finalization metadata or correction-reason field. Status choices save immediately; unmarked students remain unmarked. Existing finalized sessions can be corrected without a reason. The retired finalize RPC no longer grants execute to authenticated clients; historical metadata and immutable change logs are preserved. Tenant, role, cancelled-session and optimistic-concurrency checks remain enforced.

Session badges and history grouping use starts_at/ends_at, with a one-second foreground clock and focus refresh. A session completes only at its end time; cards display both start and end. Hosted APIs already derive status from timestamps, independently of attendance.

Deployed only 202610240002_direct_attendance.sql after a verified 33-version history/catalog baseline and dry run naming only this migration. Postflight matched all 34 migration bodies, 73 functions, 18 tables, 30 policies and 25 triggers. All 18 table fingerprints and financial totals matched pre/post; no hosted fixture or account mutations.

Validation: 39 Secretary unit tests; lint/typecheck/configured web build; 2 isolated SQL-fixture browser attendance tests (desktop/mobile); 9 native SQL-role direct-attendance assertions; baseline 90 assertions; Secretary contract 59 checks; concurrency 11 and Secretary concurrency 34; actual authenticated hosted Chromium 5 read-only checks. These are automated checks, not owner or physical-device acceptance. Teacher APK unchanged.

## Current checkpoint — dated classes and stable resume, 24 October 2026

Owner-requested development changes implemented and migration 33 deployed/verified once to centerly-dev. Weekly timetables have no dates/generation/add-appointment flow; group details edit the weekly timetable. Separate Create Class selects group/date/time and Included or Additional pricing (owner explicitly merged free into included). Extra per-student invoices and attendance are atomic/idempotent; late enrollments before class reconcile once, history retained. Same-user web auth events no longer clear screens/cache; Teacher background checks retain workspace and lazy tab state, with scoped last-tab persistence. Native splash/normal themes white in light/dark mode. No hosted business mutations/fixtures, account changes or production publication. Full 33-version history/catalog/grants and all prior row fingerprints/financial totals verified. Local 28 SQL-role checks, 90 baseline SQL checks, 38 unit tests, 22 synthetic browser tests, 29 targeted Flutter checks and analyzer/build pass. Actual SDK guards/reads and browser forms/focus verified without successful writes. New configured APK ready, USB absent, not installed; owner manual/device acceptance outstanding. See docs/MANUAL_CLASSES_AND_RESUME.md/json. Earlier 32-version checkpoints are historical.

## Current checkpoint — safe student/group deletion, 23 October 2026

Active student/group list rows and details now have Delete buttons with two warnings, exact record name and required acknowledgment before final submission. Existing secretary_archive retains history/payments and group students; no SQL deletion, migration or hosted business mutation. Dashboard excludes archived-group sessions. Baseline remains 32. Local 37 unit tests and 20 synthetic SQL-fixture desktop/mobile browser scenarios pass, including cancel/no request, required second acknowledgment and unchanged payment history. Actual connected browser opened both confirmation flows and canceled, with all business writes blocked. See docs/SAFE_DELETE.md/json. Development website ready; owner manual/device testing outstanding.

## Current checkpoint — multi-day group form, 23 October 2026

Migration 32 deployed and verified on centerly-dev after owner standing authorization. Group creation has weekday checkboxes and required hour/minute plus AM/PM selects; visible date removed, Cairo today supplied by server. All selected days saved atomically with immutable idempotent audit; failures roll back every day/group. Existing schedules, financial totals and all 18 table row fingerprints preserved. Full 32 history bodies/catalog/grants verified (69 functions, 24 triggers); first CLI history read failed to connect and read-only retry passed. Both manifests updated. Local 15 SQL-role assertions, 90 Teacher baseline checks, 37 client unit tests and all 16 synthetic browser scenarios passed (one focused rerun after search-test locator fix). Actual connected browser verified 18 read-only checks, including three selected days, no date and AM/PM dropdown. No hosted fixtures, group submissions, account changes or publication. Website http://127.0.0.1:5173/ ready for owner testing; no manual/device pass claimed. See docs/MULTI_DAY_GROUP.md/json. Earlier 31-version checkpoint text below is historical.

## Current checkpoint — required group schedule, 23 October 2026

Owner authorized immediate backend implementation for requested development changes without further approval. Migration 31 deployed/verified on centerly-dev. New secretary_create_scheduled_group atomically requires group+schedule; direct group INSERT revoked, legacy unscheduled creation rejected. Calendar shows all active groups and all current/future weekly schedules; both existing owner groups currently need the owner to set times. No invented schedules or hosted business writes. Full 31-version history/catalog/grants verified; all 18 table row fingerprints and financial totals unchanged. Both manifests advanced. Local 20 SQL-role checks, 90 Teacher baseline assertions, 36 Secretary unit tests and 16 synthetic desktop/mobile browser scenarios passed. Actual connected Chromium: 15 read-only checks, 2 groups shown. See docs/REQUIRED_GROUP_SCHEDULE.md/json. Website ready at http://127.0.0.1:5173/; owner manual/device testing remains outstanding. Earlier version-30/pending statements below are historical.

## Current checkpoint — FIN30 deployed, 23 October 2026

Owner-approved exact FIN30 transaction deployed once to centerly-dev as migration 30. Both manifests advanced after full history/catalog/grant/trigger verification. All 18 table row fingerprints and financial totals unchanged. Connected local financial editing enabled. Actual SDK: 47 read-only checks, 3 existing invoices; connected Chromium: 11 read-only checks with renewal stubbed. No current payment exists for hosted payment-edit UI verification; local 26 SQL-role and 16 synthetic browser tests cover financial edits, zero values and retry. Secretary 36 unit tests/lint/build pass. No business mutations, fixtures, cleanup, account changes or publication. See docs/FIN30_DEPLOYMENT.md/json. Local owner testing ready at http://127.0.0.1:5173/; phone absent, manual/device acceptance outstanding. All earlier pending FIN30/29-version checkpoint text is historical.

# Simple daily workspace — 2026-10-23

One schedule navigation entry with recurring group/day/time cards and per-day edits. Header shows actual teacher and secretary names. Groups use dropdowns without search; new prices start blank. Direct edit links simplify daily work. Operational payment views show current collections while preserving raw ledger history.

No hosted business/schema writes, resets, account changes or new fixtures occurred. FIN30 financial editing is prepared locally, NOT deployed or registered; both manifests remain at 29 and connected financial saving is disabled pending the exact review in SIMPLE_FINANCE_EDIT_REVIEW.md.

Validation: Secretary 36 unit tests plus lint/build; 16 synthetic SQL-fixture browser scenarios across desktop/mobile; 26 local PostgreSQL SQL-role checks; Teacher 14 targeted tests plus analyzer/configured APK build. Actual authenticated connected Chromium: 9 read-only UI checks, zero business writes. Renewal RPC was guarded/stubbed by the probe, not encountered. Device absent from ADB; no physical acceptance or new installation claimed.

Web: http://127.0.0.1:5173/. Configured APK SHA256: aefc8ec616ab204cad2d72dabc4b9ae1955f502f40316786d0a53a81a4a59fd2. Artifact inventories refreshed; decompressed APK and web credential scan found zero matches. Production remains deferred. Remaining owner actions: approve FIN30 for development deployment to enable financial edits; reconnect phone for installing this APK and owner testing.

Proposed shared API: secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text), with expected-value concurrency protection, transaction locks and idempotent immutable audit. original_amount_egp remains original face; amount_egp is adjusted effective total; ledger_net_egp and payable_balance_egp retain their existing meanings. No ledger rows erased. Teacher movement history remains complete and prepared parsers allow zero adjusted dues. Connected finance-edit flag stays false until approved deployment.

# SEC27 hosted acceptance complete — 22 October 2026

The owner-approved bounded SEC27 package and consolidated note/removal addendum completed on centerly-dev. Actual Supabase SDK/REST, Secretary Chromium and Windows Teacher UI acceptance passed. Thirteen audit events (limit 23), five attendance changes (limit 6), seven notifications (limit 8), exactly two note saves and one pending removal request are retained. Atomic guarded void cleanup ran once; both tenants’ complete financial totals and unrelated record digests match their pre-run baselines. Secretary-a remains active. No account/password/Auth configuration, migration, production deployment, push or publication occurred.

Current results and retained records: [SEC27 acceptance](SEC27_ACCEPTANCE_2026-10-22.md), [detailed evidence](SEC27_ACCEPTANCE_2026-10-22.json), [shared checklist](SHARED_COMPLETION_CHECKLIST.md), [matrix](CROSS_APP_ACCEPTANCE.md). Remaining gates: separate production/signing/privacy/support, provider recovery/monitoring, physical Android/iOS and remote CI/access. Archived-student RPC boundaries are documented; invoice/session histories remain retained/readable. Completed-run guards prohibit reseeding or repeated cleanup. Older unapproved-fixture/credential-absent statements below are historical.

# Shared pilot checkpoint — 22 October 2026

Current status and stable task IDs: [SHARED_COMPLETION_CHECKLIST.md](SHARED_COMPLETION_CHECKLIST.md). Real credentials are available; real Auth/Chrome and native Windows reads passed. All 27 migration hashes/history/catalog verified. See [PILOT_EVIDENCE.json](PILOT_EVIDENCE.json), [CROSS_APP_ACCEPTANCE.md](CROSS_APP_ACCEPTANCE.md) and [PILOT_OPERATIONS.md](PILOT_OPERATIONS.md). No hosted business/schema/config changes or publication. The following checkpoint text is historical where inconsistent.

# Progress pointer

Current checkpoint: Teacher owner-testing IMPLEMENTATION COMPLETE,2026-10-22.
Approved receipt-filter migration 26 (202610220001) deployed/verified on centerly-dev;
all 26 bodies/catalog pinned. Receipt search/method/kind enabled in connected mode.
No account/finance/fixture mutations; no build/restart during deployment follow-up.
251 Flutter PASS/1 hosted Auth SKIP,3 activation UI/adapter PASS,3 preview PASS,
119 local SQL assertions PASS,60 hosted read-only reports/230 pages/2,466 checks
plus tenant/role denials; analyzer clean. See FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md.

Owner ACCEPTANCE remains pending original credentials at
`/Users/mohamedsalem/Desktop/Centerly_mobile/.env.development-accounts.json`.
No pending implementation/backend approval blocks the agreed scope. Group notes
excluded, QR deferred; attendance free-text search unavailable, status filters work.
Testing guide contains exact preview=false/receipt-filters=true final build command;
owner will request it. Pilot/recovery/React acceptance are separate gates.

The session ledger is [IMPLEMENTATION_PROGRESS.md](../IMPLEMENTATION_PROGRESS.md).
Read it with agent_rules.md, CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md and
docs/DECISIONS.md at the start of every session. The owner explicitly authorized
temporary canonical backend ownership here; this overrides plan ownership clauses.

## 2026-10-19 resumed implementation

| Task | Status | Implementation commit | Files / validation | Next / blockers |
|---|---|---|---|---|
| T-013 | DONE (local acceptance) | ef11882 | core read cache/client, bootstrap invalidation, repositories; cache/identity/retry/error tests pass | Hosted cross-app acceptance remains T-050/T-054 |
| T-012 | IN_PROGRESS | ef11882 | production safe areas/navigation, wrapping shared metrics, font-loaded AR/EN 320/430 scale-2 captures | Full Figma composition, physical TalkBack/safe-area QA remain |
| T-020 | IN_PROGRESS | ef11882 | server date filter, live aggregates/session rows, scheduled minutes and refresh | Attendance summary RPC pending approval; seeded hosted UI reconciliation remains |
| T-021 | BLOCKED (hosted approval) | ef11882 | typed group DTO/repository and additive SQL proposal; 10k bounded fixture test | Approve reviewed development read extension before wiring live Groups |
| T-022 | IN_PROGRESS | ef11882 | day/week/month production reads; Cairo DST/boundary and range tests | Named-session contract, hosted/web/device agreement remain |
| T-024 | IN_PROGRESS | ef11882 | cancellation workflow tested with group identity, reason, guarded RPC and reconciliation | Production action gated until named-session contract; actor/history/hosted acceptance remain |

Commands: `flutter analyze --no-pub` PASS; `flutter test --no-pub` 37 PASS,
1 hosted opt-in SKIP; changed Dart format check PASS; screenshot capture matrix
4 PASS; `node supabase/tests/run.mjs` 88 PASS; concurrency 11 PASS; manifest
9 unchanged / 1 pending; diff check PASS. Debug APK attempt was interrupted during
Gradle 8.12 distribution download after over six minutes, before compilation;
not an APK pass or compile failure. No hosted commands/mutations/deployment ran.

Next approval: docs/TEACHER_READ_CHANGE_REVIEW.md, one new migration with three
teacher-only read functions. Support URL stays configurable/pending. Original
uncommitted analyzer/iOS/SDK lock resolutions and the supplied untracked plan are
preserved. The implementation commit stages only the new timezone lock entry,
leaving the five pre-existing SDK lock resolutions uncommitted.

## 2026-10-19 approved deployment and next eligible read workflows

Implementation commit: `18213b5` (approved deployment, production activation, directory/roster and next local proposal).

| Task | Status | Evidence / changed areas | Next / acceptance limits |
|---|---|---|---|
| T-010 | DONE under override | Exact SQL history before/after deployment; ten hashes pinned | Transfer same canonical history to future Secretary repo |
| T-012 | IN_PROGRESS | Responsive blue/white shell; 8 AR/EN normal/200% captures; accessible actions | Physical TalkBack/safe areas and full Figma parity remain |
| T-020 | IN_PROGRESS | Deployed overview counts, date filters, decimal display, named sessions; multi-read scope guard | Hosted password/UI fixture reconciliation and remaining filters |
| T-021 | IN_PROGRESS | Live group search/grade filter/pages/schedule and roster previews; full roster navigation | Hosted Flutter and device/10k interaction acceptance |
| T-022 | IN_PROGRESS | Named day/week/month reads, Cairo/DST tests | Stored status temporal/clock-skew and cross-app acceptance |
| T-024 | IN_PROGRESS | Identified production cancellation via existing RPC, tested confirmation/error/reload | No hosted mutations rerun; actor/time/history display remains |
| T-030 | IN_PROGRESS | Real directory and group roster via list_students; read-only contacts, stale/paged/logout tests | Full profile/memberships/academic/financial history/notes |

Actual commands/results: preflight SQL + validator PASS (nine originals and exact
remote history unchanged, expected 18 tables/30 policies/four accounts); dry run
only 202610190001; db push --linked --skip-vault --yes applied that file only,
no seeds/roles; postflight history/grants/search paths and all four synthetic actor
read-only SQL checks PASS. Anonymous REST: 401 for all three reads. No fixture/Auth
settings/password/account changes. No positive pending/cancelled-attendance hosted
rows exist; local nonvacuous tests cover those cases. Password-based Auth/SDK/UI
checks require the original missing credentials, which were not retrieved/reset.

Analyzer PASS, 52 Flutter PASS + 1 hosted opt-in SKIP, 90 isolated SQL PASS,
11 independent PostgreSQL race PASS, tokenizer unit test PASS, 8 capture tests
PASS, format/diff PASS, manifest 10 unchanged / 0 pending.
Initial Android configuration failed because current Flutter requires newer tools;
Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 now pass actual debug compilation.
`flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json` PASS:
SHA256 66ec39db51b754685329f12c9436165901eb840544c44c1676df0b10cb162b91.
No installation, iOS build, pilot signing or store publication performed.

Next: detailed attendance/session and full student-profile read contracts/UI.
No further hosted migration is approved. Support remains pending/configurable.

Next local slice: T-023 session-detail read proposal is prepared outside the managed
migrations directory. 31 disposable native PostgreSQL assertions PASS; separate
approval required before hosted changes/UI activation. Review:
docs/SESSION_DETAIL_CHANGE_REVIEW.md. Managed history remains ten / zero pending.


### 2026-10-19 — approved session detail deployment and Flutter activation

Only 202610190002 deployed, exact reviewed bytes. Ten baseline local hashes and
remote SQL bodies matched; dry run only the approved version, no seeds/roles,
vault skipped. Eleven-version postflight matched, hash pinned. Hosted read-only
checks passed teacher/tenant/both-secretary/anonymous authorization, empty search
path/grants, existing persisted counts and bounded reads; anonymous REST 401.
No fixture mutation, password or Auth configuration change. Positive pending,
cancelled-history, multi-page and real inactive fixtures unavailable remotely;
local detail suite covers those cases (33 assertions). Password Auth/SDK remains
pending original credentials.

Production T-023/T-024 detail now shows all four read-only status filters, cursor
pages, manual finalization, sync/correction metadata and cancellation actor/time/
reason. Parent views refresh after return; finalized corrections refresh correctly.
59 Flutter tests PASS + 1 hosted opt-in SKIP; final targeted refresh/race checks
PASS. Analyzer PASS; 90 local SQL + 11 native race assertions PASS; manifest eleven
unchanged/zero pending. Debug APK compilation completes successfully; artifact hash
and detailed evidence are in IMPLEMENTATION_PROGRESS.md and
SESSION_DETAIL_CHANGE_REVIEW.md. CI now includes the detail SQL regression suite;
remote CI/device/iOS/signing/cross-app acceptance were not rerun.

Next eligible T-030 read proposal is prepared and locally tested (21 assertions),
not copied into managed migrations/deployed/called by production. Separate review:
STUDENT_PROFILE_CHANGE_REVIEW.md. All existing user edits remain preserved.


2026-10-27 website publication: Secretary https://centerly-secretary.pages.dev deployed at application revision 1d39c8eae108dc22e70274b649f9d3c7ca8090c1 (Cloudflare deployment 7825d770). Verified live HTTP 200, matching build identity and six entry assets; CSP points only to centerly-prod. Teacher environment/UI revision b00ef9f pushed to main. Both backend datasets unchanged; production accounts remain empty. Owner requests validated pushes after future edits and direct website publication for website changes. No native install or manual-device pass claimed.


## 2026-10-27 — immediate secretary access deactivation

- Teacher-only deactivate_secretary(uuid) requires an active owning teacher, locks the secretary row, changes application status to inactive, resolves any pending removal request and appends one audit event in a single transaction. Repeated/concurrent calls are idempotent. Auth users, passwords and historical attendance/payment/academic records are preserved. Legacy request RPC remains compatible; current Teacher UI uses immediate deactivation, including previously pending requests, after explicit confirmation. Legacy navigation delegates to the same authenticated flow.
- Both dev and prod now have 38 migrations; exact 37-version baseline checked and each dry run listed only the new migration. All 18 business-table fingerprints unchanged during deployment. Full catalogs match: 86 functions, 30 policies, 30 triggers. Production still has zero users/rows.
- Evidence: docs/secretary-deactivation-acceptance.json. Tests: 19 isolated native PostgreSQL role checks (including tenant isolation, existing-session denial, concurrent idempotency, audit-failure rollback and history preservation), 90 baseline SQL checks, 4 Flutter checks, 6 Secretary auth checks and 2 actual authenticated hosted REST denied calls without deactivating any hosted account. No physical-device acceptance claimed.
- Access is denied on subsequent server requests; already-rendered browser data clears on profile polling (60 seconds), focus or access-denied response. No claim to retract previously downloaded information or abort operations already in flight. No reactivation UI added.


Delivery verified: Teacher feature f7f8913 pushed; Secretary application 3e32a1e deployed at https://centerly-secretary.pages.dev (deployment 3b35f419), live build/production CSP/six assets match. Secretary complete check passed with 78 tests. Both hosted schemas at 38 versions; no hosted account deactivation performed.


## 2026-10-27 — manually suspended subscriptions

Owner selected manual subscription suspension by administration. Existing subscription_status/RLS protection blocks teacher and attached secretaries; no new migration or hosted account mutations. Teacher now clears the stored SDK session after confirmed access denial while retaining the actionable subscription reason. Both clients show the payment-administration guidance; Secretary clears local auth storage and tenant caches, preserves the denial message through sign-out events and permits deliberate login after renewal. Network-only errors do not revoke access. See docs/SUBSCRIPTION_ADMIN.md for exact Dashboard actions and 60-second/foreground/offline limits. Verification: 16 isolated native PostgreSQL checks, 18 Flutter auth tests, analyzer clean, 79 Secretary tests plus format/lint/type/build. No hosted suspension or physical-device acceptance claimed.


Subscription release delivered: Teacher 262990a pushed; Secretary dcc9271 published at https://centerly-secretary.pages.dev (deployment 77f218ce). Live build/CSP/six assets verified. All 38 backend migration hashes unchanged, zero pending; no hosted account changes.


## 2026-10-27 — restore secretary access from the same card

Teacher secretary cards now show Reactivate access for inactive secretaries with explicit confirmation and server reconciliation. reactivate_secretary(uuid) requires an active owning teacher and subscription, serializes seat allocation on the teacher row, respects secretary_seats, locks the target and appends one audit event atomically. Duplicate/concurrent requests are idempotent; no Auth/password changes or historical-row deletion. A reactivated secretary signs in again with existing credentials; old removal history stays handled.

Both environments deployed exactly one migration after unchanged 38-version baselines; all 18 public-table fingerprints unchanged. Current catalogs match at 39 versions / 87 functions / 30 policies / 30 triggers. Production remains empty. Evidence: docs/secretary-reactivation-acceptance.json. Verification: 15 isolated native PostgreSQL checks including cross-tenant/role denial, subscription/seat limits, rollback and competing seat allocations; 90 baseline SQL checks; 4 Flutter checks; clean analyzer; 2 actual authenticated hosted denied REST calls. Existing inactive synthetic secretary is accepted as ACCOUNT_INACTIVE, rather than assuming every retained account is active. No hosted account was reactivated for testing; no manual device pass claimed.


Reactivation release delivered: Teacher b567a23 pushed, Secretary 4bb4947 deployed (b122d846); live build/production CSP/six assets match, all 39 migration hashes retained. Secretary full suite 79 tests passed. No hosted account reactivation or device acceptance performed.


## 2026-10-27 — home on cold launch, retain background navigation

Workspace tab selection now lives only in process memory, scoped to the authenticated teacher. main clears that in-memory selection on a new app run; legacy persisted tab values are ignored. A cold launch starts at Home after session validation, while ordinary pause/resume keeps the current tab, nested route and widget state. No lifecycle-resume navigation reset, backend, website or account changes. Verification: 12 session/auth tests, including legacy saved-tab rejection, new app-session reset and unchanged background tab. Manual physical-device testing remains owner-run.
