# Progress pointer

Current milestone: Teacher completion package approved/deployed through
202610190010 (nineteen exact remote SQL bodies verified); hosted synthetic
completion suite 98 PASS. Completion gate enabled; core feature screens wired.
Final 82 Flutter tests PASS, analyzer clean, real hosted SDK and Windows native
navigation/secure-session tests PASS. Configured Android debug APK built and scanned;
owner testing milestone reached. Android physical/pilot/Secretary acceptance open.
See the current milestone at the top of IMPLEMENTATION_PROGRESS.md for final
Flutter/native/APK results. SECRETARY_HANDOFF.md defines the next application's
shared backend setup and separate cross-app/pilot acceptance. Historical entries
below retain their original approval/access limits and are superseded by this pin.

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


### 2026-10-19 — approved session detail deployment and Flutter activation

Only 202610190002 deployed, exact reviewed bytes. Ten baseline local hashes and
remote SQL bodies matched; dry run only the approved version, no seeds/roles,
vault skipped. Eleven-version postflight matched, hash pinned. Hosted read-only
checks passed teacher/tenant/both-secretary/anonymous authorization, empty search
path/grants, existing persisted counts and bounded reads; anonymous REST 401.
No fixture mutation, password or Auth configuration change. Positive pending,
cancelled-history, multi-page and real inactive fixtures unavailable remotely;
local detail suite covers those cases (33 assertions). Password Auth/SDK remains
pending original credentials.

Production T-023/T-024 detail now shows all four read-only status filters, cursor
pages, manual finalization, sync/correction metadata and cancellation actor/time/
reason. Parent views refresh after return; finalized corrections refresh correctly.
59 Flutter tests PASS + 1 hosted opt-in SKIP; final targeted refresh/race checks
PASS. Analyzer PASS; 90 local SQL + 11 native race assertions PASS; manifest eleven
unchanged/zero pending. Debug APK compilation completes successfully; artifact hash
and detailed evidence are in IMPLEMENTATION_PROGRESS.md and
SESSION_DETAIL_CHANGE_REVIEW.md. CI now includes the detail SQL regression suite;
remote CI/device/iOS/signing/cross-app acceptance were not rerun.

Next eligible T-030 read proposal is prepared and locally tested (21 assertions),
not copied into managed migrations/deployed/called by production. Separate review:
STUDENT_PROFILE_CHANGE_REVIEW.md. All existing user edits remain preserved.
