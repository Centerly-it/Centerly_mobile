# Hosted change review — approval required

Target: **centerly-dev**, reference **yfeubomyglmhuwizaqoj**, eu-west-3.
Repository linked using authenticated Supabase CLI 2.121.0 on 2026-10-18.
Owner approved all three changes in chat on 2026-10-18. All nine migrations and
the four synthetic Auth accounts/fixtures are now deployed in development only.

## Read-only discovery

PostgreSQL 17.11. Public/private application tables: **0**. Application RLS
policies: **0**. Auth users: **0**. Migration history: absent. Public has Supabase's
existing `rls_auto_enable()` helper. No name conflicts with Centerly were found.
`supabase migration list --linked` shows nine local / zero remote migrations.
`supabase db push --linked --dry-run` lists exactly these nine pending versions:

| Version | File / effect |
|---|---|
| 202610180001 | identity.sql: teacher/secretary identities, active-account helpers, profile RPC |
| 202610180002 | students_groups.sql: grades/groups/students/enrollments/schedules/sessions/attendance |
| 202610180003 | records.sql: academics, invoices, ledger, notes, notifications, removal/audit records |
| 202610180004 | authorization.sql: RLS, role grants, immutable history, timestamps/indexes |
| 202610180005 | attendance.sql: mark/finalize/cancel RPCs with session-row locks and audit |
| 202610180006 | finance.sql: invoice/collection/reversal RPCs, decimal validation, locking/idempotency |
| 202610180007 | teacher_actions.sql: conflict-protected notes, removal requests, read markers/reconciliation |
| 202610180008 | schedule_generation.sql: bounded on-demand generation, schedule add, RPC allowlist |
| 202610180009 | read_contract.sql: bounded student/session reads, live dashboard and Cairo server date |

Creates **18 application tables**, a private helper schema, same-tenant foreign
keys, indexes, RLS policies and callable RPCs. No existing tables/rows are dropped
or rewritten. No users or student/financial rows are seeded by this deployment.
Supabase migration metadata is created by the CLI. Private is not API-exposed.
Future public/private functions default to no PUBLIC execute, requiring grants.

## Review findings addressed before first deployment

- Replaced migration 008's blanket public-function revoke with the named Centerly
  RPC allowlist, preserving hosted `rls_auto_enable()` permissions.
- Dashboard date now defaults in PostgreSQL using Africa/Cairo, including DST.
- Original nine files are still undeployed, so these corrections safely precede
  their first application. Once deployed, append new migrations; never edit history.
- Helpers use empty search_path and qualified relations. Live identity/status checks
  back all RLS and sensitive RPCs; no role is read from editable JWT metadata.
- Every protected table ENABLEs/FORCEs RLS; role-sensitive mutations use RPCs.
- Manual attendance has no timer/absence conversion. Payment rows are append-only.

Local checks: all migrations apply; 64 PostgreSQL authorization assertions pass;
11 independent-connection assertions pass for retry/overpayment/attendance/cancel
races. These are not hosted REST/Auth proof. Real hosted verification follows approval.

## Proposed commands after explicit migration approval

1. Re-run linked read-only inventory and dry-run; stop if hosted state changed.
2. `supabase db push --linked` for the nine reviewed migrations, without seed flags.
3. Verify migration history, table/RLS/constraint/function grants and schema advisor.
4. Check anonymous REST denial with the public publishable key.

No linked reset, migration repair, production data mutation or store publishing.
Local public-only .env.local.json contains URL/publishable key, never service-role.

## Separate development-data approval

Propose four synthetic Auth users: teacher-a@centerly.test, teacher-b@centerly.test,
secretary-a@centerly.test, secretary-b@centerly.test. Random passwords stay in an
ignored local credential file. Provision through Supabase Auth admin API using
CLI-authenticated trusted tooling; privileged keys remain process-memory-only.
Create two isolated active test tenants, one secretary each, and small synthetic
grade/group/student/session/invoice fixtures. Test attendance corrections, payment
retries/reversals, cancellation, tenant denial and inactive-account/subscription
denial against these fixtures only. No customer data or outbound emails.
Keep fixtures for development; deleting them requires separate approval.

Public signup is now disabled after separate owner approval. Email/password login
remains enabled: global auth.enable_signup=false denies signup, while the email
provider flag stays enabled. The scoped config push left undeclared hosted settings
unchanged. No production project or store deployment occurred.
Full backup/restore, complete operational RPCs and cross-app acceptance remain gates.
