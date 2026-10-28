# Reproducible local setup

Read [the handoff](../CODEX_HANDOFF.md) and [environments](ENVIRONMENTS.md) first. Use Flutter 3.44.2 / Dart 3.12.2, Java 17, Android SDK36 and Node22+. Preserve committed lockfiles and generated sources; do not upgrade dependencies during setup.

```powershell
flutter doctor -v
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
npm ci --prefix supabase/tests
node supabase/tests/check_manifest.mjs
node supabase/tests/run.mjs
flutter run --flavor dev --dart-define-from-file=.env.dev.json
```

Run Flutter commands sequentially. Native PostgreSQL suites also run serially because they share port55439. Commands above use disposable local test databases; never substitute hosted reset/fixture scripts.

Securely restore ignored environment profiles on a new computer. Production run uses `--flavor prod --dart-define-from-file=.env.prod.json`. No credentials are committed. For signed production builds follow [Android updates](ANDROID_UPDATES.md), restore the existing signing key and verify its identity pin. Do not generate another key. Release builds must allow pub/plugin regeneration (do not add `--no-pub`). Do not install on a device unless requested.

Teacher owns the canonical40-migration schema. See [shared contract](SHARED_BACKEND_CONTRACT.md); do not replay historical deployment plans. Local tests, hosted acceptance and physical-device tests are separate evidence.
