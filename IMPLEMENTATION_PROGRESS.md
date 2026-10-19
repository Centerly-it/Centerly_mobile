# Centerly implementation progress

Updated: 2026-10-19 (Africa/Cairo). Implementation commit ef11882; historical audit at de42879.
Current phase: T1 repository/shell hardening; T2 live dashboard/session slices.
Development backend is deployed with explicit owner approval; not production ready.

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

## Task ledger

| ID | Status | Evidence / remaining acceptance |
|---|---|---|
| T-001 | DONE | Original audit and screen map retained |
| T-002 | DONE | ADR-001, actual Arabic home/groups/sessions captures, visual comparison in VISUAL_PRESERVATION.md; original Figma PNGs preserved |
| T-003 | DONE | All 12 documented checks passed on clean checkout of 3f6f16b, including debug/profile builds; CI configured |
| T-010 | DONE (owner override) | Canonical schema here, nine hosted versions verified, deployed hashes pinned, shared contracts and typed auth profile tested |
| T-011 | IN_PROGRESS | Real SDK auth, secure storage, guards, logout/refresh/role checks implemented; native Windows verification passed; configured support channel pending |
| T-012 | IN_PROGRESS | Production safe areas, scalable metric layout and loading/retry fixes implemented; device TalkBack and visual acceptance remain |
| T-013 | DONE (local acceptance) | Existing read RPC models/repositories, bounded pagination, safe errors/retry, 30-second bounded memory cache and stale-session rejection pass regression tests; hosted cross-app acceptance remains T-050/T-054 |
| T-020 | IN_PROGRESS | Live date-filtered metrics, scheduled minutes, session cards, refresh; attendance-count contract proposed locally, hosted fixture/UI reconciliation pending |
| T-021 | BLOCKED (hosted contract approval) | Additive teacher group-summary read prepared/tested locally; production Groups remains pending, no mock fallback |
| T-022 | IN_PROGRESS | Production day/week/month sessions wired to deployed RPC; server initial date, Cairo DST display, ranges/empty-state tests pass; hosted/web/device acceptance pending |
| T-023 | NOT_STARTED | Detailed attendance read contract/UI still needed; no teacher marking controls |
| T-024 | IN_PROGRESS | Reason/confirmation, duplicate guard, secure RPC, no automatic mutation retry, cache invalidation and refreshed status tested with synthetic transport; production action activation awaits named-session contract, actor/history display and hosted acceptance |
| T-030..T-034 | NOT_STARTED | Live student/academic/attendance/finance/notes |
| T-040..T-042 | NOT_STARTED | Live secretaries/notifications and design polish |
| T-050..T-054 | NOT_STARTED | Full integration/security/performance/signing/cross-app acceptance |
| T-LATER-01..03 | DEFERRED | QR scanning, push, public stores/billing |

## Hosted milestone (approved in chat)

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

## Actual verification so far

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

Approve or decline the additive development-only read migration reviewed in
`docs/TEACHER_READ_CHANGE_REVIEW.md`. After approval, verify remote preflight,
deploy only the new reviewed version, verify grants/tenant behavior, pin the hash,
and wire overview attendance counters and group browsing. No deployment is implied
by the existing approval of versions 001..009. Continue detailed attendance/student
contracts and live UI in dependency order. T-012 still needs full visual composition,
physical TalkBack and safe-area acceptance; support configuration remains pending
without blocking unrelated work. Backup/restore, monitoring, Android/iOS device QA,
release signing and Secretary cross-app acceptance remain open pilot gates.
