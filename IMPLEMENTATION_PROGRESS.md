# Centerly implementation progress

## GitHub CI repair — 2026-10-19

Main run 39293622024 passed lockfile/codegen/format/analyzer/Flutter tests, SQL and
manifest checks, then failed in native PostgreSQL startup during concurrency tests
with an undefined rejection. The pinned embedded-postgres start() drops stderr and
rejects without an Error when postgres.exe exits before readiness. Local Windows
uses a different privilege environment from the hosted Windows runner.

Disposable Windows clusters now start/stop with the same pinned PG17 pg_ctl, which
supports restricted Windows tokens. Controller output goes to temporary files to
avoid inherited-pipe EOF hangs. Startup has bounded waits, stderr/server diagnostics
and password redaction; tests/SQL assertions are not weakened or skipped. Other
platforms keep the existing native start. Added a real invalid-port startup test
for clear redacted failures. No Flutter, hosted schema/data or Auth changes.
Local native suites passed 11/33/21/98/22 assertions with the new controller;
GitHub run 39299955574 confirmed startup/concurrency/detail/profile now pass, then
exposed host-default WIN1252 encoding rejecting Arabic completion fixtures. initdb
now explicitly selects UTF8; a real Arabic/emoji round-trip/server-encoding test
guards independence from the Windows code page. Full remote rerun pending.
Pilot gates unchanged; no application or hosted backend changes.

## Teacher MVP completion — 2026-10-19 (current milestone)

This milestone supersedes the historical audit and intermediate task tables below.
Owner authorized implementation and explicitly approved the exact seven-file
completion package; approval does not include production, account/Auth changes or
publication. Existing design/assets and unrelated platform edits preserved.

- Approved/deployed 202610190004..010 to centerly-dev only. Immediately before
  deployment all twelve remote bodies and seven package hashes matched; dry run
  listed exactly those seven files. No seeds/roles/vault/backfill or existing
  migration edits. Postflight matched all nineteen bodies, 12 function metadata/
  grants/search paths, six indexes and two enabled triggers. Nineteen hashes pinned.
  Exact review/pins: docs/TEACHER_COMPLETION_CHANGE_REVIEW.md and
  supabase/completion-package-manifest.json. Sanitized verification JSON retained.
- Backend suite: local business 90 PASS; races 11 PASS; session detail 33 PASS;
  profile 21 PASS; completion 98 PASS; added integrity 22 PASS; SQL tokenizer 1 PASS.
  Integrity coverage includes simultaneous payment/reversal replay, exactly-one
  payment/removal notifications, competing note versions and Cairo DST boundary.
- Real hosted SDK login/restore/refresh/logout, secretary rejection and invalid
  password PASS. New hosted completion suite 98 PASS through real Auth/REST/RPC:
  both-tenant/secretary/anonymous checks; duplicate/reversed payment events; in-tx
  visibility and rollback of payment/event/invoice effects; null versus zero scores;
  pending then finalized correction after thirty days; note conflict/content restore;
  duplicate removal request, handled notification without deactivation; read marking
  and cancellation race. Only approved synthetic fixtures changed. No account/Auth
  configuration changes, provisioning or password resets. Test records remain for QA.
- Completion gate activated only after those backend checks. All core destinations
  now use deployed reads: profile/memberships, exams/assignments, student attendance,
  detailed global/student finance, notes, secretaries/removal and notifications.
  Finance placeholder replaced in the configured MVP. Dashboard/calendar derive
  status from server time; ended sessions hide cancellation. Secretaries remain
  read-only except removal requests; Teacher cannot write operations/finance.
- Regression additions: 14 AR/EN 320px/200% completion-page cases, note duplicate/
  conflict/ambiguous-write tests, real hosted native navigation test. Note reload
  failures preserve drafts and require reconciliation. Background account/token
  validation preserves nested navigation/drafts; startup/resume checks still gate,
  and failed account checks sign out. Tests cover nested navigation and deactivation.
- CI now includes profile/completion/integrity SQL suites. SDK/lock mismatch traced
  to five Flutter-pinned packages: existing Windows resolutions match 3.44.2; no
  dependency upgrade or unrelated lock edits. Enforced pub get PASS with existing
  lock bytes unchanged. Final analyzer clean; 82 Flutter tests PASS, one hosted
  opt-in skipped in default run (passed separately); format and whitespace PASS.
  Native Windows real hosted core navigation PASS, and separate actual secure
  persistence/restore/logout PASS. These are native reads/auth, not Android or full
  native UI mutation acceptance. Earlier test-harness failures (wrong fixture ID,
  ambiguous calendar icon, English-only back tooltip, CLI result format/last-row
  assumptions) were corrected and final runs passed; no SQL changes were needed.
