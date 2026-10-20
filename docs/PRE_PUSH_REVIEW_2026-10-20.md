# Pre-push review — 2026-10-20

Scope: all current tracked diffs and new source/assets/tests/docs on main, based
on b524cf4, with focus on authorization boundaries, preview/live routing,
financial and attendance semantics, localization, layout and CI reproducibility.
No commit, staging, push, hosted access, deployment, Auth/account change,
APK generation or app restart performed. Existing unrelated/legacy behavior retained.

## Findings corrected

| Finding | Correction and evidence |
|---|---|
| P2: paid directory badge could open an unpaid profile; illustrative invoice amounts did not reconcile to the summary | One local invoice collection now drives profile amounts and history. Unpaid: 1,900 = 1,300 + 600; paid: 1,900 = 1,900 + 0. Regression checks every fixture, payment flag, invoice sums and settlements. |
| P2: dashboard unpaid count/list was unrelated to the finance balances | Derive both from the complete finance snapshot; five unpaid students and 6,600 outstanding at the fixed date. Rows reuse responsive invoice cards and open exact invoice history. |
| P2: Arabic/Persian target digits were discarded by ASCII-only filtering | Shared localized integer formatter normalizes digits, retains valid selection/deletion and rejects non-integers. Unit and calculator input tests pass. |
| P2: unused-for-grid preview range helper still advanced by 24 hours over DST | Iterate UTC civil dates; Cairo rollback regression confirms unique sessions/dates. Existing grid/today tests retained. |
| P2: new finance proposals and opt-in UI wiring were absent from explicit CI coverage | Added disposable finance business tests and separate debug-preview navigation tests to workflow. Three exact reviewed SQL hashes checked before database startup; LF pinned for these SQL files. |
| Maintainability: several newly touched widgets crossed the repository limit | Extracted directory body, calendar marker row and attendance label; shared calendar palette and surface padding token. No wholesale rewrite of legacy prototype screens. |

## Remaining production gates — not regressions hidden by mock tests

| Priority | Actual remaining work | Evidence |
|---|---|---|
| P1 | New session/group/student/finance screens are still opt-in DEBUG preview; release continues using existing live pages. Live data adapters, loading/error/retry/pagination and real authorization acceptance are required before activating new designs. | lib/core/config/preview_mode.dart; lib/screens/teacher/teacher_workspace.dart |
| P1 | Three new finance RPCs/index are local proposals, not deployed. Receipt method/kind/search filtering and full filtered server totals are still missing; filtering one loaded remote page would be incorrect. Deployment needs a new concrete approval, exact baseline/dry run and postflight. | docs/FINANCE_BACKEND_CHANGE_REVIEW.md; lib/features/finances/preview/finance_movements_list.dart |
| P2 | Live greeting has a generic fallback; actual teacher name is absent from the current validated profile entity/identity RPC response. Add an authorized own-profile display-name read, keeping role/tenant validation authoritative. | lib/screens/teacher/widgets/teacher_greeting.dart; lib/features/auth/domain/entities/teacher_profile.dart |
| P2 | Group notes are local preview data; shared backend currently models teacher notes per student. Keeping group notes in live UI requires an agreed persistence contract, rather than silently losing edits. | lib/features/groups/preview/group_design_detail.dart; supabase/migrations/202610180003_records.sql |
| P2 | Profile contacts copy sample data; QR is a design image. Group/student/session fixtures remain independent, so their cross-tab counts are not an accepted tenant-wide report. Avatar persistence is local to this installation/account, not cloud sync. | docs/FIGMA_STUDENTS_IMPLEMENTATION.md; lib/core/data/local_avatar_store.dart |
| Acceptance | Fresh device/layout/security/performance/recovery and Secretary cross-app tests remain. No latest configured Android/release build was produced during this review, per owner's no-routine-APK request. No fresh hosted verification or remote CI result claimed. | IMPLEMENTATION_PROGRESS.md; historical verification records |

The large legacy prototype screen files were already above 100 lines before this
work; edits there only reuse the clock formatter. Generated localization is exempt
from manual splitting. New/touched feature widgets were split where warranted.
No private-key/secret-key/GitHub-token pattern candidates were found in the scoped
changed-file scan; ignored local credentials/configuration were not printed or staged.
This is not a claim of exhaustive secret-scanner coverage.

## Fresh local validation

- flutter pub get --offline --enforce-lockfile: PASS; lockfile unchanged.
- dart run build_runner build: PASS; zero source-byte changes to generated/current Dart sources.
- Repository-wide Dart format: PASS; flutter analyze --no-pub: PASS.
- Full default Flutter suite: 208 PASS / 1 hosted opt-in SKIP.
- Explicit CENTERLY_UI_PREVIEW=true transport/navigation batch: 3 PASS.
- Final student/unpaid AR/EN renders: 16 PASS; refreshed captures inspected.
- Local SQL/business suites: 343 assertions PASS (90 foundation, 11 concurrency,
  33 session detail, 21 student profile, 98 completion, 22 integrity, 68 finance).
- Disposable PostgreSQL Windows-launcher regression: 2 PASS.
- Nineteen managed migration hashes unchanged; zero pending managed versions;
  three undeployed finance proposal hashes match their review.
- git diff --check: PASS. No new dependency package was introduced by this UI work.

All database tests use disposable local databases/synthetic records. A skipped
hosted test does not establish operational hosted integration. Passing widget
renders does not prove numerical pixel identity or device accessibility acceptance.

## Commit and next task

The work can be committed as a UI-preview milestone with the above limitations.
New source, assets, .gitattributes, tests and documents are still untracked until
explicitly added; a tracked-files-only commit would omit required imports/assets.
Preserve ignored environment files and development credentials outside Git.

Next eligible implementation: connect the new designs to existing deployed
read contracts, complete missing finance receipt-query contracts/adapters and own
teacher-name display, then prepare the reviewed deployment/activation milestone.
Teacher MVP production acceptance and pilot/Secretary cross-app gates remain open.
