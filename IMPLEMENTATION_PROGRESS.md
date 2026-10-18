# Centerly implementation progress

Updated: 2026-10-18 (Africa/Cairo). Continuing from e1312a2.
Current phase: T0 baseline completion / T1 live Supabase authentication.
Development backend is deployed with explicit owner approval; not production ready.

## Task ledger

| ID | Status | Evidence / remaining acceptance |
|---|---|---|
| T-001 | DONE | Original audit and screen map retained |
| T-002 | DONE | ADR-001, actual Arabic home/groups/sessions captures, visual comparison in VISUAL_PRESERVATION.md; original Figma PNGs preserved |
| T-003 | IN_PROGRESS | Pinned setup, GitHub CI, codegen, env example, format/analyzer/tests, debug/profile builds; final clean-checkout replay pending |
| T-010 | DONE (owner override) | Canonical schema here, nine hosted versions verified, deployed hashes pinned, shared contracts and typed auth profile tested |
| T-011 | IN_PROGRESS | Real SDK auth, secure storage, guards, logout/refresh/role checks implemented; native verification and approved support channel pending |
| T-012 | NOT_STARTED | Existing design reused; full live shell/accessibility QA pending |
| T-013 | IN_PROGRESS | Auth repository and initial dashboard RPC repository; full typed operational models/pagination/error handling pending |
| T-020..T-024 | NOT_COMPLETE | Initial live count/financial read surface only; full dashboard and schedule/attendance modules pending |
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
- Debug APK with public hosted config: PASS; profile APK: PASS (before removal of
  unused Firebase packages; final clean-checkout rebuild pending).
- Local PostgreSQL/PGlite: 64 authorization/business assertions PASS.
- Independent PostgreSQL 17.10 connections: 11 race assertions PASS.
- Hosted Auth/REST/RPC: 36 fixture-only assertions PASS (including real concurrent
  payment/cancellation calls, tenant denial and inactive access).
- Actual hosted Dart SDK: teacher login/profile/refresh/logout, secretary rejection
  and invalid credentials PASS. Local unit tests cover secure storage, stale results,
  duplicate taps, errors and profile validation. Final baseline suite rerun pending.
- Native Windows attempt first stalled on unused Firebase SDK download; retried
  after removing unused packages. Android device disconnected; no Android device
  installation or iOS native verification claimed.
- Remote GitHub CI has not been pushed or executed; clean-checkout local replay pending.

## Files and decisions

See git diff / local commits for full file list: .github/workflows/verify.yml,
docs/{SETUP,VISUAL_PRESERVATION,BACKEND_REVIEW,HOSTED_CHANGE_REVIEW,DEVELOPMENT_ACCOUNTS}.md,
lib/app and core auth/config/router, auth domain/data/presentation, initial dashboard,
translations, pubspec/lock, Android manifest, supabase config/admin/tests/manifest,
test auth/visual helpers and integration_test/auth_session_test.dart.
The two original migration fixes occurred before first deployment; deployed files
are now immutable and hash-checked. No further schema changes are approved implicitly.

## Exact next task / blockers

Finish T-003 clean-checkout verification and native T-011 test; obtain real support
URL (question pending). Then finish T-013 typed repositories and T-012 live shell
using retained design before implementing full T-020 dashboard/schedule modules.
Backups/restore, remaining backend operational contracts, Android/iOS device QA,
release signing and Secretary cross-app acceptance remain open release gates.