- TEACHER MVP READY FOR OWNER DEVELOPMENT TESTING: final configured debug APK
  compiled after fixes; ZIP integrity and scan for all synthetic passwords/env
  files PASS. SHA256 9d058ca18d6f0a694bcc1169975922af081c793e454693fa81918296a7f780b7.
  Artifact: build/app/outputs/flutter-apk/app-debug.apk (170553861 bytes),
  Android >=7.0/API24, ARM64/ARMv7/x86_64, com.example.centrally 1.0.0+1 debug key.
  No core placeholders in this configured build. No physical-device installation,
  Android performance/storage verification, release signing or pilot claim.
- Support URL remains empty/configurable. No Android device/emulator is available;
  Windows native testing is supplementary, not Android acceptance. Cached Android
  SDK compiles despite some outstanding licenses for future SDK installs. Kotlin
  plugin warnings concern future Flutter versions, not this successful build.
- Next handoff: docs/SECRETARY_HANDOFF.md (canonical nineteen-version transfer,
  permissions, environment, exact money/manual attendance and remaining cross-app
  matrix). docs/TEACHER_MVP_TESTING.md contains install/manual steps. Pilot gates
  remain physical device/security/performance/accessibility/update/signing, real
  app identity/privacy/support, backup restore/monitoring and Secretary acceptance.

| Current IDs | Testing handoff status | Remaining acceptance |
|---|---|---|
| T-010/013 | Nineteen-version contract pinned; remaining typed reads/actions active | React shared pin and cross-app matrix |
| T-011/012 | Real Auth/native storage and AR/EN adaptive shell verified locally | Support URL; Android restore/accessibility/device QA |
| T-020..024 | Live overview/groups/calendar/detail/manual attendance/cancel flows wired | Owner Android QA; Secretary reception/correction matrix |
| T-030..034 | Live profile/memberships/academics/student attendance/finance/notes wired | Owner Android edge cases and cross-app reconciliation |
| T-040/041 | Own secretary/removal and real notifications/read marking wired | Operator/Secretary joint acceptance |
| T-042/050..054 | Automated suites and testing APK delivered; pilot acceptance open | Physical security/performance, signing/update, monitoring/restore, cross-app sign-off |

Exact next eligible task: begin the Secretary React app against this canonical
shared schema, using docs/SECRETARY_HANDOFF.md. Do not replay migrations or infer
pilot readiness; future hosted contract changes require separate owner review.

## Historical checkout audit — 2026-10-19, Windows

This section supersedes conflicting older status entries below. Audit only: no
implementation, deployment, Auth setting changes, password resets or hosted
fixture mutations. Only this ledger was edited; owner lockfile changes retained.

- HEAD `effcd270618f91f2e103e150f4c870d4402e097f`, branch
  `codex/teacher-auth-foundation`. Successful origin fetch: HEAD and remote branch
  match (0 ahead/0 behind), newer than de42879. Pre-existing sole modification:
  pubspec.lock downgrades intl, matcher, meta, test_api and vector_math relative
  to committed resolutions. No reset/merge/dependency installation performed.
- Rules, root plan, contract, roadmap and latest reviews/verification JSON read.
  Historical task table is stale: full profile code is wired; academics, student
  attendance, finance, notes, secretaries and notifications now have local code,
  rather than being NOT_STARTED. This does not make them hosted-complete.
- Production auth uses real Supabase SDK, secure session storage, live teacher/
  tenant validation and logout/refresh. Dashboard, group search/filter/pages,
  day/week/month sessions, reasoned cancellation, read-only session attendance,
  student directory and contact/membership profiles have live RPC/UI paths.
  Current audit did not perform a password-based Flutter/device end-to-end flow.
- Completion UI/models/repositories exist for academics, student attendance trends,
  exact-decimal finance, optimistic notes, secretary removal requests and recipient
  notifications. Entry points are gated by CENTERLY_COMPLETION_CONTRACTS (false
  by default and absent from local runtime config); Finance remains a placeholder
  in a normal build. New calendar/server-time path is gated too. Legacy mock/demo
  screens remain in source, outside the production router. No entire feature is
  newly accepted on the strength of mocks or SQL tests.
