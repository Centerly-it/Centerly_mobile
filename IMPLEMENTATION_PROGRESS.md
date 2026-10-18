# Centerly implementation progress

Updated: 2026-10-18 (Africa/Cairo). Current phase: T0 audit/remediation plus
owner-authorized local shared backend foundation. Application is still a prototype;
not release-ready, not connected to Supabase. No hosted changes or publication.

## Task ledger

| ID | Status | Evidence / remaining acceptance |
|---|---|---|
| T-001 | DONE | Complete rules/plan/PRD read, source inventory, live Figma metadata, SCREEN_MAP, doctor/pub/analyze/test/debug build executed |
| T-002 | IN_PROGRESS | ADR-001 chooses incremental repair; runtime screenshot preservation comparison still needed |
| T-003 | IN_PROGRESS | Analyzer/format/test baseline repaired, env example; CI, variants and reproducible clean-checkout verification pending |
| T-010 | IN_PROGRESS | Owner-authorized canonical SQL here, 9 migrations + local tests; no deployed compatibility pin or generated Dart models |
| T-011..T-013 | NOT_STARTED | Real Supabase auth, teacher guards, app shell and typed repositories |
| T-020..T-024 | NOT_STARTED | Live dashboard/groups/sessions/attendance/cancellation |
| T-030..T-034 | NOT_STARTED | Live student/academic/attendance/finance/notes |
| T-040..T-042 | NOT_STARTED | Live secretaries/notifications and design QA |
| T-050..T-054 | NOT_STARTED | Integration/security/performance/signing/cross-app acceptance |
| T-LATER-01..03 | DEFERRED | QR scanning, push, public stores/billing |

Task IDs refer to CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md. Backend extensions are
not evidence that mobile feature acceptance criteria are met. A local commit is
created for this slice; inspect `git log -1` for its exact SHA (no self-referential SHA).
User-supplied plan was already untracked and is intentionally left unchanged.

## Changes and reuse

- Reused teacher screens, Cairo font, blue palette, translation files, GoRouter,
  existing Cubit/data/repository structure and core components. No blank app/rebuild.
- Fixed narrow-width dashboard title/header/payment-summary and group schedule
  layout; replaced infinite-width themed button minima so buttons can work in rows.
- Replaced stale widget assertions with localized real-theme navigation tests in
  Arabic/English at 360x800; fixed four analyzer findings. Applied required Dart
  formatting across existing source (most changed files are formatting only).
- Removed verbose Dio request/response/authorization logging and BLoC payload logs.
- Added 9 SQL migrations: 18 tables, composite tenant-safe FKs, RLS/default denial,
  live account/subscription checks, secretary-only writes, hardened business RPCs,
  attendance audit, immutable money ledger, idempotency and row locking.
- Added on-demand Cairo-aware generation, bounded reads/dashboard, note conflict
  protection, removal requests and notifications. Existing occurrences preserved.
- Added embedded PostgreSQL harness, two-tenant fixtures and 64 assertions.
- Added .env.example and ignored local env/node_modules/CLI/Kotlin artifacts.
- Flutter automatically added Android Kotlin compatibility flags during debug build.

Files: `supabase/migrations/202610180001_identity.sql` through
`202610180009_read_contract.sql`; `supabase/tests/{run,schedule,security}.mjs`,
`fixtures.sql`, npm lock/package files, `supabase/{README,contracts}.md`, seed.sql;
`docs/{SCREEN_MAP,DECISIONS,SHARED_BACKEND_CONTRACT,BACKEND_COMPAT,PROGRESS}.md`;
this ledger, .gitignore, .env.example; lib/ formatting plus semantic fixes above;
test/widget_test.dart and android/gradle.properties.

## Tests actually executed

- Flutter 3.44.2 stable, Dart 3.12.2; `flutter doctor -v`: Android licenses partly
  unaccepted, Windows/Chrome available, Android device detected; no device install.
- `flutter pub get`: PASS; existing lock versions retained, no dependency upgrades.
- Baseline: analyzer 4 findings; original widget test failed; format drift 40 files.
- `dart format .`: executed; subsequent format check: 128 files, 0 changed.
- `flutter analyze --no-pub`: PASS, no issues.
- `flutter test --no-pub`: PASS, 2 localized navigation tests.
- `node supabase/tests/run.mjs`: PASS, all 9 migrations applied, 64 SQL assertions.
- `flutter build apk --debug`: PASS (initial build took ~683 seconds).
- Final code `flutter build apk --debug --no-pub`: PASS (33.8 seconds).
- No hosted Auth/REST, independent connection races, staging integration, iOS build,
  device performance, accessibility or runtime screenshot comparison claimed.

## Backend status and blockers

Canonical temporary ownership explicitly authorized by user (ADR-002). Local only.
Docker/Supabase CLI absent; PGlite uses actual PostgreSQL with synthetic Auth shim.
Remaining foundation acceptance: real Supabase Auth provisioning/seed workflow,
schedule revision/closing RPC, capacity/seat validation, invoice void RPC, richer
profile/report contracts, complete timezone/DST and independent-concurrency tests.
No service-role credentials, Supabase URL/public key or approved support URL supplied.
Disable public signup in Supabase configuration before pilot. Backup/restore pending.

Known prototype risks still present: fake login/role selector/cache guards, public
registration routes, obsolete attendance lock/countdown in existing mock screens,
teacher finance entering secretary write UI, mock operational mutations. Do not
use this build with real student/financial data. SQL does not implement timed locks.

## Exact next task

Finish T-002 runtime screenshot comparison and T-003 CI/reproducible setup, then
complete T-010 local Supabase compatibility verification/provisioning. Implement
T-011 by replacing fake login and editable role selection with Supabase password
auth and database-backed get_current_profile(), clearing stale demo sessions,
teacher-only guards, configured support channel and inactive-account handling.
Continue through T-013 typed repositories before wiring teacher features.
