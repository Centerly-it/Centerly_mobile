# Reproducible setup (T-003)

Pinned baseline: Flutter 3.44.2 stable, Dart 3.12.2, Java 17, Node 22+.
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