- Fresh authenticated, read-only hosted inventory: all twelve migration SQL bodies
  match local pinned history through 202610190003; 18 tables, 30 policies, no table
  lacking forced RLS, no anonymous Centerly RPC execute or unsafe definer search
  paths; four expected synthetic Auth users; platform helper retained. Separate
  read-only query confirms all seven completion public reads are absent remotely.
  Seven proposals 202610190004..010 remain under proposals/teacher_completion;
  none is a managed/deployed migration. Manifest's '0 pending' refers only to
  managed migrations, not these proposals. Completion package is not activated.
  Public Auth settings returned HTTP 200: email provider enabled and public signup
  disabled. This is fresh connectivity evidence, not a password-login test.
- Tools present: Flutter 3.44.2/Dart 3.12.2, Node 24.12.0, Java 17, Android SDK 36,
  Visual Studio Windows tooling, cached Supabase CLI 2.121.0. CLI authentication
  works and ignored project-ref matches expected development project.
  .env.local.json, .env.development-accounts.json and .env.native-auth.json exist
  and parse; public runtime URL/key present, support URL empty. No secret values
  printed; none of these files tracked. Password validity not tested this audit.
  Older Mac-specific missing-credential/tool-version statements are historical.
- Fresh checks: analyzer clean; Flutter suite 64 PASS / 1 opt-in hosted SKIP;
  format check lib/test/integration_test 261 files unchanged; SQL suite 90 PASS;
  native PostgreSQL concurrency 11 PASS; session-detail 33 PASS; student-profile
  21 PASS; completion-package 98 PASS on disposable local DB only; 12 manifest
  hashes unchanged; git diff whitespace check clean before ledger edit.
  Raw CLI preflight included a diagnostic prefix; extracted JSON validated
  successfully against all twelve exact SQL bodies. Evidence logs in ignored
  .buildlog/audit_*; no sensitive payloads included in this ledger.
- Not rerun: hosted password SDK/native integration, hosted mutation/fixture tests,
  APK/profile/release builds, codegen, clean-checkout replay, remote CI, visual
  captures or physical-device acceptance. Earlier Windows native auth and hosted
  36-case results, later Mac debug APKs and deployment role checks are historical.
  CI currently targets PRs/main pushes and omits the completion-package suite.
- flutter doctor: Android licenses outstanding; only Windows/Chrome/Edge detected,
  no physical Android device. iOS requires a Mac. Committed lockfile/current SDK
  compatibility needs an explicit review; existing release uses debug signing and
  com.example.centrally. No signed pilot or device-ready artifact certified here.
- Next eligible implementation slice (only after audit authorization): T-010/013
  completion-package review/compatibility pin and missing feature regression tests,
  preparing one concrete deployment review; do not enable the gate before explicit
  hosted approval and postflight verification. Then T-030..034/T-040..041 acceptance.
  Inputs: real support URL, completion-package approval before deployment, Android
  license acceptance/device, later app identity/signing/privacy/recovery ownership
  and Secretary environment. Credentials/access are present, not a current blocker.
  Pilot gates remain real two-tenant password/UI/cross-app tests, pending/cancelled/
  correction/ledger cases, device accessibility/performance/storage, signing,
  monitoring and an encrypted backup with successful restore drill.

Updated: 2026-10-19 (Africa/Cairo). Session detail deployment and Flutter activation after 66ee032.
Current phase: T2 live session detail/read-only attendance; T-030 profile contract proposal.
Development backend is deployed with explicit owner approval; not production ready.

## Approved read deployment and activation — 2026-10-19

Owner approved only 202610190001. CLI login completed on this Mac; verified and
linked the expected centerly-dev project. Read-only preflight matched exact SQL
history and all nine pinned hashes, 18 tables/30 policies/forced RLS and four
synthetic accounts. Dry run listed only 202610190001, no seeds or roles. Deployment
used --skip-vault; postflight confirmed all ten SQL bodies match local history.
Manifest now pins the tenth hash (6830529e…71f817b8). No other migration, fixture
mutation, Auth configuration, password reset or account creation ran.

