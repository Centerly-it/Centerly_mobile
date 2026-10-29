# Centerly — Codex continuity handoff

Snapshot: **2026-10-28**. Read before proposing changes. This consolidates the current state of BOTH projects, product decisions, deployments and operational limits. Current source/manifests and fresh verification outrank dated reports. It is repository knowledge, not transferred chat memory; the human owner's latest instruction still takes precedence.

## 1. Repositories and ownership

| Project   | Repository                                          | Role                                                                                         |
| --------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Teacher   | https://github.com/Centerly-it/Centerly_mobile      | Flutter teacher Android app; canonical backend migrations/tests/admin tooling                |
| Secretary | https://github.com/atamer7112002/Centerly_secretary | React/TypeScript/Vite daily-operation website using the same backend                         |
| Downloads | https://github.com/Centerly-it/Centerly-releases    | Public production APK binaries only; never source, environments, accounts or signing secrets |

Both application repositories use **main**. Typical sibling folders: `D:/ahmedtamer/Centerly_mobile` and `D:/ahmedtamer/Centerly_secretary`. Discover actual paths on another computer. Check status/fetch before editing, preserve owner work and never force-push. Codex-account access to external connectors must be checked; Windows Git/provider credentials are separate from chat history.

Teacher owns `supabase/migrations`, `supabase/schema-manifest.json`, `supabase/production-schema-manifest.json`. Secretary mirrors `docs/backend-baseline.json`, `docs/backend-production-baseline.json` and pins an available Teacher revision in `docs/canonical-revision.txt`. There is ONE shared schema in two isolated environments, not a second Secretary backend. Never replay existing versions, edit deployed SQL or copy fixtures into production.

## 2. Current environments and public endpoints

| Channel | Project       | Public ref           |
| ------- | ------------- | -------------------- |
| dev     | centerly-dev  | yfeubomyglmhuwizaqoj |
| prod    | centerly-prod | ohhwccwwwxfmwpfypfyf |

The former shared-dev-as-production decision was replaced on 27 October by this physical split. Current manifests pin **40 migrations through `202610280001_group_billing_modes.sql`**. Last migration-40 deployment evidence compared all bodies/catalog: 119 function signatures, 18 tables, 30 RLS policies, 35 triggers. That is recorded deployment evidence, not a new hosted check performed by reading this file. Actual manifests/history govern future changes.

- Public Secretary site: https://centerly-secretary.pages.dev — targets **prod**. Dev synthetic accounts belong on the local dev site, not this public login.
- Cloudflare Pages project `centerly-secretary`, production branch `main`, **direct upload**. Git push alone does not deploy.
- Current signed prod APK: **1.0.0+1**, application ID **com.centerly.teacher**. Download: https://github.com/Centerly-it/Centerly-releases/releases/download/v1.0.0-build.1/centerly-1.0.0-1.apk . SHA256 `562d36ed8700132bdc00aa04e7e20c8f1523b4906c7e2226e0d47d52ad94630e`.
- Last update-policy site deployment `095cd122` matched live JSON/no-store headers/build identity/six entry assets. Subsequent docs-only commits do not imply new binaries or web deployments.

Prod was created empty without copying test accounts/business rows. Migration-40 evidence still reported zero production accounts/rows. **Do not assume it remains empty after owner provisioning without a read-only check.** A downloadable prod APK does not create real accounts or prove real-data acceptance.

## 3. Owner working preferences and authorization boundaries

Production account update (2026-10-29): the owner explicitly authorized one Teacher account for Release/update testing. Auth creation plus an active Teacher/subscription profile completed and actual password Auth/get_current_profile verified the same teacher/tenant. The verification session was signed out. Private identity registry: Teacher ignored .env.production-owner-account.json. No secretary/business fixtures were created. Earlier empty-production observations are historical; do not recreate/reset this account or assume production is empty. Physical-device/update acceptance remains pending.

- Use concise Egyptian Arabic, implement requested work and verify it. Give meaningful progress on long tasks. Ask only for a material missing decision/authorization, not repeated routine confirmation.
- Preserve clean Arabic-first/RTL, Cairo typography and blue/green Centerly identity. Reuse existing widgets/helpers/architecture. Do not redesign or add optional features unprompted. Localize AR/EN. Secretary instructions use masculine Arabic: اختر، افتح، تقدر، راجع. Synthetic examples use clear Arabic names أحمد/محمد/عبد الرحمن.
- Standing delivery instruction: commit/push validated own changes to **main** in affected repositories; deploy actual website/runtime/public-policy changes to the existing Pages project after checks. Docs-only cleanup does not require an unchanged website redeploy.
- Preserve unknown owner files such as Secretary `output/` and temporary capture work. Do not stage unrelated files just to make status clean.
- Do not install APKs/change phone settings, create real accounts/change Auth, reset passwords, seed/reset hosted data, enable paid resources, send messages, or raise a mandatory APK minimum without the relevant owner direction. A prior bounded fixture approval is not a general permission to mutate data.
- Separate local unit/SQL-role simulation, SDK/browser fixtures, actual hosted authenticated checks and physical-device evidence. Never claim a manual/device pass that did not happen.

