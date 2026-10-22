# Pilot operations and owner script

22 October 2026. Development is `centerly-dev` / `yfeubomyglmhuwizaqoj`. It contains synthetic records and retained financial/audit history. It must remain development. No hosted configuration change, publication, real data entry or paid resource creation is authorized by this document.

## Run both apps locally

Secretary: Node 24.12.0, locked npm dependencies. `.env.local` has been prepared locally with only the existing development URL/public key, `VITE_APP_ENV=development` and `VITE_SECRETARY_EXTENSION=true`; it is ignored. From `D:\ahmedtamer\Centerly_secretary`:

```powershell
npm ci
npm run check
npm run dev -- --port 4173
```

Open `http://127.0.0.1:4173`; enter synthetic credentials from the private account file manually. Never paste credentials into terminal commands or save browser storage state. Routes reload through Vite; deployed SPA routing requires the prepared server configuration.

Teacher: Flutter 3.44.2/Dart 3.12.2, locked pub dependencies. From `D:\ahmedtamer\Centerly_mobile`:

```powershell
flutter pub get --enforce-lockfile
flutter run -d windows --dart-define-from-file=.env.local.json --dart-define=CENTERLY_UI_PREVIEW=false --dart-define=CENTERLY_FINANCE_MOVEMENT_FILTERS=true
flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json --dart-define=CENTERLY_UI_PREVIEW=false --dart-define=CENTERLY_FINANCE_MOVEMENT_FILTERS=true
```

Only public configuration belongs in `.env.local.json`. The Android debug APK is an internal development artifact, not signed pilot distribution. Do not distribute native test-runner executables. The Windows native integration test loads account credentials from a runtime file, never dart-defines:

```powershell
$env:CENTERLY_TEST_ACCOUNT_FILE='D:\ahmedtamer\Centerly_mobile\.env.development-accounts.json'
flutter test integration_test/auth_session_test.dart -d windows --no-pub --dart-define-from-file=.env.local.json --dart-define=CENTERLY_UI_PREVIEW=false
flutter test test/hosted_auth_integration_test.dart --dart-define=RUN_HOSTED_AUTH_TESTS=true
```

Secretary read-only hosted/browser test: `node scripts/pilot-readonly.mjs` (install Chromium with `npx playwright install chromium`, or set `CENTERLY_BROWSER_CHANNEL=chrome`). It logs into only the four known accounts, verifies membership before reads, and logs out its sessions. It has zero business writes and creates no traces/video/storage exports. Sanitized report: `.local/pilot-readonly.json`.

Backend local tests: `npm run verify:backend`; `node scripts/prepare-canonical.mjs`; `npm run test:teacher`; `npm run test:browser`. From Teacher: `node supabase/admin/pilot_baseline.mjs` performs read-only fresh hosted verification; `node supabase/tests/pilot_recovery.mjs` performs only the isolated local snapshot restore. Run native PostgreSQL suites sequentially; they share port 55439.

## Separate production strategy and release checklist

1. Owner selects a separate Supabase project/environment, region, operator, costs and backup service. Recommend a dedicated production project with no fixture accounts/records. Creation/configuration and any paid plan require approval.
2. Trusted operator applies the exact canonical 27 migrations to the NEW empty production project after an approved review. Do not seed fixtures or replay any migration in development. Pin exact hashes/history and compare catalog/grants/RLS; signup/admin provisioning policy requires explicit configuration approval. Provision real teacher/secretary identities only after permission and tenant/seat checks. Never ship service-role keys.
3. Set public release values using `deploy/public-release.example.json`. Save the actual public-only values in an ignored private release JSON; run `node scripts/release-preflight.mjs PATH`. Export its VITE fields into the build process, then `npm ci` and `npm run build`. Default `npm run build` may produce an unconfigured development artifact; only a validated separate-production configuration is release-eligible. The production app refuses the fixture backend. Run `node scripts/scan-artifacts.mjs dist` locally, then record artifact hash and source revisions.
4. Teacher production config must set `APP_ENV=production`, HTTPS production URL/public key, approved support URL, preview false and contract flags true. Production preview stays disabled even in a debug build. Android release requires `-PCENTERLY_APPLICATION_ID=OWNER_APPROVED_ID` as a Gradle project property (or `ORG_GRADLE_PROJECT_CENTERLY_APPLICATION_ID`) and private `android/key.properties`: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. Store the keystore outside Git; release now fails instead of silently using debug signing. Recommend `com.centerly.teacher`, subject to owner registration checks. iOS needs an owner-approved bundle ID, Apple team, distribution profile/certificate and macOS/Xcode; no iOS build/signing is claimed on Windows.
5. Render `deploy/nginx.conf.template` with only validated HTTPS Supabase origin and DNS hostname. Serve built files from immutable version directories via a controlled `current` symlink/junction behind approved TLS termination. Verify `nginx -t`, HTTPS certificate, deep-link reload, missing asset 404, CSP/connect-src, frame denial, referrer, HSTS, permissions policy, no dotfiles and no API/session caching. No nginx runtime is installed here; syntax/header deployment verification is pending on the chosen host. If another host is chosen, translate and verify the same routing/header policy there.
6. Run connected acceptance on a separate staging clone with approved synthetic fixtures, then production smoke reads under operator supervision. No public publication or real record writes until explicit approval. Run remote CI only after canonical commit is reachable and access is available; local green is not remote CI evidence.
7. Record version/build/hash, migration manifest, public environment fingerprint, operator, device signoffs, privacy/support URLs, backup/drill IDs and release approval. Distribute privately to the one pilot teacher only after gates close; store publication requires separate permission.