New RPCs: three empty-search-path SECURITY DEFINER reads; authenticated execute,
no anonymous execute. Real read-only hosted role/JWT-subject checks with the
existing synthetic UUIDs passed for both tenants, teacher authorization, counts,
secretary denial and anonymous denial. Three anonymous REST calls returned 401.
Current hosted fixtures contain zero not_marked and zero cancelled attendance
rows: positive preservation/exclusion was verified locally, not claimed hosted.
Local SQL suite now has 90 assertions including an isolated cancelled/pending case.

Public config was reconstructed with owner-only permissions and remains ignored.
The original operator environment is not mounted/configured via SSH. Synthetic
account passwords remain unavailable; no attempt to retrieve them was made.
Password-based hosted SDK/Flutter tests require the original credential file.
Approval and deployment are no longer blockers for this read extension.

Production activation: overview attendance counts remain distinct, including
not_marked; named sessions enable identified cancellation; Groups now has real
server search/grade filter, cursor pagination, retry/refresh and bounded roster/
schedule previews. Typed errors and stale-search/duplicate-page guards are tested.
Physical device/full hosted UI/Figma acceptance remains open. Gradle 8.12 failed
configuration against Flutter 3.47.2; updated Gradle/AGP/Kotlin to the installed
SDK's supported minimums (8.14/8.11.1/2.2.20). Debug compilation then passed, and a
second current-source debug APK with public development config compiled successfully.
APK SHA256: 66ec39db51b754685329f12c9436165901eb840544c44c1676df0b10cb162b91.
No device installation, signed release, iOS build or production-readiness claim.

Next eligible T-030 slice implemented using existing list_students: global
read-only student directory plus group-scoped roster, bounded search/cursor pages,
missing contact values shown as missing, stale search and duplicate page guards.
Logout regression verifies nested contact screens are removed. Full profile,
membership/academic/financial history and notes remain incomplete.

Final local checks: analyzer clean; full Flutter suite 52 PASS / 1 hosted opt-in
SKIP; eight font-loaded shell captures at AR/EN 320/430, 100%/200% text PASS;
local SQL 90 PASS; independent PostgreSQL races 11 PASS; migration-history tokenizer
unit test PASS; 10 deployed hashes unchanged / 0 pending; Dart format and diff checks
PASS. Default SDK tests use synthetic HTTP; native hosted Auth/SDK/UI tests were not
rerun without original development credentials. Sanitized deployment evidence:
docs/verification/teacher_read_20261019.json.

## Historical repository audit (before implementation resumed, 2026-10-19)

- Branch: `codex/teacher-auth-foundation`; HEAD:
  `de428791d6097d659ffbbde15d1b0746cc6a27f5`
  (Add typed teacher read repositories and record verified milestones).
- Active implementation stop: T-013, partial typed read infrastructure. Dashboard,
  student and session models/repositories, bounded reads, one transient-network
  retry and sanitized access/error handling exist. Student/session repositories
  are registered but have no production UI consumers. Caching, remaining
  operational models/contracts and live feature integration remain unfinished.
  T-011 remains open for configured support; T-012 full live shell is incomplete
  (a minimal workspace exists). No task was advanced during this audit.
- Production routing reaches TeacherWorkspace: Home renders four live aggregate
  values through get_teacher_dashboard; Sessions/Groups/Finance render pending
  text. Full legacy home/groups/sessions/details/attendance/student profile and
  secretary screens still use CenterlyMockData and are not production routes.
  Backend RPC availability is not Flutter feature completion.
- Authentication has a real SDK/repository/UI path, secure persistence, live
  profile/role validation, refresh, logout and resume/periodic revalidation.
  Earlier hosted SDK and native Windows passes are historical reports below;
  this audit did not contact hosted Supabase or re-run native integration.
  The live dashboard is wired but its rendered hosted values are not independently
  proven by this audit or the native auth test (which checks workspace presence).
- Required CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md is absent from this checkout,
  the searched Desktop tree and this repository's available git history. Task IDs
  below come from the retained ledger; exact plan acceptance cannot be checked.
- Fresh checks: flutter analyze --no-pub PASS (no issues); flutter test --no-pub
  PASS (25 passed, 1 hosted opt-in skipped); npm ci --prefix supabase/tests PASS;
  node supabase/tests/run.mjs PASS (64); node supabase/tests/concurrency.mjs PASS
  (11); node supabase/tests/check_manifest.mjs PASS (9 unchanged, 0 pending);
  git diff --check PASS before this documentation edit.
  Initial SQL test attempt lacked dependencies; rerun passed after npm ci.