## 4. Product decisions — do not restore removed complexity

### Secretary daily work

The secretary is an operator, not a teacher income-dashboard user. Prioritize today's sessions/take attendance, collection, students, groups/timetable and notifications. Header shows the owning teacher and current secretary. Extra history/record screens exist under More.

- New student requires choosing an owned group; if none exist, create a group first. Educational level/stage and group-capacity controls were removed from forms. Old DB columns may remain for compatibility: do not drop them or restore the UI unprompted.
- Group schedules are mandatory, support multiple weekdays and AM/PM selection. Recurring timetable UI has no effective-date field and displays ALL teacher group appointments simply. Edit an existing group's schedule rather than duplicating Add appointment controls.
- Separate Create Session selects group/date/time and billing: included in subscription or extra charge. No duplicate free/included choices. Ended depends on actual end time; cancelled is separate.
- Attendance is direct: **no attendance-finalization/approval button**, and no automatic unmarked-to-absent conversion.
- Group filters use a dropdown without a second search field; financial student-name search is one field. Hide prominent invoice/receipt IDs; payment time and understandable amounts matter.
- Student/group deletion/archive has repeated confirmation and retains payments, attendance and audit. Never implement physical SQL deletion just to simplify the UI.
- Exams/assignments select a student and only their eligible memberships; no invented group. Additional materials are a named-price explicit charge with retry-safe collection.
- Teacher cancellation/events appear in in-app database notifications/polling; this is not proof of native push/FCM delivery.

### Billing and immutable ledger

Monthly periods start on the student's **enrollment anniversary**, not the first day of the calendar month. Existing enrollment/refresh RPCs create dues idempotently/on demand; do not invent a hosted cron. Initial group materials are one-time; later materials are explicit separate charges.

Migration 40 adds **new-group-only monthly/per-session billing**. Do not convert existing groups. Per-session price snapshots and eligible sessions/enrollments drive charges. Attendance is direct, but a separate explicit **financial review** retains present charges and exempts eligible unpaid nonpresent amounts. Already collected cash remains, with settlement flagged; corrections are explicit/audited. There is no automatic wallet/refund or fictional cash refund, and this does not reintroduce attendance finalization. Read `docs/BILLING_MODES_RELEASE.md`, canonical migration and tests for exact APIs. Hosted per-session fixture/mutation acceptance remains separately gated.

Use exact decimal EGP/cents, not binary floating arithmetic for authoritative balances. Distinguish original invoice face amount, signed payment-minus-reversal ledger net and payable balance. Void payable is zero while original amount/history remain. Editing visible paid/due amounts uses scoped audited APIs, not UPDATE/DELETE of immutable payment records. Preserve stable mutation IDs after uncertain outcomes; never automatically retry writes.

### Teacher experience

- Tabs: Home, Sessions, Groups, Students, Finance. Today's group count is distinct noncancelled groups with today's sessions, not all teacher groups.
- Finance label: **المفترض تحصيله لهذا الشهر**. No noisy due-invoice-count subtitle. Movement controls/list scroll together; styling follows the app identity.
- Owning teacher can read archived students' attendance, academics, notes and finance. Archived notes are read-only. Operational writes are restricted; specifically supported audited historical financial settlement/reversal remains possible where the backend permits it.
- QR functionality was removed. Guardian/student call/WhatsApp actions open the contact destination; they never send messages automatically. Support is also inside the authenticated ⋮ menu using `https://wa.me/201028684980`.
- Student default avatar is the owner-approved blue profile asset. Finance card has teacher name right, Centerly left. Secretary access action is centered in its row.
- **Cold process start opens Home; ordinary background/resume retains screen/tab/draft.** `WorkspaceSelection` is process memory reset in main. Never reset navigation on every resume. Transient network revalidation keeps verified UI; confirmed denial removes it.
- Android splash is explicitly white/light for normal/night/Android 12, force-dark disabled. Approved icon: `assets/branding/centerly-launcher-v2-approved.png`; generator `tools/generate_android_launcher.ps1`. Native resource/flavor changes need Stop+Run/rebuild, not Hot Reload.

## 5. Accounts, isolation and access controls

Supabase Auth and server `get_current_profile` are authoritative. Role/tenant/status/subscription come from DB profiles/private helpers, not JWT metadata, selected-role parameters, cached display data or UI filters. Keep tenant-scoped RPCs, RLS, grants, composite ownership constraints and triggers. Clear caches/intents on account changes/confirmed denial. Backend-specific secure auth storage and Android flavor sandboxes remain separate.

