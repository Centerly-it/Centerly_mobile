# Pending development read-contract approval

Target: existing linked centerly-dev development project. **Not deployed.**
Proposed version: `202610190001_teacher_browse.sql` (after immutable 001..009).
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

After explicit approval: read-only remote migration preflight and dry run; deploy
only this pending version; verify RPC grants/search paths and tenant-scoped hosted
reads using approved synthetic fixtures. Stop if remote state differs. Do not run
fixture mutation scripts or change Auth configuration. Then pin the newly deployed
hash and wire the typed overview/group repositories and production UI, with tests.
Until names are available, production session cards do not expose cancellation
controls; a time alone is insufficient to identify overlapping groups.
No deployment or remote configuration command has run in this implementation slice.

Remaining backend gaps are outside this proposal: full student profile, detailed
session/attendance reads, operational integrity extensions, backup/restore and
Secretary cross-app acceptance. They require their own reviewed work.