- Default SDK tests use synthetic HTTP fixtures, not hosted Auth. The visual test
  checks legacy RTL layout/no exceptions; it is not a pixel golden comparison or
  proof of the live workspace design. No screenshot recapture was requested.
- Current host: Flutter 3.47.2/Dart 3.13.2, Node 25.2.1, differing from the pinned
  Flutter 3.44.2/Dart 3.12.2/Node 22+ baseline. No builds, codegen, device tests,
  hosted tests, CI runs or full clean-checkout verification were rerun here.
- Pre-existing uncommitted files: analysis_options.yaml (platform/build excludes),
  pubspec.lock (five SDK-related resolutions), ios/Podfile.lock (plugin changes),
  ios/Runner.xcodeproj/project.pbxproj (13 -> 15 deployment target and removed
  CocoaPods resources phase). Origin/native validity of iOS edits is unverified.
  This audit only changes IMPLEMENTATION_PROGRESS.md; no hosted changes.
- Deployment/security claims below are historical, corroborated by committed SQL,
  manifest and review documents plus fresh local tests, not a fresh remote inventory.
  docs/HOSTED_CHANGE_REVIEW.md retains predeployment wording in its historical
  sections; do not treat those sections as current migration state.
- Owner input: real support URL; recover/provide the missing plan for exact
  acceptance mapping. Later approvals/access are required for additional hosted
  migrations, pilot operations, target devices/signing and Secretary cross-app QA.
  Neither support URL nor missing plan prevents independent repository analysis
  or bounded work from the existing contract once implementation is authorized.
- Next implementation task after authorization: finish T-013 caching and typed
  operational contracts against existing approved RPCs; explicitly review any
  backend gaps before proposing new migrations. Then finish T-012 live shell and
  T-011 support, T-020..024 dashboard/schedule/attendance, T-030..034 student and
  records/finance/notes, T-040..042 secretary/notifications/polish, and T-050..054
  integration/security/performance/device/signing/cross-app acceptance. Backups,
  restore, monitoring and remaining backend contracts remain pilot gates.

## Resumed implementation — plan reconciliation (2026-10-19)

The root plan is now available and read in full with repository rules, README,
shared contracts and ADRs. Owner overrides remain authoritative: this repo owns
canonical migrations; manual attendance has no time lock/conversion; deployed
001..009 are immutable; hosted changes require explicit approval. Support remains
pending/configurable and does not gate unrelated work.

Acceptance reconciliation: T-010 remains accepted under the owner override, not
under the plan's original no-teacher-migrations ownership. T-011 is incomplete
only where evidence/configuration is missing; do not claim full device acceptance.
T-012 was incorrectly labelled NOT_STARTED despite an existing minimal workspace;
it is IN_PROGRESS and needs production visual/scaling/semantics acceptance.
T-013 acceptance is repository infrastructure (not every future feature model);
student/session UI wiring belongs to subsequent tasks. T-020 is incomplete even
though aggregate reads exist. Existing T0 passes refer to the recorded historical
baseline, not a new clean-checkout result on the current SDK or working tree.

T-013 local slice: cache is memory-only, 30-second TTL, max 64 entries, keyed by
SDK user + endpoint + parameters. It returns decoded copies, never serves stale
fallback, clears on account validation/signout, rejects late replies across
session/token/generation changes, and supports refresh bypass. Sensitive data is
not persisted. Nine targeted repository/cache/error/model tests passed. A typed group-summary
repository/model is also prepared and tested for the pending contract; it is not
registered or called by production navigation. Refresh
and retry callbacks were also corrected to avoid returning Futures from setState;
refresh failures remain in the localized retry UI.

T-012 local slice: safe areas in production workspace, scalable navigation height,
localized loading semantics, scrollable error/pending content, and shared metric
cards wrapping instead of overflowing at 200% text. Production widget regression
matrix passed in Arabic/English at 320/430 pixels and 200% text. Actual font-loaded
screenshots are retained; visual differences and pending physical TalkBack acceptance
are documented in VISUAL_PRESERVATION.md. No hosted backend mutation/deployment occurred.

### Subsequent local milestones

- T-020 slice: dashboard now parses real session rows, uses the server date,
  accepts a selected date through the existing p_date argument and displays
  session counts/scheduled minutes excluding cancellations. Financial values stay
  server-calculated. Attendance counters are not invented; approval proposal below.