Teacher immediately stops an OWNED secretary after confirmation using `deactivate_secretary(uuid)`; the same card restores access using `reactivate_secretary(uuid)`. Preserve Auth users/passwords/history. Deactivation resolves an old pending removal request atomically. Reactivation requires active subscribed ownership and free secretary seats, with locking, idempotency and one audit event. Legacy request-removal RPC remains for compatibility; never restore an operator-waiting request UI. Reactivated staff sign in again.

Subscription suspension is **manual admin**, not automatic monthly expiry. Change only `public.teachers.subscription_status` inactive/active. Inactive blocks teacher and linked secretaries, clears confirmed-denied local sessions and displays **راجع دفع الاشتراك مع الإدارة.** Detection: next rejected request, focus/foreground or ~60-second connected profile check. Offline clients cannot immediately receive a server decision. Renewal does not reactivate a separately deactivated secretary. Never delete Auth users/reset passwords for missed payments. Public signup stays disabled; real provisioning needs a separate authorized Auth user plus matching teacher/secretary profile, teacher link and seats.

## 6. Signed APK updates — critical continuity

Full runbook: `docs/ANDROID_UPDATES.md`. Secretary hosts `/updates/android-prod.json` and `/updates/android-dev.json` with no-store. Prod initially latest=1/minimum=1; dev disabled. First APK does not request an update to itself. No higher-version forced rollout or real-device upgrade was claimed.

`lib/features/updates/` checks startup/resume with a 15-minute cooldown. A known required cached policy blocks offline; an unknown policy-service outage alone does not block. Optional offers allow Later; mandatory blocks Back/outside dismissal. User initiates bounded private-cache Range download, with safe restart when needed. Dart/native SHA256/size checks, package, signer, exact advertised/higher build and SDK checks precede the Android installer. User still confirms installation and may need Install Unknown Apps permission. Installer launch is NOT success proof; cancellation retains retry/gate. No update-related sign-out or data reset.

Prod public package: `com.centerly.teacher`; dev: `com.centerly.teacher.dev` / Centerly Dev. Internal namespace/Dart package may still say com.example/centrally; do not rename public identity to match them. Old com.example.centrally prototypes are different apps; owner confirmed no production APK had been sent to teachers before choosing final identity.

Approved signer pin: `config/android-release-identity.json`, SHA256 `00ce36634be7cd72ec0feab2c068e0b9ed35b468580c3a2de3da539884eb2b4f`. **Never regenerate/replace this key on another account/computer.** Restore it. Preparation refuses a new key once the pin exists; Gradle/artifact checks reject a different certificate. Signature rotation is intentionally unsupported.

Private ignored local files: `android/key.properties`, `android/keystore/centerly-release.jks`, `build/release-private/centerly-signing-backup.zip`. They are owner/SYSTEM protected. Owner must keep a secure off-computer copy. Never attach/publish the ZIP; it contains secrets. Restore layout is in the runbook. Losing the key prevents ordinary updates to distributed copies.

Future release: raise build/version, reuse package/key, inspect APK/signer/decompressed credential scan, publish binary FIRST, anonymously hash it, then publish policy LAST. Raise minimum only after owner's physical upgrade acceptance (`--owner-tested`); never self-assert that. Emergency lower/disable withdraws a requirement; a binary fix uses a NEW higher build. Never overwrite published APKs or require data-erasing downgrade.

## 7. Configuration and secure transfer

Teacher ignored profiles: `.env.dev.json`, `.env.prod.json`; public templates: `config/env.dev.example.json`, `config/env.prod.example.json`. `.env.local.json` remains a legacy source for old local tools. Old shared `env.production.json` is not the current launcher. Secretary uses `.env.development.local` / `.env.production.local`; owner scripts read sibling Teacher profiles. Builds reject prod/dev/flavor mismatch, fixtures and privileged client keys. Only public publishable/anon keys enter clients.

Existing synthetic accounts live in Teacher ignored `.env.development-accounts.json`: teacher-a/teacher-b/secretary-a/secretary-b. Verify file existence securely on a new machine; they were available for previous read tests. Never print credentials or provision/reset replacements merely because a file is absent. Private `.env.production-admin.json`, DB/service-role passwords, provider/Git credentials and signing keys never enter client bundles, logs, source or chat. Same-PC account switching does not require deleting local files; new checkout requires owner-controlled secure transfer. Git cannot recover ignored secrets.

Never rerun **SEC27**, old reset/provision/environment-creation/deployment, fixture acceptance or finance cleanup scripts. Those approvals were bounded/completed. Reconcile existing retained records instead of recreating them. Old `supabase/admin` / Secretary scripts are not onboarding steps. New hosted synthetic writes need an explicit bounded scope; disposable PGlite/native Postgres tests need no hosted writes.

