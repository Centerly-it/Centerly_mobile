# Reproducible setup (T-003)

Pinned baseline: Flutter 3.44.2 stable, Dart 3.12.2, Java 17, Node 22+.
Current Windows MVP build uses that baseline successfully with Gradle 8.14,
AGP 8.11.1 and Kotlin 2.2.20. The restored lock resolutions match the pinned SDK
(intl .20.2, matcher .12.19, meta 1.18.0, test_api .7.11, vector_math 2.2.0).
The Mac 3.47.2 descriptions below are historical, not the current required SDK.
Use the committed pubspec.lock and supabase/tests/package-lock.json; do not upgrade
dependencies as part of setup. Android SDK platform 36/build tools are required.
Run `flutter doctor -v` and accept Android SDK licenses in your development environment.

From a clean checkout:

```powershell
flutter pub get --enforce-lockfile
dart run build_runner build
git diff --exit-code -- lib
dart format --output=none --set-exit-if-changed .
flutter analyze --no-pub
flutter test --no-pub
npm ci --prefix supabase/tests
node supabase/tests/run.mjs
node supabase/tests/concurrency.mjs
flutter build apk --debug --no-pub
flutter build apk --profile --no-pub
```

Generated Freezed/JSON/Injectable sources remain committed and reproducible.
CI runs these commands on a clean Windows runner without credentials or hosted writes.
Visual capture uses the existing teacher screens, bundled Cairo/Material fonts,
Arabic 390x844; see VISUAL_PRESERVATION.md. For deliberate screenshot refresh:
`flutter test test/visual_preservation_test.dart --dart-define=CAPTURE_VISUALS=true`.

## Runtime configuration and build variants

No credentials are required for static verification/builds. An unconfigured app
shows the login screen and fails closed; it never invents a session or backend.
Create ignored `.env.local.json` following `.env.example` (JSON key/value pairs)
and use `flutter run --dart-define-from-file=.env.local.json`.
In VS Code select **Centerly (connected development)** in Run and Debug, then press F5.
The committed launch configuration passes the ignored local configuration file;
it contains no keys itself. Stop any session started without these defines and
launch this configuration once; subsequent UI edits can use Hot Reload/Restart.
Completion contracts through 202610190010 are now deployed and enabled by default;
use CENTERLY_COMPLETION_CONTRACTS=false only for an older backend, not this MVP.
Public URL and publishable key only; never place service-role/secret keys in Dart.
Auth sessions persist in platform secure storage, not SharedPreferences.

- Debug: development verification; APP_ENV=development permits loopback HTTP.
- Profile: performance verification; same public configuration injection.
- Release: `flutter build apk --release --dart-define-from-file=.env.production.json`
  only after T-053 signing/application-ID gates. Existing project release signing
  is still a prototype and does not constitute a distributable production build.
- APP_ENV=staging/production requires HTTPS. Use separately approved Supabase
  projects for those environments; no invented identifiers or private keys.

The generated Supabase config.toml is local tooling configuration. `supabase link`
saves its project reference under ignored supabase/.temp. Linking does not deploy.
Never use linked `db reset`. Review dry-run and approve migrations before `db push`.

## Android compatibility update — 2026-10-19

The current Mac uses Flutter 3.47.2 / Dart 3.13.2. Its installed dependency checker
requires Gradle >=8.14, AGP >=8.11.1 and Kotlin >=2.2.20. The project now specifies
those minimum supported versions; no dependency-validation bypass is used.
Historical baseline results for Flutter 3.44.2 remain historical; current CI/clean
checkout verification on that pinned SDK has not been rerun. Current compilation
results are recorded in IMPLEMENTATION_PROGRESS.md rather than inferred from downloads.

The current configured debug build completed successfully after this update:
`flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json`.
Public URL/publishable key are intended client configuration; account passwords
were not included. APK compilation does not verify login, installation or pilot signing.

## Offline UI review (temporary owner-selected mode)

Select **Centerly (UI preview — offline)** in VS Code and launch with F5.
Stop the existing launch first once when switching modes or adding bundled assets;
Hot Restart cannot change the launch-time defines or reliably install new assets.
No automatic build/restart was performed by the agent. After launch, use normal
Hot Reload/Restart for UI edits. The local ignored runtime file also enables UI
preview; the connected launch explicitly overrides it to false.

Preview reuses the real screens and repositories with a terminal in-memory HTTP
transport. No Supabase initialization, real login, session reads/writes, database
reads/writes or auth refresh occurs. It starts signed in as a synthetic teacher;
logout/login exercise local UI only and do not validate credentials. Preview input
is never stored as a real remembered password. Fixture changes reset on restart.
The banner identifies the mode. The switch is enforced debug-only and defaults off
outside this local launch. To restore backend integration select **Centerly
(connected development)**. Preview assets are synthetic and are not acceptance
evidence for hosted authorization or business workflows.

## Translation updates

Arabic/English JSON files remain the source of truth. Regenerate the official
Easy Localization compiled loader after changing translations:

```powershell
dart run easy_localization:generate -S assets/translations -O lib/core/localization
dart format lib/core/localization/codegen_loader.g.dart
```

The app uses CodegenLoader so a Hot Restart reloads compiled labels without stale
installed JSON assets. The locale parity test rejects stale generated translations.
