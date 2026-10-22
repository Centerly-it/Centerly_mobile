# Shared pilot checkpoint — 22 October 2026

Current status and stable task IDs: [SHARED_COMPLETION_CHECKLIST.md](SHARED_COMPLETION_CHECKLIST.md). Real credentials are available; real Auth/Chrome and native Windows reads passed. All 27 migration hashes/history/catalog verified. See [PILOT_EVIDENCE.json](PILOT_EVIDENCE.json), [CROSS_APP_ACCEPTANCE.md](CROSS_APP_ACCEPTANCE.md) and [PILOT_OPERATIONS.md](PILOT_OPERATIONS.md). No hosted business/schema/config changes or publication. The following checkpoint text is historical where inconsistent.

# Secretary React handoff — shared backend v202610220001

Teacher repository temporarily owns the canonical backend by explicit owner
override. Twenty-six approved immutable migrations are deployed to centerly-dev
(yfeubomyglmhuwizaqoj). Do not initialize a second schema/project or replay these
migrations. supabase/schema-manifest.json pins LF-normalized SHA256 hashes;
SHARED_BACKEND_CONTRACT.md defines current signatures, date/money/error semantics.
TEACHER_COMPLETION_CHANGE_REVIEW.md records the last seven-file approval/deployment.

Latest verified development deployment:202610220001_finance_movements.sql, exact
owner-approved SHA256,26 bodies/full catalog matched (45 functions,18 tables,
30 policies,0 enrollment violations). No account, money or fixture mutations.
See FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md. Teacher implementation is complete
for the agreed owner-testing scope; authenticated acceptance awaits original
credentials and owner-requested final build. Receipt filters are enabled.

## Current Teacher handoff — after approved migration 26

Production Finance now uses list_teacher_finance_movements for full-dataset receipt
search/method/kind/collector/student/group/date filters, before UUID pagination;
count/gross/correction/net totals cover every match. Original and current collectors
remain separate. Other redesigned routes use their established scoped repositories;
teacher attendance/academics/finance remain read-only. Group notes excluded and QR
deferred as documented. No optional feature was added in the deployment follow-up.

Transfer all 26 exact managed migrations/history/manifest, including202610220001;
there is no pending receipt proposal to deploy again. Keep migration ownership
singular. Do not replay or rename versions. This new function is teacher-only:
Secretary must use its permitted RLS/operational contracts, not weaken teacher grants.

Fresh checks:251 Flutter PASS/1 credential-blocked Auth SKIP;3 activation UI/adapter,
3 preview and119 local SQL assertions PASS;60 hosted read-only reports/230 pages/
2,466 checks plus tenant/role/anonymous denial. These SQL-role checks do not prove
password Auth or React UI acceptance. No new build/restart occurred. Native smoke
from the previous checkpoint is historical and synthetic.

Expected local credential path:
`/Users/mohamedsalem/Desktop/Centerly_mobile/.env.development-accounts.json`.
It remains unavailable; do not reset/provision accounts or put credentials into
Vite/source/builds. Teacher final command uses preview=false and receipt filters=true
in TEACHER_OWNER_TESTING.md. Remaining acceptance: original credentials, connected
login/restore/logout/reconciliation and owner-requested Android/contact checks.
Attendance free-text search is unavailable; group notes/QR are agreed exclusions.
Pilot signing/recovery and future React acceptance remain separate in
PILOT_RELEASE_GATES.md. Do not hold the Teacher implementation open for an unbuilt
React app. No Secretary app was created as part of this work.

The preceding pre-deployment Teacher checkpoint below is retained as historical
context; its25-version/default-off/local-proposal statements are superseded.

## Teacher implementation checkpoint — 2026-10-22

The latest connected Teacher implementation now consumes the deployed finance
overview/filtered-dues/invoice-detail contracts and real Groups/Students/Profile/
Calendar/Session repositories. Shared designs, translations and teacher read-only
permissions are preserved. Trusted display name reads only RLS-scoped teachers.name;
contact actions use actual scoped numbers. Group-note editing is explicitly
excluded by owner decision. QR scanner/cards remain deferred, not preview stand-ins.
See TEACHER_OWNER_TESTING.md for every route/action and exact final owner build.

Fresh baseline verification matched all 25 remote bodies and full catalog (44
functions,18 tables,30 policies), enrollment violations0; no migration redeployed.
251 Flutter PASS/1 hosted Auth opt-in SKIP,3 explicit preview PASS,217 local SQL
assertions PASS,13 hosted read-only synthetic-role assertions PASS, and1 Android
native synthetic/plugin smoke PASS. Read-only SQL and native fixtures do not prove
password Auth/React UI. Original development passwords are unavailable; owner
confirmed this. Do not provision/reset accounts or copy credentials into Vite.

One local proposal `teacher_owner_testing/202610220001_finance_movements.sql` is
SHA-pinned in TEACHER_OWNER_BACKEND_REVIEW.md, outside managed migrations, undeployed
and disabled in Flutter. It supplies full-dataset receipt search/method/kind totals
without broadening teacher write or Secretary read grants. Transfer the deployed25
baseline as-is; include a26th version only if it was later explicitly approved,
deployed, verified and pinned. Never assume proposal presence means deployment.

