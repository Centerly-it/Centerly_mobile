# Diagnostics and Android flavors

## Run the matching environment

```powershell
flutter run --flavor dev --dart-define-from-file=.env.dev.json
flutter run --flavor prod --dart-define-from-file=.env.prod.json
```

VS Code launch configurations `dev` and `prod` already pass these options. The offline preview uses the dev flavor. Stop and Run after switching: Hot Reload does not switch compile-time configuration, package identity or native resources.

Android `dev` is **Centerly Dev**, application ID `com.centerly.teacher.dev`; `prod` is **Centerly**, application ID `com.centerly.teacher`. The approved production signing identity is pinned in config/android-release-identity.json; restore the existing key instead of generating another. The apps have separate Android sandboxes and backend-specific Supabase storage keys. Old pre-flavor development installations are not migrated or removed automatically.

The runtime configuration rejects mismatched native flavor / APP_ENV and mismatched backend projects before initializing Supabase. CI builds the dev flavor explicitly and uploads its correctly named artifacts.

## Development console

Run `dev` in Debug mode and filter VS Code Debug Console or `flutter run` output for `[Centerly]`. Real Supabase Auth, REST and RPC traffic passes through `DiagnosticHttpClient`; this is not a Dio interceptor that misses SDK requests.

Example (illustrative metadata, not a new hosted test):

```text
[Centerly][development] {"operation":"POST /rest/v1/rpc/get_current_profile","outcome":"failed","request_id":"r8","status":400,"elapsed_ms":218,"code":"SUBSCRIPTION_INACTIVE","response_shape":"object:4_keys"}
```

Records show request start/completion, correlation ID, known endpoint, status, elapsed milliseconds, byte count, safe response shape and recognized backend error codes. Transport failures include a safe exception type. App/framework/Bloc/support failures include a project-relative source location when present. Cached teacher reads explicitly show `cache_hit`; no network request is expected for those. Remote cancellation/retries are not added: existing read retry and mutation behavior are preserved.

No request/response values, bodies, SQL details/hints, query values, emails, student names, passwords, bearer tokens or API keys are printed. Responses larger than 4 KB are not parsed for summaries; the response stream passes through without truncation or extra buffering beyond that preview cap. Unknown endpoints are redacted. Use the operation, request ID, status, code and source when reporting a bug, instead of only the user-facing message. The in-memory metadata buffer is bounded to 50 records and is not persisted to disk.

## Production

Production configuration produces no diagnostic console prints, even in a prod debug APK. Success traffic is not retained. Unexpected error metadata can be sent to the existing Sentry SDK only when `CENTERLY_SENTRY_DSN` is present in the private production define JSON. No Sentry project, paid resource or external account has been created, and no test telemetry is sent by this change.

Without a DSN, remote reporting is disabled; bounded local failure metadata remains available in memory to a debugger. To enable remote monitoring later, the owner supplies their existing project's **public DSN** in `.env.prod.json` and rebuilds. Never put a Sentry API/auth token in the app.

Only explicit sanitized diagnostic events are accepted. User/request objects, raw exceptions, arbitrary tags and device contexts are discarded before sending. There are no automatic breadcrumbs, network payloads, replay, screenshots, tracing or native automatic integrations. Global Dart/Flutter errors and Bloc errors use the same safe metadata path. Expected HTTP auth/business denials are not crash reports. Reports are limited to 20 per rolling session-hour; reporting failure never blocks a business operation. This does not claim native process-crash capture, external alert delivery or a manual device pass.

Both APKs are development-signed validation artifacts. Production release signing and real-account acceptance remain separate owner decisions.