## Backup, recovery and incident handling

Recommend owner-approved targets of RPO <=24 hours and RTO <=4 hours for the pilot; these are proposals, not achieved hosted guarantees. Name a primary and backup operator. Keep encrypted backups outside the application host with restricted access and audited downloads; agree retention/deletion obligations before real student data. No account passwords/service keys belong in backup evidence or client logs.

Before first real record: operator takes a provider-supported database backup and separately inventories Auth users/config, role grants, storage objects, private signing material and environment settings. A database-only export may not recover all services. Obtain an isolated target of matching PostgreSQL/service versions, restore there, and check 27 migration hashes, complete catalog/grants/RLS, row counts, exact invoice/payment/reversal totals, audit/attendance history, two-tenant denial, read/write workflows and app reconnect. Do not repoint clients until owner signoff. Record elapsed recovery, lost-data interval and encrypted backup ID. Deactivate/dispose isolated recovered identities only under separate approval; never send messages from the drill environment.

The included PGlite drill serializes a binary synthetic snapshot to disk and restores a separate database, comparing ten complete tables, full catalog, exact reversed balance and foreign-tenant denial. It does not validate Supabase Auth/storage/provider restore or native pg_dump; native dump tools are absent. Production provider recovery remains a release gate.

Monitor Auth errors, availability, RPC errors/latency, storage/database growth, backup freshness, denied-access spikes, duplicate financial intent/conflict rates and client crashes. Configure a named private alert recipient after owner approval; do not log names, contact numbers, tokens, passwords or note content. Recommend 5-minute availability checks and a daily operator review during the pilot. No external monitor or notification channel was configured.

Incident: pause further financial/attendance mutations, record time/source versions/request IDs without PII, preserve original idempotency keys and audit evidence, assign operator, assess tenant/data exposure, and reconcile uncertain writes by original key before any retry. Restrict access through approved operator controls only. Do not reset accounts or delete ledger/history. Escalate suspected exposure to the owner and follow their approved notification/legal process. No automated external messages are sent.

Client rollback: deploy the previous immutable compatible web build / signed mobile version, invalidate browser shell caches, revalidate tenant/Auth and verify core reads. Database changes use reviewed additive forward fixes; never edit deployed migration bodies or roll back by deleting history. A backup restore is a separate owner-approved recovery event with a data-loss/reconciliation plan. Reconcile writes around the incident before reopening.

## Real-teacher onboarding and concise owner test

Before onboarding, select one teacher and secretary, document consent/authority and data-entry permission, verified identities/tenant/subscription/seats, named support/operator, private distribution method, retention/privacy notice and recovery signoff. Send invitations or reset passwords only on explicit instruction. Do not reuse synthetic accounts for the real teacher.

On approved synthetic staging fixtures: (1) log in both roles and restore/reopen; (2) create/edit student/group and enroll, deny overflow; (3) generate schedules twice, verify Cairo times and retained history; (4) mark before/during/after, leave one unmarked, manually finalize/correct with reason, verify Teacher refresh/audit; (5) enter missing/zero exam and assignment, verify Teacher report; (6) invoice 100.10, collect 40.05 then concurrent bounded remainder, reconcile lost result with original key, reverse and compare exact totals/actors; (7) verify each notification's recipient/actor/event; (8) exercise Teacher note conflict/draft and removal request without deactivation only within separately approved bounds; (9) cancel eligible session, retain attendance in both; (10) log out offline, switch tenants, verify no old data, then check owner devices/accessibility/contact handlers. Record PASS/FAIL and screenshots without credentials. No API-only substitution for these UI actions.

For the real pilot, begin with read-only orientation. Enter real students/financial records only after the explicit real-data approval and completed gates. Provide a one-page privacy notice covering operator identity/contact, purpose/data categories, role access, processors/hosting region, retention/deletion requests, incident/support channels and account recovery. Owner/legal review must supply final claims and contact details; do not publish placeholder text.

## One bundled owner decision list

- Approve or decline the existing precise SEC27 synthetic extension in `HOSTED_FIXTURE_ACCEPTANCE_SCOPE.md`, including its guarded fixture-only void cleanup. Recommend approve exactly those bounds, no new accounts/keys. The consolidated proposal, including the Teacher-action addendum, remains unexecuted. The same single extension now includes the bounded note-conflict/request-only addendum; approve the whole consolidated package once or execute none.
- Choose separate production project/region/budget and name operator/backup operator; recommend dedicated production plus an isolated restore target. Approve resource/configuration/migration work only after reviewing exact targets and costs.
- Confirm Android app ID and keystore custody, iOS bundle/team/private distribution, web hostname/TLS host, support/privacy URLs and privacy/retention owner. Recommend private Android pilot first if iOS credentials/devices are unavailable.
- Supply physical Android/iOS devices and owner test signoff; approve backup targets/RPO/RTO and provider restore drill. Confirm the remote push/CI/publication step separately. No production rollout, account changes or real-data entry is inferred from this preparation.