- T-022 slice: production Sessions tab replaces pending text with existing RPC
  day/week/month reads, Sunday-based weeks, useful empty/error/retry states, Cairo
  IANA display independent of device timezone, manual finalization labels.
- T-024 slice: cancellation dialog validates reason and confirms preservation of
  attendance/notification to secretaries via existing RPC. It disables duplicate
  submission; mutations are never automatically retried. Errors require returning
  to refresh, and the list reconciles after closing. No fake successful cancellation. Session cancellation controls are gated on
  group identity: current deployed list_sessions lacks names, so production shows
  read-only cards until the reviewed named-session RPC is approved and wired.
  Workflow tests include explicit group identity; full hosted acceptance stays open.
- Pending migration 202610190001 adds three teacher-only read functions only. Local
  SQL suite passes 88 assertions including 10k bounded group fixture checks,
  cross-tenant/role/anonymous denial and explicit not_marked counts. Original nine
  hashes unchanged, one pending version; 11 concurrency assertions pass.
- Full Flutter suite: 37 passed, one opt-in hosted test skipped. Analyzer passed
  before the final documentation-only changes. Font-loaded capture matrix: 4 pass.
  Debug APK attempt was interrupted during the Gradle 8.12 distribution download
  after more than six minutes; compilation was not reached and no APK pass is claimed; no native-device/hosted verification claimed.
- Next contract-dependent work requires owner approval of the concrete proposal in
  docs/TEACHER_READ_CHANGE_REVIEW.md before hosted deployment. No hosted state was
  contacted or changed in this slice. Support URL remains pending and configurable.

## Historical task ledger (superseded by current milestone above)

| ID | Status | Evidence / remaining acceptance |
|---|---|---|
| T-001 | DONE | Original audit and screen map retained |
| T-002 | DONE | ADR-001, actual Arabic home/groups/sessions captures, visual comparison in VISUAL_PRESERVATION.md; original Figma PNGs preserved |
| T-003 | DONE | All 12 documented checks passed on clean checkout of 3f6f16b, including debug/profile builds; CI configured |
| T-010 | DONE (owner override) | Canonical schema here, nine hosted versions verified, deployed hashes pinned, shared contracts and typed auth profile tested |
| T-011 | IN_PROGRESS | Real SDK auth, secure storage, guards, logout/refresh/role checks implemented; native Windows verification passed; configured support channel pending |
| T-012 | IN_PROGRESS | Blue/white live shell, adaptive paired metrics, safe areas, accessible actions; 8 font-loaded AR/EN scale captures pass; physical TalkBack/full Figma acceptance remain |
| T-013 | DONE (local acceptance) | Existing read RPC models/repositories, bounded pagination, safe errors/retry, 30-second bounded memory cache and stale-session rejection pass regression tests; hosted cross-app acceptance remains T-050/T-054 |
| T-020 | IN_PROGRESS | Live date-filtered metrics, scheduled minutes, session cards, refresh; attendance-count contract proposed locally, hosted fixture/UI reconciliation pending |
| T-021 | IN_PROGRESS | Approved RPC deployed; production search/grade filtering/cursor pagination/previews wired; hosted SQL isolation passes, full Flutter/scale-device acceptance remains |
| T-022 | IN_PROGRESS | Production day/week/month sessions wired to deployed RPC; server initial date, Cairo DST display, ranges/empty-state tests pass; hosted/web/device acceptance pending |
| T-023 | IMPLEMENTED / acceptance pending | Deployed typed detail, all four read-only status filters, bounded pages, finalized/sync/marker metadata and correction refresh; local UI/race/SQL tests pass; password-hosted Flutter/device and cross-app acceptance remain |
| T-024 | IN_PROGRESS | Reason/confirmation, duplicate guard, secure RPC, no automatic mutation retry, cache invalidation and refreshed status tested with synthetic transport; production action now uses named-session contract; actor/reason/time history now wired; hosted Flutter/cross-app acceptance remain |
| T-030 | IN_PROGRESS | Production server-search directory and group roster with read-only contacts, bounded pagination and logout guard tested; full profile/membership and hosted Flutter acceptance remain |
| T-031..T-034 | NOT_STARTED | Live academic/attendance/finance history and notes require remaining read contracts/UI |
| T-040..T-042 | NOT_STARTED | Live secretaries/notifications and design polish |
| T-050..T-054 | NOT_STARTED | Full integration/security/performance/signing/cross-app acceptance |
| T-LATER-01..03 | DEFERRED | QR scanning, push, public stores/billing |

