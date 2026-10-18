# Approved development provisioning and tests

Target: centerly-dev / yfeubomyglmhuwizaqoj only. Owner explicitly approved four
synthetic accounts, two-tenant fixtures and fixture-only mutation/security tests.
Do not run these scripts against a production project or without that approval.

The operator scripts use authenticated Supabase CLI to discover the linked project.
Auth admin credentials are fetched into process memory only; they are never printed
or written into app configuration. Teacher/secretary business identities are inserted
through trusted CLI SQL. Account passwords are random and saved only in ignored
`.env.development-accounts.json`. Do not commit, upload or paste that file into logs.

```powershell
node supabase/admin/provision_development.mjs --approved-development-fixtures
node supabase/admin/verify_hosted.mjs --approved-development-fixtures
flutter test test/hosted_auth_integration_test.dart --dart-define=RUN_HOSTED_AUTH_TESTS=true
```

Provisioning resumes from the local credential file after partial failure. It does
not delete users, reset the database or replace existing passwords. If that file
is lost, do not blindly recreate users; inspect the Auth admin state first.
Fixture tests append financial/history rows, temporarily toggle test account or
subscription status, restore it in finally blocks and preserve all ledger/audit data.
No customer data or outbound email is involved. Never add cleanup that silently
deletes payment history. Seat validation remains the operator's responsibility.

The scripts currently use Windows PowerShell/CLI; the SQL/RPC contracts are platform
and framework independent. Ordinary CI runs only local PostgreSQL tests. Hosted
tests require this explicit opt-in and approved test credentials; no hosted writes
occur in the default workflow.

Native persistence verification can run `integration_test/auth_session_test.dart`
on a connected device/Windows with a separate ignored dart-define JSON containing
public runtime config and TEST_TEACHER_EMAIL/TEST_TEACHER_PASSWORD. Test binaries
can contain those synthetic credentials; keep them local, never distribute them.
Normal debug/profile/release builds must use only public runtime configuration.
