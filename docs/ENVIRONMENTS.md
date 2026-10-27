# Separate development and production — 27 October 2026

| Run configuration | Project | Reference | Local Flutter file |
| --- | --- | --- | --- |
| `dev` | `centerly-dev` | `yfeubomyglmhuwizaqoj` | `.env.dev.json` |
| `prod` | `centerly-prod` | `ohhwccwwwxfmwpfypfyf` | `.env.prod.json` |

Both projects are in the existing Free organization, in `eu-west-3`. No paid plan/add-on was enabled. The current development project and all test identities, students, payments, attendance and audit history were preserved. Production was newly created; no existing database was reset or cleared.

## Run the Teacher app

In VS Code Run and Debug, choose `dev` or `prod`, then Run. Stop an existing run before switching: dart defines cannot change through Hot Reload. Both connected configurations disable offline preview. The independent offline preview configuration is retained.

Terminal equivalents:

```powershell
flutter run --dart-define-from-file=.env.dev.json
flutter run --dart-define-from-file=.env.prod.json
```

The old shared production launch entry was removed. `env.production.json` is no longer read by the run/build configurations; the unavailable file from the other computer is not needed. `.env.local.json` is retained as a legacy development source, including existing local test tools. No test credential file was renamed, removed or copied to production. Templates without keys live in `config/env.dev.example.json` and `config/env.prod.example.json`.

Production runtime accepts only the dedicated production host; development rejects that host. Existing encrypted auth storage and read-cache namespaces already include the backend host, keeping authentication/data separated. Local client environment files are ignored by Git and contain public client keys only. Transfer `.env.dev.json` and `.env.prod.json` privately when using another computer. Never place the private `.env.production-admin.json` or its database password in an application or repository.

## Secretary website

The website has ignored `.env.development.local` and `.env.production.local` mode files. These point to the same respective projects as Teacher. Run from the Secretary repository:

```powershell
npm run dev:dev
# http://127.0.0.1:5173
npm run dev:prod
# http://127.0.0.1:5174
```

The production Pages build script now reads `.env.prod.json` and the production manifest, and rejects the former shared development target. Auth storage is namespaced by backend host. Neither local website was restarted and no website was published during setup; an already-published version retains its previous configuration until separately rebuilt/deployed with owner approval.

## Backend reconciliation and verification

The development host had 37 versions while the current Teacher checkout had only 34. The exact three missing files were recovered from existing canonical commit `6f86568d9c9491468c4a45fc5c266f69ff9a68d4`, matching the Secretary manifest; no deployed SQL was rewritten. Full development history/catalog verification passed before production creation.

Production was proven empty before applying exactly those 37 unchanged migrations with the normal CLI. The dry run listed only those 37 files. Deployment used an isolated workspace; the default repository CLI link remains development. Never run old fixture provisioning/reset scripts against production. The one-time creation/deployment helpers fail closed on an unrecognized or nonempty target and do not reset existing projects.

Postflight compared all migration bodies and the full application catalog: **85 functions, 18 public tables, 30 policies, 30 triggers**, including grants, indexes and constraints. Production has **zero Auth users and zero rows in all 18 public tables**, no buckets/files and no Edge Functions to copy. Development row fingerprints and financial totals were identical before/after. Production inherited the development email/password, signup-disabled, anonymous-disabled, confirmation and session settings; no external provider/SMTP credentials or test data were copied.

Actual hosted anonymous REST checks passed for both environments: Auth settings reachable and protected profile RPC denied without a user. No production login acceptance is claimed because no accounts exist yet. Local tests: 7 development Flutter/config/storage checks; 6 production Flutter/config checks; 77 Secretary tests; 90 PostgreSQL business/authorization assertions; 37 migration hashes; analyzer/lint/type checks.

## Create real accounts later

Use the **centerly-prod** Supabase Dashboard. Public self-signup remains disabled, following the existing internal-provisioning backend contract. No real teacher or secretary has been created by this setup.

1. In Authentication → Users, add the real teacher using their actual email and private password. Copy the new Auth UUID. Create its matching `public.teachers` row with the real name, active status/subscription and an explicitly chosen secretary seat count.
2. For each secretary, create a distinct Auth user and a matching `public.secretaries` row whose `teacher_id` is that teacher's UUID. Respect the teacher's configured seat count.
3. Confirm Teacher and Secretary can each sign in to `prod` and only access their own teacher's data before entering real student records. Test credentials from development will not work in production.

Do not copy `auth.users` or synthetic profiles across projects. Account provisioning is a separate owner action; entering only an Auth user without the application profile does not create an authorized Centerly account.

This setup prepares the empty production backend/configuration, not a public product launch. The Free plan still has its normal limits and lacks automatic backups; recovery arrangements, real-account acceptance and any public website/email redirect/SMTP configuration remain owner launch decisions. The copied Auth site URL is the existing local default, not a newly approved public domain. No native app was installed, restarted, built or distributed.