## Original hosted milestone (approved in chat; historical)

- Supabase CLI 2.121.0 authenticated through user-authorized login. Discovered the
  sole project centerly-dev, reference yfeubomyglmhuwizaqoj; repository linked.
- Read-only preflight: zero business tables/policies/Auth users/migration history;
  pre-existing rls_auto_enable() helper. No application-name conflicts found.
- Owner separately approved the nine migrations, four development accounts/fixtures,
  and public signup denial. Deployed exactly versions 202610180001..202610180009.
- Postflight: 18 application tables, 30 policies, every table ENABLE/FORCE RLS,
  zero anonymous Centerly RPC grants, zero unsafe Centerly definer search paths.
- Four synthetic accounts and two isolated fixture tenants provisioned through
  approved trusted tooling. Credentials only in ignored .env.development-accounts.json.
- Public signup disabled; email/password login enabled. Corrected the CLI email
  provider flag after verification showed it also disabled email login. Only scoped
  Auth settings changed; undeclared hosted properties preserved.
- Security Advisor warnings documented in BACKEND_REVIEW.md; none silently hidden.

## App and tooling changes

- Preserved theme/fonts/assets/widgets and baseline teacher screenshots. Replaced
  fake-token login, role selector and cached/query role authorization with live
  get_current_profile() validation. Public registration routes removed.
- Supabase session persisted via FlutterSecureStorage; SDK refresh/logout, duplicate
  submission and stale-result protection; periodic/resume account revalidation.
- Production route never enters secretary operations or mock-data screens. Initial
  dashboard reads real server aggregates; unfinished tabs explicitly show pending.
- Arabic/English errors/support labels; no invented support number. Config rejects
  privileged keys and remote plaintext HTTP; Android INTERNET permission added.
- Unused Firebase dependencies removed (no app references, push deferred). Existing
  REST adapters are unreachable from production and retained for staged cleanup.
- Added CI, setup docs, codegen drift check, schema manifest, native/hosted/local
  auth tests, real PostgreSQL 17 concurrency tests and trusted provisioning scripts.

## Earlier baseline verification (historical)

- pub get and codegen: PASS; analyzer: PASS (no issues).
- Debug APK with public hosted config: PASS; debug/profile builds on clean checkout: PASS.
- Local PostgreSQL/PGlite: 64 authorization/business assertions PASS.
- Independent PostgreSQL 17.10 connections: 11 race assertions PASS.
- Hosted Auth/REST/RPC: 36 fixture-only assertions PASS (including real concurrent
  payment/cancellation calls, tenant denial and inactive access).
- Actual hosted Dart SDK: teacher login/profile/refresh/logout, secretary rejection
  and invalid credentials PASS. Local unit tests cover secure storage, stale results,
  duplicate taps, errors and profile validation. Final baseline suite: 25 PASS; one opt-in hosted test skipped in default run (passed separately).
- Native Windows login, secure persistence, restore and logout: PASS after removing unused Firebase packages. Android device disconnected; no Android device
  installation or iOS native verification claimed.
- Clean checkout of 3f6f16b: all 12 documented commands PASS. Remote GitHub CI execution remains pending push.

## Files and decisions

See git diff / local commits for full file list: .github/workflows/verify.yml,
docs/{SETUP,VISUAL_PRESERVATION,BACKEND_REVIEW,HOSTED_CHANGE_REVIEW,DEVELOPMENT_ACCOUNTS}.md,
lib/app and core auth/config/router, auth domain/data/presentation, initial dashboard,
translations, pubspec/lock, Android manifest, supabase config/admin/tests/manifest,
test auth/visual helpers and integration_test/auth_session_test.dart.
The two original migration fixes occurred before first deployment; deployed files
are now immutable and hash-checked. No further schema changes are approved implicitly.

## Exact next task / blockers

