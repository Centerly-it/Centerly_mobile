# Shared backend contract — v6.1 development deployment

Canonical source: this repository's `supabase/migrations`, by explicit owner
override on 2026-10-18. Nineteen migrations are deployed to centerly-dev after explicit
owner approval; supabase/schema-manifest.json pins their hashes. See BACKEND_COMPAT.md.
Transfer the same versioned migrations and Supabase migration history to the
future Secretary repo; never create/reapply a duplicate schema. Both clients
must pin the same deployed migration version before integrating live data.

## Identity, authorization and provisioning

Supabase Auth owns email/password and auth UUIDs. `teachers.id` is the tenant;
`secretaries.id` references an Auth user and has exactly one `teacher_id`.
Teachers and secretaries have independent live account status; teacher
subscription must also be active. No role comes from editable user metadata.
No public registration/provisioning RPC. Trusted administrators create Auth users
then insert role records with privileged tooling outside both apps. Disable
Supabase public signup in project configuration before pilot; this is not a SQL
setting. Unprovisioned Auth users have no business access.

All tenant tables ENABLE and FORCE RLS. Anonymous has no table/function grants.
Authenticated users read their tenant only; notifications additionally require
matching recipient. Secretary-only INSERT/UPDATE: grade levels, groups, students,
enrollments, exams, assignments. No client DELETE. All other writes use RPCs.
Account/profile, subscription and seat changes are trusted-admin-only.
RPC definer helpers have empty search paths, qualified relations and explicit
EXECUTE grants; migration owner must retain BYPASSRLS for identity lookup.

## Tables

`teachers`, `secretaries`, `grade_levels`, `groups`, `students`,
`group_enrollments`, `group_schedules`, `sessions`, `attendance`, `exams`,
`assignments`, `invoices`, `payments`, `teacher_notes`, `notifications`,
`secretary_removal_requests`, `attendance_change_log`, `audit_events`.
Exact columns, constraints and enum-like CHECK values are migration-defined.
Composite FKs enforce same-tenant references. Business history is archived,
never client-deleted. Update/remove operational tables with care: historical
schedule version editing, enrollment capacity enforcement and provisioning seat
validation still require dedicated acceptance tests and RPC extensions.

## Implemented RPCs (PostgREST named arguments match SQL)

| Function | Arguments | Return / authorization |
|---|---|---|
| get_current_profile | none | JSON id, teacher_id, role; active actor |
| list_students | p_search text=null, p_group_id uuid=null, p_cursor uuid=null, p_limit int=30 | student rows; UUID ascending cursor; max 100 |
| list_sessions | p_from date, p_to date, p_group_id uuid=null | session rows ordered start/id; inclusive range <=62 days |
| get_teacher_dashboard | p_date date=server Cairo today | JSON counts, today's sessions, daily collected and all outstanding; teacher |
| add_schedule | p_group_id uuid, p_weekday int, p_start time, p_end time, p_from date, p_to date=null | schedule UUID; secretary |
| generate_sessions | p_from date, p_to date | inserted count; secretary, inclusive <=62 days |
| set_attendance | p_session_id uuid, p_student_id uuid, p_status text, p_reason text=null | attendance UUID; secretary |
| finalize_attendance | p_session_id uuid | void; secretary, repeat safe |
| cancel_session | p_session_id uuid, p_reason text | void; either role, session not ended |
| create_invoice | p_student_id uuid, p_amount numeric, p_due_on date, p_invoice_number text, p_group_id uuid=null | UUID; secretary |
| record_payment | p_invoice_id uuid, p_amount numeric, p_method text, p_idempotency_key uuid | UUID; secretary, idempotent exact replay |
| reverse_payment | p_payment_id uuid, p_reason text | reversal UUID; secretary, repeat returns same UUID |
| save_teacher_note | p_student_id uuid, p_content text, p_expected_updated_at timestamptz=null | updated timestamp; teacher, optimistic conflict |
| request_secretary_removal | p_secretary_id uuid | request UUID; teacher, pending duplicate returns same request |
| mark_notification_read | p_id uuid | void; matching recipient |
| get_daily_collections | p_date date, p_secretary_id uuid=null | JSON net EGP; either role |

## Calculation and workflow rules

EGP uses numeric(12,2), never binary floats. Payments >0, two decimal places,
cash/transfer/other. Net paid = collections minus reversal rows. Outstanding =
invoice amount minus net paid, excluding void invoices. No overpayment. Due /
partially_paid / paid derives transactionally from ledger. Money rows and audit
logs reject UPDATE/DELETE even for accidental privileged SQL. The invoice-void
workflow is not yet implemented. The scoped profile read is described below.

Dates use Africa/Cairo server conversion including DST; instants are timestamptz.
Daily reports use inclusive local midnight / exclusive next local midnight.
Weekday is PostgreSQL Sunday=0. End time earlier than start means next-day end.
Existing generated occurrences are never overwritten. No background job required.
Manual attendance has no time cutoff, leaves not_marked intact and audits actor/time.
Corrections after finalization require nonblank reason; cancelled sessions retain
marks but reject further marking. Attendance ratios must exclude not_marked from
the marked denominator and show pending separately; no ratio RPC yet.

## Errors and verification limits

