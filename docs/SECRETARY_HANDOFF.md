# Secretary React handoff — shared backend v202610200006

Teacher repository temporarily owns the canonical backend by explicit owner
override. Twenty-five approved immutable migrations are deployed to centerly-dev
(yfeubomyglmhuwizaqoj). Do not initialize a second schema/project or replay these
migrations. supabase/schema-manifest.json pins LF-normalized SHA256 hashes;
SHARED_BACKEND_CONTRACT.md defines current signatures, date/money/error semantics.
TEACHER_COMPLETION_CHANGE_REVIEW.md records the last seven-file approval/deployment.

Latest verified development deployment: six approved202610200001..006 migrations,
25 bodies/catalog/grants/RLS matched,135 hosted business checks and1 SDK Auth test
passed. See HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md and PROJECT_HANDOFF.md
in the repository root. Finance read contracts are available; new Teacher designs
remain preview until adapters are integrated. Secretary enrollment updates must
atomically change status/left_at. Ongoing overview counts use server time,
independent of selected day; not_marked is never absence. Earlier test counts below
are historical and do not replace device/React cross-app acceptance.

## Ownership transfer

When the Secretary repository exists, copy the exact versioned migrations, tests,
contracts and manifest, retaining the hosted supabase_migrations history. Establish
that repository as sole owner in both projects, then stop adding migrations here.
Verify all twenty-five remote bodies and hashes before new additive migrations. Never
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
