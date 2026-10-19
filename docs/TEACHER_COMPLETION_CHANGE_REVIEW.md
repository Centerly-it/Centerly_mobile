# Teacher MVP completion package — approved and deployed

Owner explicitly approved the exact seven pins in chat on 2026-10-19. Baseline and
hashes rechecked; dry run listed only those seven. Deployment completed on centerly-dev.
Postflight matched all nineteen remote SQL bodies, grants/helpers/indexes/triggers.
Hosted synthetic completion tests passed 98 assertions without account/Auth changes.
The approval request and boundaries below are retained as the deployment record.

Target: centerly-dev / yfeubomyglmhuwizaqoj. Baseline: twelve deployed migrations
through 202610190003. Fresh read-only inventory matched all twelve remote SQL bodies,
18 tables, 30 policies, forced RLS and restricted execution. No completion reads
are deployed. This request authorizes only the seven exact files below, in order.

Source directory: supabase/proposals/teacher_completion. SHA256 uses UTF-8 with LF
line endings; machine-readable pin: supabase/completion-package-manifest.json.

| File | SHA256 |
|---|---|
| 202610190004_teacher_read_helpers.sql | 5de720f00f265769fcf58f67ba6644c10b740d54499b27ab4ce5c7c72826fadb |
| 202610190005_teacher_academics.sql | cfbf4289a59cd0be201350a41a0b1e9bdc82d14b554d66d9e48a5c434885e1d6 |
| 202610190006_teacher_student_attendance.sql | 7d89703812852eeab26e9a72238f4e918a37f97a351d3319962243b37e25813d |
| 202610190007_teacher_finance.sql | e1b5255ef353e58d56fb53a01270297028c36535d680e1bb58e610271515a83f |
| 202610190008_teacher_people_events.sql | 7fc3629a20a59ece96af8b6d5a2ecdc245538c18164df3e770070326920e4b64 |
| 202610190009_teacher_calendar.sql | c8ae664ccb31dd439068927ac2cd761dcd8a6fa7965ca7914ddb7aa986b8a503 |
| 202610190010_teacher_event_producers.sql | 988718aa10559528fda4b47f55a8803059492c4177257bbc2007973214dc02b0 |

## Exact effects

- 004: three private validation/pagination helpers; six history/search indexes.
- 005: teacher-only exam/assignment pages, missing-versus-zero scores, aggregate
  distributions, date/group filters, UUID cursor with limit+1 detection.
- 006: teacher-only student attendance pages; cancelled history retained, cancelled
  rows excluded from trends; not_marked remains pending, excluded from denominator.
- 007: teacher-only invoice/payment pages, receipts, collectors, reversals, daily
  Cairo collections and exact decimal-string totals. Invoice totals use due dates;
  collection totals use receipt dates and optional collector. Collector filter
  does not restrict invoice balances. No money mutation or replacement calculation.
- 008: teacher-only note read, own secretary list/latest removal status, own
  recipient-scoped notification page/unread count with allowlisted payload IDs.
- 009: teacher-only calendar; upcoming/ongoing/completed derived from server time,
  cancellation preserved, Cairo server_date and synced_at, inclusive <=62 days.
- 010: two private trigger functions/two triggers. Future payment INSERT emits
  payment_collected/payment_reversed to owning teacher. Pending->handled removal
  transition emits removal_handled to teacher. No backfill, push, emails or cron.
  Payment idempotency/reversal replay produces no duplicate inserts/events.

Adds ten functions (seven public reads, three private helpers), plus two private
trigger functions, six indexes and two triggers. No tables/columns/policies changed,
no records deleted or rewritten, no account/Auth/role/fixture/secret changes. Existing
twelve migration files and all business mutation RPCs remain unchanged.
Indexes build normally and can briefly block writes; deploy on the development
project during an idle window. Triggers run transactionally: failed notification
insertion rolls back the corresponding future payment/removal transaction.

## Authorization and both-client compatibility

Each public read checks active teacher/subscription from server identity; no UI
teacher_id/role authority. Cross-tenant IDs fail or return no rows. Anonymous and
secretary execution denied, empty search_path, schema-qualified references.
Private helpers/trigger functions have no client execute grants. RLS stays forced.
Secretary React continues using existing secretary writes and same shared tables;
new event triggers apply equally to its future writes. Removal remains a request,
not deactivation. Teacher never writes attendance, academics, invoices or payments.
Both clients share migration IDs/contracts; ownership later transfers without
reapplying versions. RPC parameters are PostgREST named arguments; money is decimal
strings, UUID cursors ascending, pages 1..100, report date range <=366 days.

## Validation and limits

- Local package: 98 assertions PASS, all seven proposals applied to disposable PG17.
  Teacher/secretary/anonymous/tenant/inactive/subscription denial, pagination,
  null score, attendance correction/pending/cancelled history, finance and calendar.
- Local integrity: 22 assertions PASS: simultaneous same-key payment/reversal,
  exactly-one events, competing note version conflict, duplicate removal request,
  exactly-one handled event, recipient denial/paging and Cairo DST-day boundary.
- Existing local audit suites passed: SQL 90, races 11, session detail 33, profile 21.
- Fresh hosted SDK auth test PASS using existing synthetic accounts; no business
  fixture writes in this review. Hosted package/UI acceptance is pending deployment.

## Approved execution boundary (only after explicit owner approval)

Recheck twelve pinned remote SQL bodies; copy exact seven proposal bytes into
managed migrations, verify package hashes, dry-run only these seven versions.
Deploy with seeds/roles/vault skipped. Verify nineteen remote SQL bodies, expected
functions/grants/indexes/triggers and existing-fixture read authorization. Pin
nineteen hashes, then activate Flutter gate and run hosted synthetic MVP tests.
Existing synthetic-fixture mutation authorization is reused only within that scope;
no new accounts, password reset, real tenant edits or Auth setting changes.
Any SQL/hash/scope change invalidates this review and requires a revised approval.
Pilot device/signing/performance/backup/Secretary cross-app acceptance stays open.