T-023/T-024 detail and read-only attendance are wired against approved deployed
202610190002. Password-hosted Flutter/device acceptance remains open; SQL checks
are not substitutes. Next eligible T-030 profile contract is prepared locally in
`supabase/proposals/202610190003_student_profile.sql`, with review in
`docs/STUDENT_PROFILE_CHANGE_REVIEW.md`. It is not a managed migration and requires
separate explicit approval before hosted activation. No other deployment is authorized.
Support remains configurable/pending. Existing uncommitted SDK/iOS/config work
and the user-added root plan are preserved. Physical TalkBack/safe-area/Figma QA,
backup/restore, monitoring, device/signing and Secretary acceptance remain pilot gates.

## Approved session-detail deployment — 2026-10-19

Deployed only `202610190002_session_detail.sql`, exact reviewed SHA256
`7a93684737cab4be2b9b0a281c000c139271770532131533f92c54615f7d8273`.
Preflight matched all ten pinned local hashes and remote SQL bodies; dry run listed
only this version (no seeds/roles, vault skipped). Postflight matched all eleven
remote SQL bodies and expected 18 tables/30 policies/four synthetic accounts.
Read-only SQL role checks passed: teacher reads, other-tenant NOT_FOUND, both
secretaries FORBIDDEN_ROLE, anonymous execution denial, missing-session NOT_FOUND,
unprovisioned ACCOUNT_INACTIVE. Function is definer with empty search_path,
authenticated grant, no PUBLIC/anon grant. No fixture/Auth configuration changes.
Existing teacher fixtures: two sessions; counts and bounded first pages agree with
persisted rows. Zero positive not_marked/cancelled-history rows; multi-page and
positive pending/cancelled-history cases remain local-only. Existing inactive
account fixtures unavailable: positive inactive/subscription denial tested locally,
not claimed hosted. Password-based Auth/SDK acceptance still awaits credentials.
Hash pinned. Flutter T-023/T-024 integration is in progress; deployment alone does
not complete these tasks.


## T-023/T-024 Flutter milestone — 2026-10-19

Production dashboard and session cards open the real typed detail contract. The
Teacher UI provides all/present/absent/excused/not_marked filters, bounded cursor
pages, manual finalization and last-sync timestamps, student/marker/update data,
and cancellation reason/actor/time. No attendance edit/finalize or automatic
absence controls exist. Missing rows are explained separately from not_marked.
Refresh resets accumulated pages and shows corrections after finalization; late
filters, duplicate pages and access revalidation fail safely. Existing cancellation
reason/confirmation/conflict reconciliation remains; ended detail actions use server
sync time. Return from detail refreshes parent aggregates/list. Backend notification
creation has local coverage; Secretary reception is not claimed verified.

Fresh checks: analyzer PASS; final combined Flutter suite 59 PASS/1 hosted opt-in SKIP.
Local SQL: 90 business assertions PASS; session detail 33 PASS; independent native
concurrency 11 PASS; tokenizer 1 PASS; eleven immutable hashes/zero pending PASS.
Configured debug APK compiled successfully (assembleDebug completed), SHA256
`98604e1fadbb13a08fb820df8a2a491bf218c14580833108c6aa1adf93c23316`.
No device installation/iOS/release build or current remote CI run claimed.

Continued T-030: bounded read-only profile/membership proposal prepared outside
managed migrations; 21 disposable PostgreSQL assertions PASS. Not deployed or
called by production. Next activation needs explicit reviewed approval; academic,
student attendance/finance/notes and later modules remain incomplete.


## Completion-path and approved profile milestone — 2026-10-19

Remaining checklist, implementation/acceptance estimates and separate owner-test/
pilot definitions: docs/TEACHER_COMPLETION_ROADMAP.md. Review all T-001..054 gates;
existing mock screens remain excluded. Plan range: 21–37 engineering days of
implementation plus 14–23 acceptance days, external waiting/Secretary work extra.

Owner separately approved only 202610190003_student_profile. Eleven-version
hash/remote SQL preflight and only-this-version dry run passed; deployed with vault
skipped and no seeds/roles. Twelve-version postflight passed; exact approved SHA
760740f7d4ea2c59cbaa645619fcf8f22375d73eadd115c12277c4ff3ce291e5 pinned.
Read-only existing-fixture SQL checks passed contacts/membership counts/scope,
tenant/secretary/anonymous/missing denial and grants/search_path. No fixture writes,
Auth/account changes or other migration deployed. Password SDK/UI remains pending.
Profile/membership Flutter integration is being tested; not marked fully accepted.
Remaining reads and event producers are being consolidated into one local package;
all unapproved production entry points default disabled until approved deployment.