## 8. Diagnostics, verification and remaining work

Dev debug console filter `[Centerly]`: real Supabase endpoint/status/duration, response shape/count, request ID, recognized code, safe error type/project source; cache hits explicit. No payloads/query values/tokens/credentials/student data/SQL details. Prod console diagnostics disabled. Optional Sentry accepts sanitized metadata only (no automatic request/user context, replay/screenshots/tracing; 20/hour cap). Sending requires owner `CENTERLY_SENTRY_DSN` in private prod config; remote delivery is not proven without it.

Setup baseline: Flutter 3.44.2/Dart 3.12.2, Java 17, Android SDK 36/build tools, Node 22+, committed lockfiles. Do not upgrade dependencies unprompted. Generated Flutter code stays tracked. Native PostgreSQL tests share port 55439: run serially. Flutter pub/test/build share generated plugin registration: run serially. Web check/build/deploy share dist: run serially. Prod Release transition uses the full Flutter build with pub regeneration, NOT --no-pub inherited from dev/test.

Latest recorded updater evidence: **354 Flutter passed / 2 conditional skipped**, clean analyzer, **8 JVM native policy/digest tests**, signed Release/550-entry credential+preview scan, anonymous public APK hash. Website: 82 baseline + 3 policy tests; live metadata/headers/build/six assets matched. These are checkpoints, not automatic proof on every future revision. SQL-role simulation is not hosted Auth/PostgREST, SDK/browser fixtures are not a real phone, local checks are not remote CI. Check actual CI status.

Owner acceptance/config still needed: one-device signed upgrade preserving state; secure off-computer key backup; separately approved real onboarding; hosted per-session write acceptance (proposed scope NOT executed); provider DB/Auth/Storage recovery drill; optional Sentry/alerts delivery; privacy/support approval. These do not block local synthetic dev testing. Do not claim real-student-data launch acceptance merely because the app builds/downloads.

See `docs/OPERATIONS_AND_RECOVERY.md`. Retained old evidence is for tests/hash/reconciliation, not live instructions. Deleted old docs are recoverable from pre-cleanup Git: Teacher `51c994c`, Secretary `8113adb`. Never execute an old plan just because it exists in history.

## 9. Teacher code map and commands

Follow `agent_rules.md`. Main path: `lib/main.dart`, `lib/app/bootstrap_auth.dart`, `lib/app/session_lifecycle.dart`, `lib/core/router/app_router.dart`, `lib/core/config/app_config.dart`, `lib/core/diagnostics/`, `lib/screens/teacher/teacher_workspace.dart`, `workspace_selection.dart`, `lib/features/{auth,dashboard,groups,students,sessions,finances,notes,secretaries,notifications,updates}/`. Keep GetIt/Cubit/GoRouter/shared widgets. Legacy/mock screens remain; inspect connected navigation and PreviewMode before treating them as production.

```powershell
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run --flavor dev --dart-define-from-file=.env.dev.json
flutter run --flavor prod --dart-define-from-file=.env.prod.json
npm ci --prefix supabase/tests
node supabase/tests/check_manifest.mjs
node supabase/tests/run.mjs
```

Use the APK runbook for signed distribution, not a debug build. Actual define-file tests use matching flavor. Do not auto-install on the connected Redmi. Hot Reload is only for changes that do not alter native/build-time config.

## 10. Secretary code map and commands

Entry: `src/main.tsx`, `src/app/{auth,Shell,WorkspaceNav,IdentityNames}.tsx`; pages/forms `src/features/`; RPC/model/validation/runtime config/localization `src/lib/`; shared UI `src/components/`. Preserve TanStack Query, stable mutation intents and reconciliation. Main routes: `/`, `/records/students`, `/records/groups`, `/calendar`, `/sessions/new`, `/records/invoices`, `/records/notifications`; additional histories under More.

```powershell
npm ci
npm run dev:dev
# http://127.0.0.1:5173 — synthetic dev backend
npm run dev:prod
# http://127.0.0.1:5174 — production backend
npm run check
npm run prepare:backend
npm run verify:backend
npm run test:teacher
npm run test:concurrency
# Only after website/public-policy changes pass checks:
npm run deploy:pages
```

`npm run dev:fixtures` is a disposable SQL/Auth-shim browser harness, not hosted acceptance. `scripts/canonical.mjs` verifies migration hashes/resolves Teacher (or `CENTERLY_CANONICAL_REPO`); `.backend-canonical` is an ignored test copy. Never ship fixture mode or treat its login as Supabase credentials. Align baseline JSONs/canonical-revision after shared changes. Preserve owner `output/`; it is not web source. See `docs/CLOUDFLARE_PAGES.md` in Secretary and `docs/README.md` in each repository for the active document map.
