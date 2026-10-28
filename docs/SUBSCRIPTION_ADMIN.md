# Manual subscription suspension

The owner selected manual administration, not automatic monthly expiry. No payment gateway, billing scheduler or subscription dates are introduced.

In the Supabase Dashboard, select the intended project first: `centerly-dev` for synthetic testing or `centerly-prod` for real accounts. Open **Table Editor → public.teachers**, locate the teacher by their verified Auth UUID and name, then change only **subscription_status**:

- `inactive`: stop the teacher and all secretaries attached to that teacher.
- `active`: permit access after payment, provided the teacher and each secretary also have `status = active`.

Do not delete the user or change passwords, `status`, tenant IDs or historical records for a missed subscription payment. Teacher and secretary clients cannot edit this administrator-only field themselves. Renewing a subscription does not reactivate a secretary independently deactivated by the teacher.

Existing backend identity/RLS checks already reject protected reads and writes with `SUBSCRIPTION_INACTIVE`, including requests using an existing valid Auth token. Supabase Auth may verify the password, but application profile validation denies entry and clears the local session. No Auth ban or account deletion is required.

Teacher and Secretary clients display **«راجع دفع الاشتراك مع الإدارة.»**, clear protected data and sign out locally after confirmed denial. Open clients detect it on their next rejected request, foreground/focus validation or approximately 60-second foreground profile check while connected. Offline devices cannot receive the administrative decision until they reconnect; already downloaded information cannot be retracted. Temporary network failures alone do not sign out a valid account.

After renewal, the user signs in again normally. No automatic login or mutation retry is performed.

Verification for this change: 16 disposable native PostgreSQL role assertions (old/fresh sessions, teacher and secretary denial, tenant isolation, client self-renewal denied, preserved histories and renewal); 18 Flutter auth/session/router/SDK-fixture tests; 79 Secretary tests. SQL-role and SDK-fixture tests are synthetic; no hosted subscription or account was changed, and no physical-device/manual acceptance is claimed. That verification was recorded against schema38; current schema40 retains these controls. See CODEX_HANDOFF.md for the current checkpoint.
