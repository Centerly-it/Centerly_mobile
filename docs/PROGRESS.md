# Progress pointer

The session ledger is [IMPLEMENTATION_PROGRESS.md](../IMPLEMENTATION_PROGRESS.md).
Read it with agent_rules.md, CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md and
docs/DECISIONS.md at the start of every session. The owner explicitly authorized
temporary canonical backend ownership here; this overrides plan ownership clauses.

## 2026-10-19 resumed implementation

| Task | Status | Implementation commit | Files / validation | Next / blockers |
|---|---|---|---|---|
| T-013 | DONE (local acceptance) | ef11882 | core read cache/client, bootstrap invalidation, repositories; cache/identity/retry/error tests pass | Hosted cross-app acceptance remains T-050/T-054 |
| T-012 | IN_PROGRESS | ef11882 | production safe areas/navigation, wrapping shared metrics, font-loaded AR/EN 320/430 scale-2 captures | Full Figma composition, physical TalkBack/safe-area QA remain |
| T-020 | IN_PROGRESS | ef11882 | server date filter, live aggregates/session rows, scheduled minutes and refresh | Attendance summary RPC pending approval; seeded hosted UI reconciliation remains |
| T-021 | BLOCKED (hosted approval) | ef11882 | typed group DTO/repository and additive SQL proposal; 10k bounded fixture test | Approve reviewed development read extension before wiring live Groups |
| T-022 | IN_PROGRESS | ef11882 | day/week/month production reads; Cairo DST/boundary and range tests | Named-session contract, hosted/web/device agreement remain |
| T-024 | IN_PROGRESS | ef11882 | cancellation workflow tested with group identity, reason, guarded RPC and reconciliation | Production action gated until named-session contract; actor/history/hosted acceptance remain |

Commands: `flutter analyze --no-pub` PASS; `flutter test --no-pub` 37 PASS,
1 hosted opt-in SKIP; changed Dart format check PASS; screenshot capture matrix
4 PASS; `node supabase/tests/run.mjs` 88 PASS; concurrency 11 PASS; manifest
9 unchanged / 1 pending; diff check PASS. Debug APK attempt was interrupted during
Gradle 8.12 distribution download after over six minutes, before compilation;
not an APK pass or compile failure. No hosted commands/mutations/deployment ran.

Next approval: docs/TEACHER_READ_CHANGE_REVIEW.md, one new migration with three
teacher-only read functions. Support URL stays configurable/pending. Original
uncommitted analyzer/iOS/SDK lock resolutions and the supplied untracked plan are
preserved. The implementation commit stages only the new timezone lock entry,
leaving the five pre-existing SDK lock resolutions uncommitted.

## 2026-10-19 approved deployment and next eligible read workflows

Implementation commit: `18213b5` (approved deployment, production activation, directory/roster and next local proposal).

| Task | Status | Evidence / changed areas | Next / acceptance limits |
|---|---|---|---|
| T-010 | DONE under override | Exact SQL history before/after deployment; ten hashes pinned | Transfer same canonical history to future Secretary repo |
| T-012 | IN_PROGRESS | Responsive blue/white shell; 8 AR/EN normal/200% captures; accessible actions | Physical TalkBack/safe areas and full Figma parity remain |
| T-020 | IN_PROGRESS | Deployed overview counts, date filters, decimal display, named sessions; multi-read scope guard | Hosted password/UI fixture reconciliation and remaining filters |
| T-021 | IN_PROGRESS | Live group search/grade filter/pages/schedule and roster previews; full roster navigation | Hosted Flutter and device/10k interaction acceptance |
| T-022 | IN_PROGRESS | Named day/week/month reads, Cairo/DST tests | Stored status temporal/clock-skew and cross-app acceptance |
| T-024 | IN_PROGRESS | Identified production cancellation via existing RPC, tested confirmation/error/reload | No hosted mutations rerun; actor/time/history display remains |
| T-030 | IN_PROGRESS | Real directory and group roster via list_students; read-only contacts, stale/paged/logout tests | Full profile/memberships/academic/financial history/notes |

Actual commands/results: preflight SQL + validator PASS (nine originals and exact
remote history unchanged, expected 18 tables/30 policies/four accounts); dry run
only 202610190001; db push --linked --skip-vault --yes applied that file only,
no seeds/roles; postflight history/grants/search paths and all four synthetic actor
read-only SQL checks PASS. Anonymous REST: 401 for all three reads. No fixture/Auth
settings/password/account changes. No positive pending/cancelled-attendance hosted
rows exist; local nonvacuous tests cover those cases. Password-based Auth/SDK/UI
checks require the original missing credentials, which were not retrieved/reset.

Analyzer PASS, 52 Flutter PASS + 1 hosted opt-in SKIP, 90 isolated SQL PASS,
11 independent PostgreSQL race PASS, tokenizer unit test PASS, 8 capture tests
PASS, format/diff PASS, manifest 10 unchanged / 0 pending.
Initial Android configuration failed because current Flutter requires newer tools;
Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 now pass actual debug compilation.
`flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json` PASS:
SHA256 66ec39db51b754685329f12c9436165901eb840544c44c1676df0b10cb162b91.
No installation, iOS build, pilot signing or store publication performed.

Next: detailed attendance/session and full student-profile read contracts/UI.
No further hosted migration is approved. Support remains pending/configurable.

Next local slice: T-023 session-detail read proposal is prepared outside the managed
migrations directory. 31 disposable native PostgreSQL assertions PASS; separate
approval required before hosted changes/UI activation. Review:
docs/SESSION_DETAIL_CHANGE_REVIEW.md. Managed history remains ten / zero pending.
