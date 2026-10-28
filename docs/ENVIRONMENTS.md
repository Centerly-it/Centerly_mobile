# Current development and production configuration

Updated 2026-10-28. [Full handoff](../CODEX_HANDOFF.md) is the startup authority.

| Mode | Backend       | Public ref           |
| ---- | ------------- | -------------------- |
| dev  | centerly-dev  | yfeubomyglmhuwizaqoj |
| prod | centerly-prod | ohhwccwwwxfmwpfypfyf |

The old shared-production setup is superseded. Keep synthetic accounts/data in dev; do not copy them into prod. Verify live inventory before assuming prod is still empty.

## Teacher

Ignored `.env.dev.json` / `.env.prod.json`; public key-only templates in Teacher `config/`. Native flavors and backend selection must match:

```powershell
flutter run --flavor dev --dart-define-from-file=.env.dev.json
flutter run --flavor prod --dart-define-from-file=.env.prod.json
```

VS Code has matching dev/prod launches. Stop+Run to change compile-time mode. Native icon/splash/package changes need rebuild. Signed distribution uses [Android updates](ANDROID_UPDATES.md), not debug builds. Prod identity com.centerly.teacher and existing signing key are permanent.

## Secretary

Ignored `.env.development.local` / `.env.production.local`; owner scripts also read sibling Teacher profiles.

```powershell
npm run dev:dev
# http://127.0.0.1:5173
npm run dev:prod
# http://127.0.0.1:5174
```

Public https://centerly-secretary.pages.dev uses prod. Development synthetic accounts cannot log in there. Only public publishable/anon client keys belong in build configuration; no privileged keys/fixture flags. Current schema is 40 migrations, not the old 27/37 baseline.

## Private transfer

Existing synthetic credentials: ignored Teacher `.env.development-accounts.json`; verify/read securely without printing. Do not recreate accounts when this file is absent. Legacy `.env.local.json` remains used by some old tools; obsolete shared `env.production.json` is not required by current launchers.

Ignored `.env.production-admin.json`, DB passwords/service keys, Git/Cloudflare/Supabase credentials and signing files are private operator inputs. Git cannot restore them on a new device. Securely transfer necessary profiles and the existing signing backup; never regenerate production signing material. Codex-account switching on the same computer does not require deleting files.

Public signup stays disabled. Only on explicit owner onboarding instruction, create a real Supabase Auth user, then its corresponding active teacher profile with chosen subscription/seats; secretaries need their own Auth/profile and exact teacher ID. Never rename synthetic tenants into real customer accounts. Confirm two-tenant isolation with authorized accounts before entering real student data.