RPC business failures use SQLSTATE P0001 with stable MESSAGE: AUTH_REQUIRED,
ACCOUNT_INACTIVE, SUBSCRIPTION_INACTIVE, FORBIDDEN_ROLE,
NOT_FOUND, VALIDATION_ERROR, CONFLICT, ALREADY_CANCELLED,
ATTENDANCE_CORRECTION_REASON_REQUIRED. Constraint/RLS failures can use native
SQLSTATE 23503/23505/23514/42501. Clients must map to localized errors and suppress
SQL details. Unprovisioned users receive ACCOUNT_INACTIVE without tenant access.

Run `npm ci --prefix supabase/tests`, then `node supabase/tests/run.mjs`.
Tests apply all migrations to embedded PostgreSQL with synthetic Auth schema.
Native PostgreSQL 17 also runs 11 independent-connection race assertions. Approved
hosted fixtures passed 36 Auth/REST/RPC assertions and the Dart SDK auth integration
test. Public signup is disabled; email login remains enabled. Production still
requires backups/restore, monitoring and the remaining release gates in BACKEND_REVIEW.md.

## Approved read extension (deployed 2026-10-19)

`202610190001_teacher_browse.sql` deploys teacher-only `get_teacher_overview(p_date)`
(existing dashboard plus explicit manual attendance counts) and bounded
`list_teacher_groups(p_search,p_grade_level_id,p_cursor,p_limit)` with grade,
student count, roster and schedule previews, plus `list_teacher_sessions(p_from,
p_to,p_group_id)` adding group/subject identity to bounded session reads. Production overview, named-session and group reads use the deployed extension.
The original nine versions are unchanged; all ten hashes are pinned. See
[deployment evidence](TEACHER_READ_CHANGE_REVIEW.md). No additional hosted changes
are authorized by this milestone.

Client read cache is bounded memory only (64 responses, 30 seconds), keyed by SDK
identity/endpoint/parameters; no persistent student or finance cache. Validation,
logout and mutations invalidate it. Session/token changes reject late responses.
Refresh bypasses cache; offline failures never fall back to stale sensitive data.


## Approved session detail extension (deployed 2026-10-19)

`202610190002_session_detail.sql` adds teacher-only
`get_teacher_session_detail(p_id uuid,p_status text=null,p_cursor uuid=null,
p_limit integer=30) -> jsonb`. Status accepts present/absent/excused/not_marked;
limit 1..100. Returns session/group/subject/cancellation actor/time/reason, counts
of persisted attendance, filtered_count, attendance records with student/marker
names and timestamps, accurate limit+1 next_cursor and server synced_at.
Missing attendance is not inferred; cancelled history remains readable. Teacher
attendance is read only. All eleven deployed hashes are pinned. See
[actual verification and limits](SESSION_DETAIL_CHANGE_REVIEW.md).

The separately approved `202610190003_student_profile.sql` is deployed and pinned:
`get_teacher_student_profile(p_id uuid,p_cursor uuid=null,p_limit integer=30)`
returns student contacts/timestamps and bounded membership history (including
inactive enrollment and group archive metadata), membership_count, accurate
next_cursor and synced_at. Other-tenant/archived students return NOT_FOUND.
See STUDENT_PROFILE_CHANGE_REVIEW.md for evidence and acceptance limits.

The seven-file completion package 202610190004..010 was separately approved and
deployed on 2026-10-19; all nineteen exact remote SQL bodies and grants verified.
Hosted synthetic Auth/REST/workflow tests passed 98 assertions without account/Auth
changes. Completion reads/event triggers are live; Flutter gate defaults enabled.

## Completion read contracts (deployed)

All seven reads require an active teacher/subscription. Secretary/anonymous denied;
tenant is resolved server-side. JSON monetary values below are decimal strings.
Reports: p_from/p_to inclusive dates, <=366 days; p_cursor UUID=null and p_limit=30
(1..100), UUID ascending pages with rows/total_count/next_cursor/synced_at.

| RPC | Named arguments beyond common report/page inputs | Response notes |
|---|---|---|
| get_teacher_student_academics | p_id uuid, p_kind exams/assignments, p_group_id uuid=null | Missing score stays null; distribution/count/average summary |
| get_teacher_student_attendance | p_id uuid, p_group_id uuid=null, p_status text=null | Cancelled history retained; cancelled/pending excluded from marked denominator |
| get_teacher_finance | p_kind invoices/payments='invoices', p_student_id/p_group_id/p_secretary_id uuid=null | Invoice totals by due date; net collections by Cairo receipt date; collector affects collections only |
| get_teacher_student_note | p_id uuid; no report/page inputs | note=null or content/updated_at; preserve exact timestamp for save_teacher_note optimistic version |
| list_teacher_secretaries | page inputs only | Own status/contact/latest removal request; no deactivation |
| list_teacher_notifications | page inputs only | Own recipient rows, unread_count; payload ID allowlist only |
| get_teacher_calendar | p_from/p_to inclusive <=62 days, p_group_id uuid=null; no page inputs | sessions, server_date, synced_at; status derived from server time, cancelled preserved |

Private helpers cannot be executed by clients. Six history indexes support reports.
Future payment/reversal INSERTs notify the owning teacher exactly once per ledger
row; replay creates no second row/event. Pending->handled removal transition notifies
the teacher; status-only handling never deactivates a secretary. No backfill, push or
cron. Trigger failure rolls back the corresponding business transaction. Existing
cancellation notifications, note writes, mark-read and removal request RPCs unchanged.
