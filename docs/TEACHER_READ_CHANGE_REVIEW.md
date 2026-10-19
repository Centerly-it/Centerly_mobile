# Approved development read-contract deployment — 2026-10-19

Target: existing linked centerly-dev development project. **Deployed after explicit approval.**
Deployed version: `202610190001_teacher_browse.sql` (after immutable 001..009).
Canonical ownership remains this repository for both clients. No production or
Auth configuration change is proposed.

## Concrete change

- `get_teacher_overview(p_date date=server Cairo today) -> jsonb`: wraps the existing
  dashboard contract and adds `attendance_counts` with present/absent/excused/
  not_marked. Excludes cancelled sessions, preserves pending and does not change
  attendance marks, finalization or any existing RPC signature.
- `list_teacher_groups(p_search text=null,p_grade_level_id uuid=null,
  p_cursor uuid=null,p_limit integer=30) -> setof jsonb`: teacher-only UUID cursor
  pagination (1..100), search/grade filtering, active student counts, five-student
  roster previews, grade names, up to 32 schedule previews with an explicit
  `schedules_truncated` flag. Archived groups/students are excluded. No phones or
  emails appear in the previews. A full roster continues through list_students.
- `list_teacher_sessions(p_from date,p_to date,p_group_id uuid=null) -> setof jsonb`:
  preserves the deployed bounded session read and adds tenant-scoped group/subject
  names. Required to identify the session before exposing cancellation controls.
- All three infer teacher identity from the existing hardened require_actor helper,
  explicitly scope every subquery to that tenant, use empty search paths, revoke
  public/anonymous execution and grant authenticated execution only.
- Adds three functions only: no tables, policies, write privileges, fixtures,
  provisioning, destructive changes or edits to the original nine files.
- Existing Flutter dashboard/sessions continue using deployed contracts. None of the
  new RPCs is called by production code before approval/deployment and client wiring.

## Validation and activation

Local test suite applies the proposed migration to an isolated PGlite database.
Additional tests cover teacher/secretary/anonymous permissions, cross-tenant denial,
manual pending attendance, grade/search/page validation and a synthetic 10,000-group
bounded query. This is local evidence, not hosted integration/performance proof.
Existing PostgreSQL concurrency tests also apply the full migration directory.

Actual sequence: CLI 2.121.0 login authorized on this Mac; verified the project
reference/name/region, linked locally, checked original nine local hashes and exact
remote migration SQL history, 18 tables/30 policies/FORCE RLS and four approved
accounts. Dry run listed only this version, no seeds/roles. Deployed with
`db push --linked --skip-vault --yes`, no include-seed/include-roles flags.
Postflight verified exact SQL history for all ten versions, three restricted grants
and empty search paths; manifest pins SHA256
`6830529e9cc9bbd9812f406bd7ce272492e199807e0126d5cc45ae2271f817b8`.

Read-only hosted transactions impersonated the existing synthetic Auth UUIDs via
transaction-local JWT subject/role settings. Both tenant scopes, named sessions,
overview counts and both secretaries/anonymous denial passed. Anonymous REST calls to
all three new functions returned HTTP 401. No fixtures or Auth settings changed.
This is real hosted SQL/RLS verification, not password-based Auth/SDK/UI acceptance.
Existing development account passwords are unavailable on this Mac and were not
retrieved, guessed, reset or replaced. The public-only ignored config was restored
from the verified project URL and publishable key with owner-only file permissions.
No original operator SSH host or mounted environment was available.

Hosted positive-case limitation: current fixtures have zero not_marked rows and
zero attendance rows on cancelled sessions. Live results match the relational
formula, but positive preservation/exclusion scenarios were verified in isolated
local PostgreSQL tests only (90 assertions total), without altering hosted data.
Production overview/session repositories and Groups UI now use these deployed
contracts. Full hosted Flutter acceptance still requires restored account credentials.

Remaining backend gaps are outside this proposal: full student profile, detailed
session/attendance reads, operational integrity extensions, backup/restore and
Secretary cross-app acceptance. They require their own reviewed work.

Sanitized evidence: [teacher_read_20261019.json](verification/teacher_read_20261019.json).
The configured debug APK compiled after aligning Gradle/AGP/Kotlin minimums;
this is compilation evidence only, not hosted Flutter/device acceptance.