Remaining Teacher owner acceptance: original credentials and authenticated connected
navigation/restore/logout/reconciliation; full receipt-filter acceptance after the
one reviewed extension if approved. Native secure-storage/URL-handler/Finance-shell
smoke ran on Android17/API37 emulator; external contact completion, physical device
performance and revocation remain open. Pilot signing/recovery and future React
cross-app matrix are separately documented in PILOT_RELEASE_GATES.md. Those future
React tests must not hold the Teacher implementation milestone open indefinitely.


## Ownership transfer

When the Secretary repository exists, copy the exact versioned migrations, tests,
contracts and manifest, retaining the hosted supabase_migrations history. Establish
that repository as sole owner in both projects, then stop adding migrations here.
Verify all twenty-six remote bodies and hashes before new additive migrations. Never
db reset/push existing IDs again, rename versions, edit deployed bytes or apply a
duplicate baseline. Both clients pin the same version. Hosted changes need owner
approval; React implementation is a separate next task, not created by this handoff.

## Client setup and auth

Agreed web stack: React/TypeScript/Vite, TanStack Query, React Hook Form/Zod,
Tailwind/shadcn, Arabic RTL using the agreed design. supabase-js client receives
only public URL/publishable key, supplied through ignored environment files.
No service role, admin key, CLI token or account passwords in Vite/source/builds.
Read ignored development credentials through trusted operator workflow; do not
copy that file into the web repository, fixtures, browser source or CI logs.

No public signup, OTP or self-service teacher/secretary provisioning. Real Supabase
email/password Auth, SDK refresh/logout and live get_current_profile() role check.
Teacher UUID is tenant ID; secretary Auth UUID maps to one teacher_id server-side.
Reject teacher login into secretary workspace. Do not trust metadata, URL/query
role, editable storage or UI teacher_id. Clear sensitive query caches on logout,
role/account validation, tenant switch and mutations; reject late stale responses.

## Permissions and workflows

All tenant tables have ENABLE/FORCE RLS and composite tenant-safe references.
Secretaries may INSERT/UPDATE own grade levels/groups/students/enrollments/exams/
assignments under RLS; they cannot change teacher/account/subscription/seat records
or delete business history. API stamp triggers set updated_at/entered_by server-side.
Use secured RPCs for schedules/generation, attendance/finalization, cancellation,
invoices/payments/reversals. Never write these tables directly from React.

Teacher completion reads are intentionally teacher-only; do not call them from
React or weaken grants. Secretary reads use scoped RLS tables and existing shared
RPCs. Add dedicated bounded secretary contracts only after a separate review where
needed. Secretary can read teacher notes within the tenant, never edit them.
Teacher removal is a request; trusted operator handles status, not either client.

Attendance has no time cutoff/auto-absence/countdown. Keep not_marked forever until
manual action. Finalization is optional; later corrections need reason and append
audit. Cancelled sessions retain history and reject marking. Generate occurrences
idempotently; no attendance cron. Store instants UTC; use server Cairo local dates,
DST and cross-midnight schedules. Never derive authoritative status from device clock.

EGP is numeric(12,2). Preserve exact decimal strings/minor units in clients; no float
balance recomputation. Same payment idempotency UUID for retries of one exact
submission; changed payload/key misuse fails CONFLICT. Serialize UI submission,
reconcile ambiguous errors before another payment. Reversal appends a row and keeps
original receipt/audit. Daily collections use Cairo receipt dates; invoice balances
use due-date filtering, independent of collector filter. No teacher finance writes.

Payments/reversals now transactionally produce one teacher notification per inserted
ledger row; idempotent replay produces none. Cancellation notifies existing tenant
recipients. Removal pending->handled notifies teacher. No push/backfill/email.
Notifications are recipient-scoped; render known types/allowlisted IDs safely.

## Development and verification

Existing four synthetic Auth accounts/two tenants are available on this machine;
no password reset or new account needed. CLI auth/project link are local ignored
operator state. Never run hosted mutation tests against real customers. The package
was verified with 98 hosted assertions (real Auth/REST/RPC, both tenants), plus local
98 contract and 22 integrity assertions. Logs do not replace React acceptance.
Local: npm ci --prefix supabase/tests; check_manifest.mjs; run.mjs; concurrency.mjs;
teacher_completion_package.mjs; completion_integrity.mjs. Scripts use disposable PG17.
Hosted admin test scripts require --approved-development-fixtures; inspect scope
before running. Never run provisioning just to recover a missing credential file.

## Remaining joint acceptance / pilot gates

Record Secretary creates group/student/enrollment; generates sessions; leaves pending,
marks after lesson, finalizes then corrects with reason; Teacher refresh sees exact
marks/history. Enter exams (null/zero distinct) and assignments; Teacher matches.
Collect/retry/race/reverse; receipts, collector totals and Teacher balances reconcile.
Teacher cancels; Secretary sees retained history/status/notification. Teacher note
updates are visible read-only to Secretary; concurrent note conflict is explicit.
Teacher removal request reaches operator; handling updates Teacher without client
deactivation. Test every path with two tenants, guessed IDs, inactive accounts,
expired sessions, offline/slow network, pagination and Arabic edge cases.

Before real pilot: review seat/capacity enforcement, historical schedule revisions,
invoice void/export/privacy workflows; establish monitoring, encrypted restricted
offsite backups and successful restore drill. Android signing/update/performance/
accessibility/security and owner sign-off remain separate from the Teacher testing
handoff. No store publication or production readiness is implied.
