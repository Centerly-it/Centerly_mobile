## UI-MOB-039 — Compact centered method selector

Styled the remaining all-records/payment-method selector as a centered compact control (maximum 220px) with smaller theme text, centered labels, soft brand surface, rounded border and dropdown chevron. Preserved 48px dropdown touch height and method behavior. Validation: flutter analyze PASS; two Arabic/English narrow 200%-text connected tests PASS. Next: owner Hot Reload and visual review.

## UI-MOB-038 — Remove record-kind dropdown

Removed the left all-records/collections dropdown from money activity. Method filter remains; requests explicitly use no kind restriction so hidden filtering cannot persist. Removed unused kind callback/state plumbing. Validation: flutter analyze PASS; both Arabic/English connected narrow layout/navigation tests PASS, including fixed-header drag and method-filter changes. No backend or hosted changes. Next: owner Hot Reload.

## UI-MOB-037 — Movement summary spacing

Added 8px below the movement-count/net-results summary before receipt cards, using existing spacing tokens. Validation: dart format and flutter analyze PASS. Next: owner Hot Reload and review.

## UI-MOB-036 — Fixed compact money-activity header

Owner revised UI-MOB-034: month/tabs and money-activity controls are fixed; only the results list scrolls. Group and collector selectors share a row; method and record-kind filters use side-by-side dropdowns, preserving all/collections choices without the removed corrections option. Removed the nested independently scrollable filter panel. Existing server filtering, history, totals and navigation preserved.

Validation: flutter analyze PASS; six connected Arabic/English narrow 200%-text and invoice-layout tests PASS. Connected tests assert filter Y position remains unchanged after dragging results and exercise collections selection (removed obsolete programmatic corrections selection). Evidence: /tmp/centerly-fixed-finance-tests.log. No hosted actions. Next: owner Hot Reload and visual acceptance of fixed finance header.

## UI-MOB-035 — Hide deducted-corrections filter

Removed the deducted-corrections choice chip from live money activity filters at owner request. All-records and collections filters remain; ledger history and exact server totals unchanged. Validation: flutter analyze PASS; both Arabic/English connected navigation tests PASS. Evidence: /tmp/centerly-hide-corrections-tests.log. Next: owner Hot Reload and review.

## UI-MOB-034 — Unified finance scrolling

Finance month/tabs now use a coordinated NestedScrollView header. Movement and dues filters are leading content in the same PagedReadBody list as results, so dragging receipts scrolls controls and the month header instead of trapping movement inside a short results pane. Bottom navigation and shared app bar remain stable. Pagination, refresh, filter state and server totals unchanged.

Validation: flutter analyze PASS; eight targeted scroll, Arabic/English narrow connected navigation, invoice layout and movement adapter tests PASS. Added a drag regression proving outer-header and inner-filter movement; adapted connected navigation to reveal the now-scrollable tabs before tapping. Evidence: /tmp/centerly-scroll-tests.log. No hosted actions. Next: owner Hot Reload and actual device scroll review.

## UI-MOB-033 — Membership heading breathing room

Added 16px vertical padding above and below the student profile membership heading using existing spacing tokens. Presentation-only change. Validation: dart format and flutter analyze PASS. Next: owner hot reload and visual review.

## UI-MOB-032 — Arabic membership and attendance card labels

Refined membership and attendance cards with anchored status chips, compact icon-labeled date/actor rows, localized month dates and a separate subdued cancelled-session history notice. Added translatedLabel fallback to the compiled locale dictionary when hot reload retains an older EasyLocalization dictionary, preventing raw membership_joined_on/ui_recorded_by keys from appearing. Actual saved actor names remain unchanged; no account identity is invented or edited.

Validation: flutter analyze PASS; 11 targeted localization, history, finance layout and connected-design tests PASS, including Arabic/English narrow 200% text layouts and deliberately stale dictionaries. git diff --check PASS. Visually inspected synthetic Arabic widget preview build/ui-review/student-history-ar.png. Evidence: build/ui-review/history-arabic-tests.log. No hosted mutations or backend changes. Next: owner Hot Restart and visual acceptance against their actual records; an English saved account name requires its correct Arabic display name through the authorized account workflow.

## UI-MOB-031 — Student membership/history cleanup and receipt alignment

Implemented requested student-info cleanup: structured membership identity/status and labeled join/withdrawal dates, no internal grade/year label, and removal of duplicate feature shortcut buttons while retaining the four actual profile tabs. Attendance removes denominator/ratio explanation text while preserving server counts/calculation models; history uses compact 12–14px aligned rows with actor names, cancellation history and session-detail access. Added 16px space after academic metrics and finance metrics, removed the finance-basis paragraph, and renamed the payments tab to Collections (including its retained correction history).

Follow-up receipt change: header amount expands to its own end-aligned area (left in Arabic), centered vertically alongside student/payment identity. Existing invoice amounts, signed corrections, collectors and all business rules unchanged. Added exact edge/vertical geometry assertions to all four existing Arabic/English receipt layout cases and two narrow 200%-text membership/history cases.

Validation: full flutter test PASS (281 passed, 1 skipped); flutter analyze PASS. Full run also uncovered older workspace fixtures that did not handle the new unread-count request: added the explicit notification mock response and kept the notification tooltip stable, preserving full-count screen-reader semantics in the badge. No hosted actions, data deletions or migration. Evidence: build/ui-review/student-polish-tests.log, receipt-alignment-tests.log, history-layout-tests.log. Next: owner hot-reloads and reviews all requested student and receipt presentation changes.

## UI-MOB-030 — Teacher unread notification badge

Added NotificationBell to the shared workspace header: red badge uses exact server unread_count from list_teacher_notifications with p_limit=1, hides for zero/unknown, caps visual text at 99+ and preserves the full count in its tooltip. Refreshes on initial mount, return from notifications, app resume and every 30 seconds while foreground; timer stops on pause/disposal. Failed/revoked reads clear the displayed count and existing TeacherReadClient session guards reject stale identities. Existing scoped migration-36 inbox remains the source; no new backend or hosted mutations.

Validation: flutter analyze PASS; five targeted tests PASS (zero/positive/99+ badge and polling-to-zero cases plus connected Arabic/English narrow 200% navigation). Files: notifications/presentation/notification_bell.dart, screens/teacher/widgets/workspace_actions.dart, test/notification_bell_test.dart. Next: owner reloads and checks unread/read transitions in normal use.

## NOTIFY36 deployed and verified — 25 October 2026

Owner approved deployment of only 202610250002_teacher_notification_scope.sql (SHA256 823946e86d5326c23b47adf4b13a4cbd1513a95793abe4c1199bbd6a1b04f17c). All 35 baseline bodies/catalog matched; dry run named only this file. Postflight verified all 36 migration bodies, 78 functions, 18 tables, 30 policies and 29 triggers. Existing business rows, tables, RLS and previous triggers preserved. Canonical manifest and Secretary baseline advanced after successful verification.

Teacher inbox now receives/reads only student_added, student_withdrawn, student_removed and payment_collected; filtered unread/total/page counts agree. Other new Teacher notifications are suppressed; historical rows remain unchanged. Secretary recipients retain existing event behavior, including session cancellation. No notification backfill or ledger/history edits.

Evidence: 30 local native event-scope assertions PASS; 90 baseline local authorization/business assertions PASS with all 36 migrations; 36 manifest hashes PASS; 11 actual hosted authenticated GET-only read/count/permission checks PASS for both Teacher tenants and Secretary. No hosted fixture, payment, student, cancellation or Auth/account changes. New-event hosted mutation acceptance remains pending separately approved scope. See docs/NOTIFY36_DEPLOYMENT.json. Next: owner restarts the Flutter debug app to load labels/spacing and checks future notifications during normal use.

## UI-MOB-029 / NOTIFY36 — Notification spacing and focused event categories

Added 12px under notification read/unread status; added localized new-student, group-withdrawal and removed-student labels and trusted optional student name plus contextual icons. Generated Arabic/English loader updated. flutter analyze and 23 targeted notification/page/label tests pass. Scoped Teacher inbox backend is prepared in canonical review commit 570a4d0: 30 native PostgreSQL checks pass. No hosted deployment. Current inbox still follows the deployed migration-35 behavior until explicit approval of 202610250002_teacher_notification_scope.sql. Review: docs/TEACHER_NOTIFICATION_SCOPE_REVIEW.md. Next: obtain approval for the exact candidate, then verify 35-version hosted baseline and one-version dry run before deployment. No fixture/Auth/production changes authorized.

## UI-MOB-028 — Compact group card spacing

Reduced card padding, header icon size and vertical gaps, count-chip padding and schedule padding; kept text sizes and student-action touch target. flutter analyze passed; three Arabic/English narrow/200%-text group-card layout tests passed. Next: owner hot-reloads to review the smaller card.

## UI-MOB-027 — Refreshed group cards

Redesigned connected group cards with a subtle brand-gradient accent, book icon and clearer identity header, compact member-count pill, separate calendar/time area and prominent filled student-navigation action. Preserved real server counts, grouped weekday/time previews (including effective-window grouping), truncation/empty states, detail navigation and student roster navigation. Extracted focused header, count badge, schedule display and label-formatting widgets; no added dependency, image asset or backend change. Time ranges use an en dash rather than an ambiguous colon.

Validation: flutter analyze PASS; 7 targeted widget/navigation tests PASS (three new Arabic/English 320/390-width 100/200% text layouts, live group search tests and existing connected design routes). RTL chevron direction is explicit to avoid double mirroring. Synthetic design screenshot: build/ui-review/group-card-ar.png. No hosted mutations or install. Next: owner hot-reloads and reviews the refreshed group list.

## UI-MOB-026 — Remove raw group-search label

Removed visible live_group_search from the group picker search field. Search icon, keyboard submission and localized screen-reader label remain; other search fields retain their labels. Changed server_search_field.dart and teacher_group_filter.dart. Validation: dart format and flutter analyze passed. Next: owner reloads the current Flutter session.

## UI-MOB-025 — Organized invoice and connected detail presentation

Implemented in the actual current Teacher checkout: shared AppInfoRow; invoice identity/status, outstanding hero and paired amount/paid summary; organized receipt/correction cards, student financial records, daily collection rows, group details, notification summaries and payment notification sheets. Reused ColorManager/StyleManager/AppSurface components and Material icons; Arabic/English labels regenerated. Existing structured attendance/academic tables, session panels and contact/note sections retained. No backend or finance logic changed.

Changed files: core/widgets/app_info_row.dart; finances/presentation live_invoice_detail, live_invoice_summary, finance_amount_summary, live_receipt_card, finance_record_card, teacher_finance_page and design/finance_detail_line; groups/presentation/live_group_detail; notifications/presentation teacher_notifications_page, notification_summary and notification_payment_button; both locale sources and generated loader; organized_finance_layout_test with synthetic fixture helper. Existing live_groups_test had obsolete ActionChip expectations against the already-removed UI; updated search/empty/no-grade-control coverage.

Checks: flutter analyze PASS; full flutter test PASS (270 passed, 1 skipped). Four new narrow/large-text Arabic/English layout cases; visual inspection of build/ui-review/invoice-ar.png; all connected navigation/finance regressions pass. No hosted operations, account changes, publication or install. See docs/MOBILE_INFORMATION_LAYOUT.md. Next: owner reloads current Flutter debug session and reviews invoice/receipt and supporting detail layouts on their device.

## 2026-10-24 — Direct attendance, development migration 34

Owner-requested removal of attendance approval: Secretary has no finalize action, manual-mode notice, finalization metadata or correction-reason field. Status choices save immediately; unmarked students remain unmarked. Existing finalized sessions can be corrected without a reason. The retired finalize RPC no longer grants execute to authenticated clients; historical metadata and immutable change logs are preserved. Tenant, role, cancelled-session and optimistic-concurrency checks remain enforced.

Session badges and history grouping use starts_at/ends_at, with a one-second foreground clock and focus refresh. A session completes only at its end time; cards display both start and end. Hosted APIs already derive status from timestamps, independently of attendance.

Deployed only 202610240002_direct_attendance.sql after a verified 33-version history/catalog baseline and dry run naming only this migration. Postflight matched all 34 migration bodies, 73 functions, 18 tables, 30 policies and 25 triggers. All 18 table fingerprints and financial totals matched pre/post; no hosted fixture or account mutations.

Validation: 39 Secretary unit tests; lint/typecheck/configured web build; 2 isolated SQL-fixture browser attendance tests (desktop/mobile); 9 native SQL-role direct-attendance assertions; baseline 90 assertions; Secretary contract 59 checks; concurrency 11 and Secretary concurrency 34; actual authenticated hosted Chromium 5 read-only checks. These are automated checks, not owner or physical-device acceptance. Teacher APK unchanged.

## Current checkpoint — dated classes and stable resume, 24 October 2026

Owner-requested development changes implemented and migration 33 deployed/verified once to centerly-dev. Weekly timetables have no dates/generation/add-appointment flow; group details edit the weekly timetable. Separate Create Class selects group/date/time and Included or Additional pricing (owner explicitly merged free into included). Extra per-student invoices and attendance are atomic/idempotent; late enrollments before class reconcile once, history retained. Same-user web auth events no longer clear screens/cache; Teacher background checks retain workspace and lazy tab state, with scoped last-tab persistence. Native splash/normal themes white in light/dark mode. No hosted business mutations/fixtures, account changes or production publication. Full 33-version history/catalog/grants and all prior row fingerprints/financial totals verified. Local 28 SQL-role checks, 90 baseline SQL checks, 38 unit tests, 22 synthetic browser tests, 29 targeted Flutter checks and analyzer/build pass. Actual SDK guards/reads and browser forms/focus verified without successful writes. New configured APK ready, USB absent, not installed; owner manual/device acceptance outstanding. See docs/MANUAL_CLASSES_AND_RESUME.md/json. Earlier 32-version checkpoints are historical.

## Current checkpoint — safe student/group deletion, 23 October 2026

Active student/group list rows and details now have Delete buttons with two warnings, exact record name and required acknowledgment before final submission. Existing secretary_archive retains history/payments and group students; no SQL deletion, migration or hosted business mutation. Dashboard excludes archived-group sessions. Baseline remains 32. Local 37 unit tests and 20 synthetic SQL-fixture desktop/mobile browser scenarios pass, including cancel/no request, required second acknowledgment and unchanged payment history. Actual connected browser opened both confirmation flows and canceled, with all business writes blocked. See docs/SAFE_DELETE.md/json. Development website ready; owner manual/device testing outstanding.

## Current checkpoint — multi-day group form, 23 October 2026

Migration 32 deployed and verified on centerly-dev after owner standing authorization. Group creation has weekday checkboxes and required hour/minute plus AM/PM selects; visible date removed, Cairo today supplied by server. All selected days saved atomically with immutable idempotent audit; failures roll back every day/group. Existing schedules, financial totals and all 18 table row fingerprints preserved. Full 32 history bodies/catalog/grants verified (69 functions, 24 triggers); first CLI history read failed to connect and read-only retry passed. Both manifests updated. Local 15 SQL-role assertions, 90 Teacher baseline checks, 37 client unit tests and all 16 synthetic browser scenarios passed (one focused rerun after search-test locator fix). Actual connected browser verified 18 read-only checks, including three selected days, no date and AM/PM dropdown. No hosted fixtures, group submissions, account changes or publication. Website http://127.0.0.1:5173/ ready for owner testing; no manual/device pass claimed. See docs/MULTI_DAY_GROUP.md/json. Earlier 31-version checkpoint text below is historical.

## Current checkpoint — required group schedule, 23 October 2026

Owner authorized immediate backend implementation for requested development changes without further approval. Migration 31 deployed/verified on centerly-dev. New secretary_create_scheduled_group atomically requires group+schedule; direct group INSERT revoked, legacy unscheduled creation rejected. Calendar shows all active groups and all current/future weekly schedules; both existing owner groups currently need the owner to set times. No invented schedules or hosted business writes. Full 31-version history/catalog/grants verified; all 18 table row fingerprints and financial totals unchanged. Both manifests advanced. Local 20 SQL-role checks, 90 Teacher baseline assertions, 36 Secretary unit tests and 16 synthetic desktop/mobile browser scenarios passed. Actual connected Chromium: 15 read-only checks, 2 groups shown. See docs/REQUIRED_GROUP_SCHEDULE.md/json. Website ready at http://127.0.0.1:5173/; owner manual/device testing remains outstanding. Earlier version-30/pending statements below are historical.

## Current checkpoint — FIN30 deployed, 23 October 2026

Owner-approved exact FIN30 transaction deployed once to centerly-dev as migration 30. Both manifests advanced after full history/catalog/grant/trigger verification. All 18 table row fingerprints and financial totals unchanged. Connected local financial editing enabled. Actual SDK: 47 read-only checks, 3 existing invoices; connected Chromium: 11 read-only checks with renewal stubbed. No current payment exists for hosted payment-edit UI verification; local 26 SQL-role and 16 synthetic browser tests cover financial edits, zero values and retry. Secretary 36 unit tests/lint/build pass. No business mutations, fixtures, cleanup, account changes or publication. See docs/FIN30_DEPLOYMENT.md/json. Local owner testing ready at http://127.0.0.1:5173/; phone absent, manual/device acceptance outstanding. All earlier pending FIN30/29-version checkpoint text is historical.

# Simple daily workspace — 2026-10-23

One schedule navigation entry with recurring group/day/time cards and per-day edits. Header shows actual teacher and secretary names. Groups use dropdowns without search; new prices start blank. Direct edit links simplify daily work. Operational payment views show current collections while preserving raw ledger history.

No hosted business/schema writes, resets, account changes or new fixtures occurred. FIN30 financial editing is prepared locally, NOT deployed or registered; both manifests remain at 29 and connected financial saving is disabled pending the exact review in SIMPLE_FINANCE_EDIT_REVIEW.md.

Validation: Secretary 36 unit tests plus lint/build; 16 synthetic SQL-fixture browser scenarios across desktop/mobile; 26 local PostgreSQL SQL-role checks; Teacher 14 targeted tests plus analyzer/configured APK build. Actual authenticated connected Chromium: 9 read-only UI checks, zero business writes. Renewal RPC was guarded/stubbed by the probe, not encountered. Device absent from ADB; no physical acceptance or new installation claimed.

Web: http://127.0.0.1:5173/. Configured APK SHA256: aefc8ec616ab204cad2d72dabc4b9ae1955f502f40316786d0a53a81a4a59fd2. Artifact inventories refreshed; decompressed APK and web credential scan found zero matches. Production remains deferred. Remaining owner actions: approve FIN30 for development deployment to enable financial edits; reconnect phone for installing this APK and owner testing.

Proposed shared API: secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text), with expected-value concurrency protection, transaction locks and idempotent immutable audit. original_amount_egp remains original face; amount_egp is adjusted effective total; ledger_net_egp and payable_balance_egp retain their existing meanings. No ledger rows erased. Teacher movement history remains complete and prepared parsers allow zero adjusted dues. Connected finance-edit flag stays false until approved deployment.

23 October dues search simplified: one student-name search input on invoices, removed the group picker/search and ignored stale URL group filters on that screen. Existing RLS-scoped RPC is unchanged; the client reads authorized invoice pages and searches student_name only, retaining accurate matching totals/pagination and existing amount values. Arabic normalization supported. 33 unit tests/lint/typecheck/build PASS; connected Chromium confirmed one input and group picker absent, zero business writes (renewal RPC stubbed in the read-only check). No data/schema changes.

23 October owner-requested reset R3 completed: all 16 development business tables empty after removing 16 owner test rows, with all four existing account profiles unchanged. Separate private backup restored and FK-verified locally. Educational level removed from Secretary student create/edit/details/list; new students send null level. 31 unit tests, 14 unaffected browser cases and two corrected targeted desktop/mobile workflows PASS; actual connected read-only browser six checks PASS. Migration baseline remains 29; no fixture replay, Auth or schema changes. See docs/OWNER_RESET_R3.md.

CURRENT 23 October: owner-approved R2 deployed and verified on centerly-dev as migration 29. Connected creation/billing enabled; grade-level UI removed. All business data remains empty. Earlier pending/28-version statements below are historical. See docs/R2_ACTIVATION_ACCEPTANCE.md.

23 October creation simplification R2: masculine Arabic instructions; student creation requires an active owned group or prompts to create one first. New reviewed RPCs atomically create student/enrollment/billing and retry safely. Group form/list/details omit capacity, and creation omits the year search/chooser; internal reference/capacity are server-owned. Local SQL 40 checks PASS. Pending review regenerated with a new hash; no hosted schema/data/Auth writes. New creation saves remain gated until reviewed backend activation.

23 October owner reset/pricing update: explicit dev-only reset completed, 222 synthetic business rows removed from 16 tables; all four accounts unchanged, backup restored and verified locally, 73 actual SDK/browser checks PASS. Migration 28/catalog unchanged. Enrollment-anniversary group pricing, recurring catch-up, atomic transfer and simplified payment UI prepared locally (31 SQL checks / 14 synthetic browser tests PASS), awaiting required concrete backend review approval. Configured Teacher APK rebuilt; current adb device list empty, installation/manual acceptance unavailable. See docs/OWNER_RESET_AND_PRICING_ACCEPTANCE.md and docs/GROUP_PRICING_REVIEW_AR.md. Historical retained-fixture statements below are superseded.

23 October - owner-requested simplification complete: daily Secretary home without teacher income aggregates; Arabic named classes; direct attendance/student collection/transfer entry; named weekdays and polling notifications. Teacher QR removed from connected/preview/legacy profile UI, guardian WhatsApp intent normalized with safe fallback. Separate OWNER28-AR Arabic fixtures created once; existing 18-table history preserved. Actual hosted browser seven read-only checks, two-account guardian-field round trip (two reserved-value edits restored), Secretary 28 unit/local SQL browser 14 tests and Flutter targeted19/analyzer PASS. Updated APK installed/launched on Redmi. No agent attendance/payment/cancel/notification mutations; no account/Auth/schema changes. Owner manual checks remain pending. See SIMPLE_DAILY_WORK_AR.md and SIMPLE_FLOWS_ACCEPTANCE.md/json.


23 October final local handoff: approved migration 28 deployed; all 18 business-table fingerprints unchanged; 37 actual SDK read checks and actual Secretary Chromium/Windows Teacher archived-navigation checks PASS. Final APK a7f2d490be888d34d71b7a9f35ad8a7a72422bf8e27692c28b73eb32b7227a76 installed/launched on Redmi Note 9S. Targeted Flutter 20, Secretary 25 tests and analyzer PASS. Read PILOT28_ACCEPTANCE.md/json and OWNER_LOCAL_TESTING.md. Manual/device acceptance is pending. Fresh operational mutations await OWNER28_SYNTHETIC_SCOPE.md approval; production decisions are deferred.
## Current local-owner milestone — 23 October 2026



Production hosting, paid services, distribution signing, privacy launch and real onboarding are deferred and are not local-testing blockers. The exact approved migration 202610230001 is deployed to centerly-dev; existing synthetic records/history were preserved. Secretary is running at http://127.0.0.1:5173 in connected development mode. A configured non-preview Teacher debug APK was built and installed successfully on the connected Redmi Note 9S (Android 12, API31); launch command succeeded. Phone/manual acceptance has not passed by inference. See OWNER_LOCAL_TESTING.md and the proposed OWNER28_SYNTHETIC_SCOPE.md. New fixture mutations require scope approval; existing retained records are read-only. Historical launch gates below do not redefine this local milestone.



# SEC27 hosted acceptance complete — 22 October 2026



The owner-approved bounded SEC27 package and consolidated note/removal addendum completed on centerly-dev. Actual Supabase SDK/REST, Secretary Chromium and Windows Teacher UI acceptance passed. Thirteen audit events (limit 23), five attendance changes (limit 6), seven notifications (limit 8), exactly two note saves and one pending removal request are retained. Atomic guarded void cleanup ran once; both tenants’ complete financial totals and unrelated record digests match their pre-run baselines. Secretary-a remains active. No account/password/Auth configuration, migration, production deployment, push or publication occurred.



Current results and retained records: [SEC27 acceptance](docs/SEC27_ACCEPTANCE_2026-10-22.md), [detailed evidence](docs/SEC27_ACCEPTANCE_2026-10-22.json), [shared checklist](docs/SHARED_COMPLETION_CHECKLIST.md), [matrix](docs/CROSS_APP_ACCEPTANCE.md). Remaining gates: separate production/signing/privacy/support, provider recovery/monitoring, physical Android/iOS and remote CI/access. Archived-student RPC boundaries are documented; invoice/session histories remain retained/readable. Completed-run guards prohibit reseeding or repeated cleanup. Older unapproved-fixture/credential-absent statements below are historical.



# Current shared pilot checkpoint — 22 October 2026



Teacher remains canonical migration owner. All 27 deployed versions through `202610220002` are now present and hash-pinned here; fresh hosted history/full catalog match. No hosted schema/config/business changes ran. The previously missing original four-account credential file is available on this Windows machine and was read only in memory. Real SDK/Secretary Chrome and native Windows Teacher Auth/read-route checks passed. The configured Android debug APK built; physical-device/cross-app business acceptance remains gated.



The authoritative shared checklist is [SHARED_COMPLETION_CHECKLIST.md](docs/SHARED_COMPLETION_CHECKLIST.md); the [acceptance matrix](docs/CROSS_APP_ACCEPTANCE.md), [evidence](docs/PILOT_EVIDENCE.json) and [operations/runbook](docs/PILOT_OPERATIONS.md) separate passed checks from release gates. Secretary exists at `D:\ahmedtamer\Centerly_secretary`. Both initial worktrees were clean; this checkpoint preserves designs and existing immutable migration bodies. The migration-27 source is imported unchanged from the approved Secretary review, not newly deployed. Historical 26-version/credential-missing/future-Secretary statements below are superseded.



# Centerly implementation progress



## Teacher owner-testing implementation complete; Finance26 deployed — 2026-10-22



Owner explicitly approved only202610220001 with SHA256

`e59af624e58ddb7875fc59c6f02278806fcdb8eb8c93ec8b0765a17848e2eedf`, development

centerly-dev, and read-only verification. Rechecked healthy project/ref, exact25

baseline bodies/full catalog (44 functions,18 tables,30 policies,0 enrollment

violations), old hashes and exact proposal bytes. Dry run listed only that file,

no seeds/roles; --skip-vault. Applied once, no old migration replay.



Postflight exact26 bodies/full catalog PASS:45 functions,18 tables,30 policies,

0 enrollment violations. Approved function body/definer/search_path/execute grants

match local schema; no unrelated catalog change. Read-only existing synthetic

records:60 filter combinations,230 limit-one pages,2,466 teacher checks, maximum

report22 rows and9 existing corrections. Every page's full filtered count/gross/

correction/net matched an independent ledger reference; signed amounts, no loss/

duplicates, original/current attribution, tenant/entity filters and invalid inputs

verified. Additional other-teacher scope, Secretary and anonymous denials PASS;

anonymous publishable-key REST401. This is SQL-role/anonymous HTTP evidence, not

password-based SDK acceptance. No account/status/Auth changes, financial writes,

fixture mutations or data repairs occurred.



Only after all postflight checks passed: pinned26 in schema-manifest, enabled

CENTERLY_FINANCE_MOVEMENT_FILTERS by default and in connected VS Code launch, and

added the new RPC to the explicit offline test transport. No production preview

substitution. Final dry run up to date (zero migrations/seeds/roles). The original25

managed files remain unchanged. New bytes retain the approved hash and LF pin.



Fresh checks: Flutter251 PASS/1 hosted Auth opt-in SKIP; activated AR/EN200% UI plus

adapter3 PASS (including corrections-empty/clear); explicit preview3 PASS;

analyzer/format/diff clean; local26 foundation90 + movement29 =119 SQL assertions

PASS. Pinned26 remote history/catalog comparison and manifest checks PASS. No build

or restart was run in this deployment follow-up, as requested. The earlier Android

synthetic smoke remains historical evidence, not a new enabled-filter native test.



Implementation milestone: COMPLETE for agreed Teacher owner-testing scope. T-033

production adapter/receipt filters DONE; connected route/action checklist retained.

No pending implementation/backend approval blocks that scope. Attendance full-text

search across pages remains unavailable (status filters/paging work); group notes

are explicitly excluded and QR/cards/scanning deferred. No optional feature added.



Acceptance milestone: PENDING original development credentials, which owner says

are unavailable. Exact expected ignored local file:

`/Users/mohamedsalem/Desktop/Centerly_mobile/.env.development-accounts.json`.

Do not create/reset accounts or expose credentials. Fresh password login/restore/

refresh/logout/role denial, connected owner reconciliation, and final configured

Android/contact acceptance remain unverified. These are acceptance gates separate

from implementation gaps. Pilot signing/recovery/future React matrix remain

separate and do not block the Teacher implementation milestone.



Updated testing guide, backend compatibility/contract, deployment record and

Secretary handoff. Final owner-requested build uses .env.local.json with

CENTERLY_UI_PREVIEW=false and CENTERLY_FINANCE_MOVEMENT_FILTERS=true; exact command

in docs/TEACHER_OWNER_TESTING.md. No new build produced. Next: owner restores the

original credentials/requests final build, then authenticated acceptance; Secretary

inherits identical26 migrations/history without replay. Working changes remain

uncommitted; unrelated startup/splash/router/test/lockfile edits preserved.



Evidence: docs/FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md and ignored

build/finance-movements-deployment/. All older25-version/default-off/pending-approval

entries below are historical and superseded by this26-version checkpoint.





## Teacher connected-design owner-testing checkpoint — 2026-10-22



Resumed from actual main `a3bb5e0`, not the stale October19 completion pointer.

Preserved the six pre-existing startup/splash/router/test/SDK-lock changes exactly

(46 insertions/86 deletions). No reset/stash, commit/push or backend deployment.

Current Mac: Flutter3.47.2/Dart3.13.2; existing local SDK resolutions retained,

no new dependencies. Public config verified against centerly-dev/publishable key.



Implemented production FinanceRepository/DTOs and connected redesigned overview,

filtered dues and invoice-detail/history to deployed reads. Complete server totals

are distinct from paged rows; exact BigInt cents, negative period cash, historical

creator/collector/corrector/reversal attribution retained. Filters precede server

pagination; strict UUID order/cursor and monetary reconciliation reject malformed

responses. Shared calculator uses complete server summary and no example target.

Student invoice history uses the designed amounts, preserves void records and opens

real invoice/receipt history. Parent Finance lists refresh after detail return.



Connected shared Groups/Students/Profile/Calendar/Session designs to existing

repositories: real bounded schedules/upcoming sessions/rosters, server directory

search and group filters, contacts, membership history, academics/attendance/

finance tabs, calendar markers and attendance/cancellation history. Missing badges

and absent roster counts are withheld instead of filled with preview values.

Teacher attendance/academics/finance remain read-only. Existing durable student

notes/removal/notification actions retain their secured flows. Home gets a real

dues drilldown without inventing a distinct-student unpaid count.



Trusted teacher name uses the existing narrow RLS teachers.name SELECT after profile

validation, with safe fallback/token guards. Real contact URIs validated; failures

offer translated copy fallback, no automatic messaging. QR cards/scanner deferred

per approved plan; no placeholder QR in connected mode. Owner explicitly excluded

group-note editing for this milestone; unavailable message, no fake saved notes.

Full route/action/scope checklist: docs/TEACHER_OWNER_TESTING.md.



Fresh evidence (ignored build/owner-testing/):



| Check | Actual result / scope |

|---|---|

| Remote baseline | Exact25 migration bodies,44 functions,18 tables,30 policies plus catalog/grants/RLS/indexes/triggers/constraints match; enrollment violations0 |

| Managed manifest |25 hashes unchanged;0 pending managed versions; no replay/deployment |

| Hosted read-only SQL |13 synthetic actor assertions PASS: trusted name, cohort/cash/dues/detail, tenant isolation and teacher-only denial. SQL role simulation, not SDK/password Auth |

| Flutter full suite |251 PASS,1 hosted Auth opt-in SKIP; final run after native ink fix |

| Explicit preview tests |3 PASS with CENTERLY_UI_PREVIEW=true |

| Connected design traversal |2 PASS, AR/EN at320px/200% text; explicitly synthetic transport, not hosted UI |

| New receipt adapter |1 PASS with CENTERLY_FINANCE_MOVEMENT_FILTERS=true; full filtered total independent of partial page |

| Final route regressions |16 PASS after retaining the compatibility gate on profile tabs |

| Analyzer / format / diff |PASS, no issues; changed Dart formatted, unrelated user files preserved |

| Connected bundle |flutter build bundle --debug --no-pub with local config and preview=false PASS; no owner APK claim |

| Local PostgreSQL |Foundation90 + deployed-finance transition68 + hardening30 + new movement proposal29 =217 assertions PASS, disposable local DB |

| Android native smoke |1 PASS on Centerly_Dev/emulator-5554, Android17/API37; actual secure-storage write/read/delete, native URL-handler query and current connected Finance shell with synthetic transport |



First native build took532.8s fetching Gradle dependencies, then exposed a real

ListTile ink/ColoredBox assertion in the calculator link. Fixed with Material;

second build15.5s, install and native smoke PASS. This was a test-harness APK, not an

authenticated owner build; moved to ignored build/owner-testing/native-smoke-test.apk

to avoid distributing it accidentally. No repeated app restarts after UI edits.

External call/WhatsApp completion, physical-device performance, password login/

restore/revocation and real connected route reconciliation remain unverified.



Remaining genuine inputs:



- Original development credential file unavailable (owner confirmed). Do not

  create/reset accounts. Fresh hosted Auth and authenticated owner acceptance are

  BLOCKED on those credentials, not on the future React application.

- Receipt search/method/kind is absent from the25-version deployed API. Prepared

  exactly one teacher-only additive read proposal, locally29 PASS and SHA-pinned:

  docs/TEACHER_OWNER_BACKEND_REVIEW.md. Outside managed migrations, undeployed,

  default-false feature flag; no partial-page filtering or previous approval reused.

  Baseline date/group/collector reports work now; complete receipt-filter acceptance

  needs explicit approval, single-version deployment and fresh verification.



Readiness: connected implementation completed locally to the credential/approval

boundary; do not label authenticated owner-testing milestone accepted yet. Exact

one final configured owner build command is in docs/TEACHER_OWNER_TESTING.md.

Pilot signing/recovery/physical-device and Secretary cross-app acceptance are

separate in docs/PILOT_RELEASE_GATES.md and docs/SECRETARY_HANDOFF.md.



Task state: T-033 IN_PROGRESS at full receipt-filter approval boundary; T-021/

T-022/T-023/T-030..034 connected source and local regressions implemented; T-050

fresh Auth acceptance BLOCKED by missing credentials. Implementations remain

uncommitted in the working tree for review; baseline SHA above is not a claim that

these changes were already committed. Next action: restore original credentials,

approve only the reviewed receipt read if full filters are required, run final

connected acceptance, then proceed to Secretary React without replaying the schema.





## Repository handoff packaged for push — 2026-10-20



Owner requested all changes on main plus a complete new-computer report.

PROJECT_HANDOFF.md now consolidates actual UI/live status, business semantics,

25-version deployment, exact test evidence, ignored local config/credential transfer,

secure setup/launch commands and remaining finance/device/Secretary tasks. README,

SETUP and SECRETARY_HANDOFF point to the current snapshot/version. Remote main was

fetched and matched0577486 before preparing the commit; no merge/reset needed.

Staged-files scan excludes local env/credential values, private keys and runtime

artifacts. Existing19 managed contents unchanged; all25 manifest pins pass. The

commit containing this entry is the transfer snapshot; use git log for its ID.

No new hosted mutation, build or restart is part of this push request.





## Approved hardening deployed — 2026-10-20



Owner explicitly approved the reviewed six-file package. Verified CLI auth and

linked centerly-dev identity. Fresh preflight:19 exact remote bodies plus matching

catalog/grants/RLS, enrollment violations0. Exact six SHA256-pinned files copied

to managed migrations; dry run contained only202610200001..006; all six applied.

Postflight verified25 exact remote bodies and full catalog,44 functions/18 tables/

30 policies, both indexes and approved NOT VALID timeline constraint. Existing19

files unchanged; schema-manifest now pins25. No Auth/account changes/backfill.



Real hosted validation:98 completion +37 hardening =135 business assertions PASS;

Flutter SDK Auth1 PASS (existing synthetic teacher/Secretary credentials). Verified

payment/reversal retry/exactly-once notifications, void preservation, transactional

rollback, attendance start/end/cancellation/overnight/selected-day semantics,

corrections, removal handling and tenant/role denial. Only approved synthetic

fixtures mutated; temporary attendance boundary data rolled back. No new customer

or account provisioning/data scope. Full25-version local regression results in

build/hardening-local-*.log; earlier audit Flutter240+preview3 remain historical.



Ongoing dashboard scope detection can now display fresh server counts after

refresh. New finance reads are deployed/verified, but redesigned Finance remains

debug preview pending production adapters. Remaining UI/live/device/pilot/Secretary

gates still apply. Next eligible implementation: production finance adapters and

cross-screen reconciliation. No APK/restart, staging/commit/push or publishing.

Evidence: docs/HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md. Earlier LOCAL ONLY

entries below describe pre-approval state and are superseded for this package.





## Deep main logic/performance hardening — 2026-10-20



Verified local main starting 0577486; initially clean. Implemented bounded,

project/user/token-scoped memory TTL cache with duplicate-read coalescing, stale

response guards, Auth logout/restore race fixes, exact indexed finance snapshot

calculations/validation, parallel dashboard reads, strict cursor progression,

bounded avatar decoding/storage and cheaper calendar marker generation. Profile

verification follows first frame while protected routing remains gated. Removed

raw legacy backend error logging. No new dependencies or lockfile change.



Owner clarified «الحضور في السنتر الآن» = ongoing-session attendance independent

of selected day; unmarked label = «لم يُسجّل». Prepared SQL006 with server-time

start-inclusive/end-exclusive/cancel/overnight semantics and index. UI requires

scope/timestamp before showing current counts; old daily totals are withheld.

Snapshot timestamp + manual refresh, not realtime physical occupancy.



Fresh: Flutter240 PASS/1 hosted opt-in SKIP; explicit preview3 PASS; analyzer and

format clean; enforced offline lockfile and codegen PASS; existing PostgreSQL343

+ hardening30 =373 assertions PASS; Windows PostgreSQL launcher2 PASS; all19

managed hashes unchanged. Local load/reference arithmetic benchmarks passed;

measurements/limits and initial test-fixture failure/fix in audit report.



Six LOCAL ONLY SQL proposals202610200001..006: three finance reads/covering index,

void-preserving settlement helper, NOT VALID enrollment timeline check, ongoing

attendance overview/index. Existing19 migrations untouched; no deployment or new

approval assumed. Revised001 hash invalidates prior proposal bytes. Historical

invalid enrollment rows require read-only preflight/owner-reviewed repair; no

backfill authorized. Exact review: docs/MAIN_HARDENING_CHANGE_REVIEW.md.



NOT production-ready: redesigned screens/finance are still debug preview; real

finance adapters, generic teacher name, group-note persistence, QR/contact behavior,

fresh hosted acceptance and device/pilot/Secretary matrix remain open. See

 docs/MAIN_LOGIC_PERFORMANCE_AUDIT.md for concrete findings, cache policy, measured

limits and next eligible sequence. No hosted access/mutation, commit/push, APK

build or restart during this audit. Earlier ledger counts are historical.





## Pre-push review and fixes — 2026-10-20



Reviewed all tracked diffs/new source, local SQL proposals, assets, localization,

preview/live entry points and CI. Fixed paid-badge/profile/invoice-history conflicts

using shared synthetic invoice records; dashboard unpaid card/list now shares the

finance ledger and opens invoice history (five students/6,600 at fixed review date).

Normalized Arabic/Persian target digits with a reusable integer formatter; corrected

remaining civil-date range iteration across Cairo DST. Split directory/calendar/

attendance widgets and centralized calendar colors/shared padding tokens.



CI now runs the finance proposal suite with exact review-hash guards and explicit

opt-in UI navigation. Proposal SQL LF bytes are pinned for cross-platform checkout;

no managed migration changed and no proposal was deployed. No new package needed.



Fresh: enforced offline lockfile PASS/unchanged; build_runner PASS with zero source

byte changes; format/analyzer PASS; full Flutter 208 PASS/1 hosted opt-in SKIP;

explicit preview transport/navigation 3 PASS; refreshed student/unpaid renders

16 PASS. Local SQL suites total 343 assertions PASS; Windows PostgreSQL launcher

2 PASS; nineteen managed hashes/zero pending PASS; three proposal pins PASS.



Readiness: UI-preview milestone can be committed; NOT production activation.

New designs are debug-gated, finance queries/adapters/deployment remain incomplete,

live teacher name is still generic, group notes lack a persistence contract,

contacts/QR remain preview, and device/pilot/Secretary acceptance remains open.

Student/group/session samples are still separate across modules; do not infer

whole-tenant reconciliation from widget tests. Report and exact next task:

docs/PRE_PUSH_REVIEW_2026-10-20.md. Existing earlier verification entries are

historical and do not override these current limitations.



No staging/commit/push, hosted access/mutation, Auth changes, APK build or restart.





## Business-first finance preview — 2026-10-20



T-033 UI/business milestone only; hosted end-to-end acceptance is NOT completed.

Replaced the debug preview Finance screen with month-scoped overview, searchable

invoice dues/status filters, invoice history, receipt/correction details, actor/

method/kind movement filters and local collection/target calculators. Preserved

shared app bar/navigation and teacher financial read-only permissions. Exact BigInt

piastres underpin all balances; decimal details survive, whole values are grouped.

Due-date invoice settlements reconcile separately from receipt-date cash. Full

correction/original references and creator vs collector vs correction actor remain

distinct. Date/month changes reset dependent filters; no future receipts fabricated.

Arabic/English and narrow/enlarged text layouts covered. Preview figures are local

synthetic fixtures, not operational teacher data.



Related business correction: dashboard due-cohort settlement card now consumes

paid_against_invoices_egp rather than period_net_collected_egp. Updated its mock

contract to test distinct receipt/settlement values. Dashboard preview totals share

the finance fixture; existing student-profile/unpaid design samples remain separate

and are not evidence of cross-screen live reconciliation.



Three additive LOCAL proposals (202610200001..003) provide teacher-only aggregate

finance, attributed invoice history and filtered/paginated dues; one payment/invoice

index. No managed migration or existing nineteen bodies changed. Exact hashes,

effects, permission/date semantics and remaining receipt-filter adapter work are in

docs/FINANCE_BACKEND_CHANGE_REVIEW.md. Not deployed/activated or freshly verified

against hosted Supabase. Shared contract explicitly marks these as undeployed.



Fresh validation: complete Flutter suite 202 PASS / 1 hosted opt-in SKIP;

`dart analyze lib test` clean; final finance render/navigation batch 20 PASS,

including AR/EN 320px at 200% text; six domain arithmetic/fixture tests passed.

Fourteen screenshots under docs/screenshots/finance inspected for key layouts.

Disposable PostgreSQL finance proposal tests: 68 assertions PASS, covering exact

cents, cross-cohort receipts, different correcting actor, signed actor totals,

Cairo midnight boundaries, tenant/role/anon/inactive/subscription denials,

historical attribution/archive visibility, pagination and totals, index/search_path

and absence of read-triggered notifications. git diff --check passed.



No hosted access/mutation, deployment, Auth changes, restart, APK build, commit or

push performed. Current new finance UI remains gated by debug CENTERLY_UI_PREVIEW;

existing production LiveFinance is retained. See docs/FINANCE_BUSINESS_DESIGN.md.

Next eligible work: owner UI review; then complete remote receipt query contracts

and live adapters, obtain a concrete deployment approval, postflight and device/

Secretary cross-app acceptance. Do not treat mock tests as completion of T-033.





Student empty-search illustration (2026-10-20): student directory now uses the

exact attendance-search image and aspect ratio through shared AppSearchEmpty.

Attendance delegates to the same shared widget; localized directory copy retained.

Focused analyzer clean; 11 directory-filter/session-render tests PASS, including

assertions for the exact shared image asset. No restart or build.



## Teacher student-creation control removed — 2026-10-20



Owner clarification overrides the reference add button: removed it from the

student directory together with its local callback, dialog and unused translations.

Search, filters and profiles retained; no hosted permissions changed. Replaced

local-add test with a regression asserting no creation action in the Teacher UI.

Validation: focused analyzer clean; seven permission/filter/navigation/translation

tests PASS. No restart, APK build or hosted mutation.



## Figma students section — 2026-10-20 (current UI milestone)



Implemented six adjacent frames 961:5521 / 5540 / 5597 / 5669 / 5743 / 5810 from

high-fidelity context and screenshots: directory, level sheet, profile information,

attendance, academics and payments. Debug preview only; shared workspace app bar

and five-tab navigation retained, connected student flows/backend unchanged.

Search and combined level/group/payment filters, clear/cancel/apply, local name

validation/addition, selected-student note editing and all four profile tabs are

interactive. Workspace-owned synthetic students preserve local edits across main

tabs. Shared surface panel/section and identity widgets avoid repeated layout;

Arabic/English localization and original exported assets included.



Design data correction: attendance rate is computed as 24/30 = 80%, rather than

inconsistent reference 85%; full student name stays consistent across views.

Grouped whole-pound payment display and exact 1,900 = 1,300 + 600 summary retained.

Contact actions expose only sample-number copying; reference QR is a design image,

not an active attendance credential. Add/notes remain in-memory fixtures; Teacher

hosted creation permissions are not changed. No hosted operational claim.



Validation: full analyzer clean; full Flutter suite 176 PASS / 1 hosted opt-in SKIP.

That run includes 12 AR/EN state renders, 12 320px/200% cases, filter reset/cancel,

local add/note validation and isolation, profile navigation and summary arithmetic,

plus existing regressions. After final label/tab polish: 17 affected design/action/

workspace/translation tests PASS; final 12 design renders PASS. Verified nonempty

assets and effective SVG/PNG geometry at callsites, and visually reviewed renders.

Physical-device/numeric pixel comparison remains unverified. No restart, APK build

or hosted mutation. New assets may need owner-initiated Stop/Run once if absent

from the current bundle. See `docs/FIGMA_STUDENTS_IMPLEMENTATION.md` and

`docs/FIGMA_STUDENT_ASSETS.json`.



## Figma groups section — 2026-10-20 (current UI milestone)



Implemented the five adjacent frames 961:6366 / 6356 / 6177 / 6259 / 6268 from

high-fidelity design context and screenshots: grade-grouped list, empty state,

detail with no notes, note editor and detail with saved note. Original local

assets, reusable widgets, Arabic/English labels, local search, view-all lists,

required-note validation and group-scoped in-memory notes. Workspace retains

preview groups across tab navigation. Existing shared app bar and five-item

navigation unchanged; connected LiveGroups/backend untouched. No hosted group

notes or persistence claim: this is the owner-requested offline UI preview.



Validation: focused analyzer clean; 24 relevant tests PASS (10 design states,

6 responsive, 1 note save/validation/isolation, 3 view-all, 2 main-tab navigation,

2 translation parity). Verified original SVG render dimensions against manifest

and visually inspected five rendered states. Physical-device pixel comparison

remains unverified; no numeric pixel-perfect claim. New asset bundle may need an

owner-initiated Stop/Run once. No restart, APK build or hosted changes performed.

See `docs/FIGMA_GROUPS_IMPLEMENTATION.md` and `docs/FIGMA_GROUP_ASSETS.json`.



## Attendance ratios and navigation order — 2026-10-20



Session preview cards now show present/expected for both current and completed

sessions, excluding upcoming/cancelled cards. Preview model explicitly records

completion; today includes current/completed examples (19/25), earlier days are

completed, later days upcoming. Shared app bar reduced from 100 to 92 across all

five tabs. Swapped Students and Finance positions: Home, Sessions, Groups, Students,

Finance; navigation routing updated with the labels. Focused analyzer clean and

18 design/responsive/navigation tests PASS, including per-card ratio visibility

and the student destination at index 3. No restart, APK or hosted changes.



## Identical workspace header across tabs — 2026-10-20



Removed Home-only header/action variants. All five main tabs now compose the exact

same greeting/date/avatar/boxed notification/more-menu header. Responsive height

calculation is shared and independent of selected tab. Future header changes apply

to every main tab. Focused analyzer clean; eight greeting tests and final two

Arabic/English navigation regressions PASS, asserting the same header composition

and height on every destination. No restart, build or hosted changes.



## Dashboard and selected navigation polish — 2026-10-20



Removed the bottom navigation selection background; selected icons and labels use

the primary color. Dashboard payment figures now group whole pounds with commas,

using exact BigInt/string formatting (18,000), retaining ledger precision and the

existing currency symbol. Compact dashboard session rows reuse AppStatusBadge for

completed/current/upcoming labels; offline sample shows all three states. Connected

rows use supplied contract statuses. Arabic upcoming label changed to feminine.

Shared branded app bar height increased from 80 to 100, retaining Home text-scale

adaptation and all tab controls.

Validation: focused analyzer clean; nine navigation/decimal-contract/translation

tests PASS, including transparent indicator, selected label color, and rendered

18,000 amount. Dashboard badge tests exercise Arabic/English at 320px/200% text.

No restart, APK build or hosted changes.



## Five-tab teacher navigation — 2026-10-20



Moved the unpaid preview card before the center attendance section. Student

shortcut now lives as a fifth bottom destination after the existing four; removed

it from header actions. StudentDirectory supports an embedded body, preserving

search/profile navigation without a duplicate app bar; pushed directory/group

routes retain their existing scaffold. All five destinations use primary-colored

selected icons and the existing pale indicator. Navigation extracted into a

focused shared teacher widget.

Validation: focused analyzer clean; 14 preview navigation/greeting/unpaid tests

PASS. Final Arabic/English navigation assertions cover five destinations, primary

selected icons, actual embedded student directory and one shared app bar.

No restart, APK build or hosted changes.



## Home students shortcut and unpaid summary — 2026-10-20



Restored the student directory shortcut beside notifications on Home, using the

same reusable white rounded action button. Removed duplicate home overflow entry.

Reviewed Figma 961:6655 context/screenshot and added its unpaid-students summary at

the end of the offline dashboard: original 24px SVG, error tile, count and working

View list button. Preview count and list both use eight synthetic rows; card is

preview-gated because no connected monthly debtor count/list contract is wired.

No real debt status inferred from aggregate balances. Other backend behavior

unchanged. Responsive stacked layout supports narrow screens/large text.

Validation: focused analyzer clean; 12 greeting/navigation/translation tests PASS

and four unpaid card/list Arabic/English/large-text tests PASS. Reviewed rendered

header and card against requested Figma components. Asset provenance/hash in

`docs/FIGMA_HOME_UNPAID_ASSET.json`. No restart, APK build or hosted changes.



## Home greeting header — 2026-10-20



Reviewed Figma 961:6626 high-fidelity context and screenshot. Home now uses the

shared header with localized greeting and current Cairo date, keeping editable

avatar and rounded blue header. Preview name is Ahmed with abbreviated Arabic

honorific; morning switches to evening at noon Cairo time and refreshes each

minute while mounted. Connected mode uses a generic teacher label until a trusted

teacher display-name contract is available (Auth profile currently has IDs only).

Notification action uses the original 24px Figma SVG in a white rounded box;

existing notification navigation preserved. Student directory moved into the home

more menu for space, remains a direct action on other tabs. Other tab titles stay

unchanged. No artificial unread indicator. Asset hash recorded in

`docs/FIGMA_HOME_HEADER_ASSET.json`.

Validation: focused analyzer clean; 12 greeting/preview navigation/translation tests

PASS, covering 11:59/noon Cairo, Arabic/English and 320px/200% text. Reviewed rendered

home header image against Figma, adapting only owner-requested white box, title and

existing account/menu controls. No restart, APK build or hosted changes.



Arabic clock polish (2026-10-20): shared time formatting now places the day

period (AM/PM) physically left of clock digits while preserving start/end reading

order. English formatting unchanged. Five direction/session tests PASS; focused

analyzer clean. No restart, build or hosted mutation.



## Time interval reading order — 2026-10-20



Shared interval formatting now isolates the whole range according to locale and

each clock individually: Arabic start time on the right, end on the left; English

start on the left. Applied to session details/attendance header, dashboard and

connected session cards, plus legacy teacher/secretary mock screens. Legacy local

clock fields retain their original hours/minutes without UTC conversion. Removed

forced LTR text overrides while retaining the dashboard clock icon position.

Validation: focused analyzer clean; 17 time-direction/Cairo/session/design tests

PASS, including measured text positions inside both LTR and RTL parent contexts.

No restart, APK build or hosted changes.



## Calendar civil dates and status markers — 2026-10-20



Fixed month/week generation to construct civil dates rather than adding 24-hour

Durations across Cairo DST (the cause of repeated October dates). Pastel 6px

markers share a legend and support both scheduled and cancelled sessions on the

same day. Cancelled sessions remain excluded from the schedule list; the monthly

calendar retains their red marker. Offline fixture includes one cancellation on

the 28th for visual review. Today has a persistent blue outline and bold number,

independent of the selected date; selecting it uses the existing solid blue fill.

Validation: 17 design/responsive/action tests PASS, including unique October dates,

exactly one October 29 and mixed cancellation markers; dedicated today selection

regression PASS. No restart, APK build or hosted changes.



Attendance preview polish (2026-10-20): removed the read-only header badge at

owner request; attendance permissions and behavior unchanged. No restart/build.



## Sessions schedule simplification — 2026-10-20



Owner override of the Figma summary: the offline preview sessions tab now shows

only non-cancelled sessions for the selected day. Removed daily/weekly/monthly

summary metrics and the cancelled calendar legend. Attendance ratios appear only

on the current session; date selection and session details remain available.

The heading uses today only for the actual Cairo date. Connected backend unchanged.

Validation: 17 focused design, responsive and cancellation tests PASS, including

assertions for no summary/cancelled legend and attendance ratios only on current

cards. No restart, APK build or hosted mutation performed.



## Figma sessions and attendance UI — 2026-10-20 (current milestone)



Reviewed all ten owner-specified section frames through high-fidelity Figma design

context and rendered reference images. Implemented day/week/month/empty, detail,

cancellation and attendance all/present/absent/search-empty with original local

assets, reusable section widgets, independent data model and local fixture wiring.

Existing owner-approved shared app bar/navigation remain. Locale labels, arrows,

12-hour time and responsive layouts covered; no frozen screenshot used in UI.

Month/week date selection, previous/next, search, filters, reason validation, local

cancellation and retained attendance history are interactive. UI fixtures only;

connected flows/backend unchanged. Optional not-marked state remains explicit.



Validation this turn: full analyzer PASS; full Flutter suite 108 PASS / 1 hosted

opt-in SKIP before final typography polish; final affected design/state/layout/

action checks 17 PASS (ten screenshot states and six AR/EN 320px/200% cases);

translation parity 2 PASS; actual offline-mode main-tab navigation 2 PASS.

Original asset files checked nonempty and every literal asset reference resolved;

35 asset hashes recorded. Ten rendered states saved and visually reviewed. No

numeric pixel-diff or physical-device visual sign-off claimed. Intentional system

chrome/shared-header/dynamic-data differences documented in

docs/FIGMA_SESSIONS_IMPLEMENTATION.md. All new design/preview components kept

focused and below the repository's 100-line guideline.



No build/restart/deployment/hosted mutation. Owner must stop/run UI-preview once

to load newly bundled Figma assets; later UI changes can use Hot Reload/Restart.

Next: owner visual review, then adapter integration only when requested.



## Sessions tab and detail layout — 2026-10-20



Removed repeated Cairo timezone line from session cards. Short localized attendance

status now says in progress; finalized records still correctly say recorded.

Cards group date/time with icons, badge/status in a wrapping row, and actions

together below a divider. Extracted action composition, retaining cancellation

confirmation/conflict logic and details navigation. Detail metadata moved into

expandable card; attendance summary uses paired metrics, student name/status share

a row. Arabic/English translations regenerated. Full analyzer PASS. Eight session

detail (AR/EN at 200%), action, locale and preview-navigation regression cases PASS

(after updating old 24h/status expectations and wrapping expandable tile in Material).

No restart/build/hosted mutation.





## Consistent tab header — 2026-10-20



All four main Teacher tabs share the home app-bar configuration: 80px toolbar,

avatar menu, title, visible notifications, overflow actions and 16px bottom radius.

Shared core/widgets/AppHeader owns appearance and accepts title/avatar/actions;

WorkspaceAppBar supplies only teacher-specific composition. Removed home-specific

flag instead of duplicating headers. Avatar state now remains

mounted when switching tabs. No restart/build; nested detail-page app bars unchanged.





## Avatar menu and smaller header curvature — 2026-10-20



App-bar lower radius reduced from 24 to 16px. Removed permanent avatar edit badge;

tapping photo opens localized change/remove menu (remove disabled without photo).

Removal deletes only scoped local avatar file and returns to fallback icon.

Work-duration unit reduced from headlineLarge to titleMedium. No build/restart.

Full analyzer and avatar/localization/responsive preview checks run for this change.





## Visible notifications, local avatar and splash — 2026-10-20



Notifications promoted from overflow to direct app-bar bell. Bottom app-bar corners

use shared 24px radius. Avatar has edit affordance and gallery picker (existing

image_picker); compressed bounded image stored in application-support directory,

scoped by environment/account, never uploaded in UI preview. Supports cancel/error

fallback and Android lost-picker-data recovery. Local file survives restart; cloud

avatar storage/synchronization remains a future connected implementation. Added

iOS gallery-purpose description; no broad Android storage permissions introduced.

path_provider promoted from transitive to direct at identical locked 2.1.5.

Flutter splash logo increased responsively to 200–240px; native splash is removed

only after first Flutter frame, retaining existing white native setup and Android

12 masked-image assets/system sizing. Native resources not regenerated or resized.

Schedule clock now sits physically left of time range; work-duration icon replaced

with localized hour unit on left (Arabic requested letter, English h).

Full analyzer PASS; 14 local avatar persistence/isolation/rejection, localization,

AR/EN preview/responsive and protected-route checks PASS. Native gallery selection,

permissions, Android process-loss recovery, iOS and cold-start transition remain

owner/device acceptance. No APK/restart/hosted mutation performed.





## Attendance preview grid and translation reload — 2026-10-20



Attendance cards now use the existing two-column metric grid: present/waiting first,

absent/excused second, with normal metric sizing. Local preview supplies 42/2/5/3.

Replaced bundled-asset translation loading with the dependency official generated

CodegenLoader, retaining JSON as canonical AR/EN source. This resolves repeated raw

new-key display during Hot Restart after JSON edits. Documented regeneration and

added generated-map parity coverage. No restart/build/hosted changes.





## Dashboard time direction repair — 2026-10-20



Isolated start/end time strings in shared CairoTime.range to keep Arabic day-period

markers attached to their own time across the range separator. Compact dashboard

schedule uses the helper with LTR range layout. Reused TeacherStatCard optional

icon for scheduled work-duration clock alongside value. Focused analyzer PASS.

No restart/build; owner device visual verification pending.





## 12-hour time and waiting attendance — 2026-10-20



Shared Cairo time display now explicitly uses h:mm a (Arabic day periods/English

AM-PM). Dashboard attendance title uses a dedicated static locale key; does not

depend on selected-date text. Fourth Waiting card uses existing notMarked count,

with owner-requested Arabic diacritic, without changing backend attendance enums.

Current UI-preview mode remains local only. No restart/build.





## Compact dashboard schedule — 2026-10-20



Owner requested dashboard glance rather than repeated detailed session cards.

Retained four summary metrics (session count, work duration, students, groups).

Replaced detailed operational cards with one compact schedule card: group name

and Cairo start/end time per row, wrapping for narrow/large-text layouts.

No attendance metadata, repeated dates, details buttons or cancellation controls

on dashboard; existing sessions tab retains full functionality. Uses shared card,

theme and locale time formatting. Focused analyzer PASS; preview AR/EN navigation

and responsive workspace tests PASS. No restart/build/hosted changes.





## Whole-app offline UI review — 2026-10-20 (current owner priority)



Owner explicitly paused connected business testing to review the entire Teacher UI.

Added opt-in debug-only PreviewMode, separate local auth/bootstrap and terminal HTTP

transport with dedicated synthetic fixtures. Existing production screens/repositories

are reused; hosted backend/auth code is preserved and bypassed completely in preview.

Local reads cover dashboard/groups/calendar/detail/attendance/students/profiles/

academics/finance/notes/secretaries/notifications. Writes simulate cancellation, notes,

read state and removal requests in memory only; restart resets fixtures.

Removed one-off sample-session widget. Preview has a visible mode banner, local

auth starts signed in, and remembered real credentials are neither read nor changed.

VS Code preview launch uses no backend configuration; separate connected launch

explicitly disables preview. Ignored local config defaults to preview for owner UI

work. Release/profile cannot activate the debug guard. No APK/restart/hosted mutation.

One-time owner relaunch needed to load new assets/defines and fresh translations.

Full analyzer PASS; 14 local contract/auth/dashboard/responsive cases PASS, plus

two Arabic/English offline-preview main-tab navigation cases PASS. Preview tests

use only terminal local transport and detect dashboard translation-key leakage.

This mode is for design review, not hosted MVP/production acceptance.





## Temporary session visual preview — 2026-10-20



Owner requested one sample session to inspect layout before Secretary data entry.

Empty dashboard session lists now show a labeled visual sample only in development

debug builds. Reuses LiveSessionCard, disables details/cancellation, does not affect

counts/finance/attendance or hosted data. Release/profile excludes this preview.

Localized group/subject/preview labels; selected calendar date, 16:00 Cairo, 90min.

No build/restart/hosted writes. Remove this temporary preview after owner UI review.





## Monthly payment progress — 2026-10-20



Added rounded green payment progress track with localized label/percentage and

accessibility semantics. Ratio uses exact invoice cohort (invoiced minus outstanding)

over invoiced; monthly receipt totals are not mixed into the denominator. Zero due

shows zero progress; over/under bounds clamped for display. Empty-session title now

explicitly uses shared 10px size. No build/restart; owner visual acceptance pending.





## Attendance heading and card hierarchy — 2026-10-20



Restored localized center attendance heading per owner correction. Present count

now spans full section width, with absent/excused paired beneath. Recorded-mark

semantics unchanged (not live occupancy). Arabic money uses owner-selected symbol

from shared MoneyEgp formatting constant; English retains intl EGP. No restart/build.

Focused analyzer PASS.





## Dashboard numeric display repair — 2026-10-20



Owner screenshot showed untranslated currency/basis keys from installed locale assets.

Money display now composes exact rounded integer with intl EGP currency symbol,

independent of new translation templates. Preserves actual backend numbers; no mock

values introduced. Removed attendance heading and explanatory text per owner request;

three recorded-mark cards remain. No build/restart. Focused analyzer PASS.





## Dashboard typography, EGP and attendance — 2026-10-20



Reduced date selector to headlineSmall and empty-session message to bodySmall.

Money cards render localized EGP with whole pounds, exact BigInt half-away-from-zero

display rounding; stored money unchanged. Attendance section title follows owner

request with spacing and three explicit present/absent/excused metrics only. Added

localized basis text: selected-date session marks, not live center occupancy; no

new live-presence claim or automatic absence conversion. No build/restart.

Focused analyzer PASS; dashboard/responsive and exact-rounding regressions run.





## Monthly three-card dashboard — 2026-10-20



Date selector enlarged with shared headlineMedium; dashboard empty-state title uses

bodyMedium through optional shared titleStyle. Monthly finance uses a full-width

invoiced total card, followed by two-column net collected and outstanding cards.

All three values come from deployed finance summary, not client arithmetic.

Invoiced/outstanding are for invoices due in current Cairo month; net receipts follow

receipt dates (can include earlier invoices). Labels supplied AR/EN. Older disabled

contract has no fabricated invoiced amount. No restart/build or hosted mutation.

Focused analyzer PASS; repository/month bounds and responsive workspace tests PASS.





## Dashboard empty state and monthly payments — 2026-10-20



Empty sessions use the existing full day message as title, with no subtitle or gap.

Shared AppEmptyState supports omitted subtitle. Payment heading now says this month

(AR/EN), with 16px gap below. Corrected data basis as well: dashboard reads deployed

finance summary for the current server Cairo month, even when another session date

is selected. Collections are net receipts/reversals in month; outstanding is balance

on invoices due in month. Existing global/day overview contract unchanged.

Updated repository fixture asserts exact month bounds and monthly totals; overflow

menu regression reflects owner-requested logout relocation. Analyzer PASS.

No build/restart/hosted writes; device/real-data monthly acceptance pending.





## Home date copy and lighter section — 2026-10-20



Opening session metric shortened to Sessions. Session heading uses Today sessions

or localized Sessions on {date}; AR/EN provided. Section uses new primarySoft

palette token near white; other primary surfaces preserved. Confirmed initial

LiveDashboard date is null so backend defaults to current Cairo date (no persisted

previous selection). No build/restart; owner device acceptance pending.





## Login branding follow-up — 2026-10-20



Owner screenshot showed a residual baked-in tagline; tightened login-only clipping

to 0.74. Increased login logo responsive width from 35% to 42% (120–200 logical

pixels), with 48px spacing before the welcome heading. Changed welcome heading to Arabic Welcome / English Welcome in locale

assets. Focused analyzer PASS; no restart/build or device visual acceptance claimed.





## Login copy cleanup — 2026-10-20



Removed teacher-account sign-in caption from LoginView. BrandLogo now supports

showTagline=false using layout clipping of the existing bundled PNG (tagline is

baked into the image); login opts out, other brand surfaces retain their default.

Focused analyzer PASS. No build/restart; owner visual acceptance pending.





## Configurable WhatsApp support — 2026-10-20



Owner supplied support phone. Onboarding/login use localized Contact support and

shared support action; opens owner WhatsApp with localized draft, never auto-sends.

Default owner-approved wa.me destination remains overridable by CENTERLY_SUPPORT_URL.

Extracted existing AppButton into core widget to avoid circular feature imports;

retained export for compatibility. Arabic/English labels/messages provided.

No build/restart/message sent; physical WhatsApp handoff remains owner acceptance.





## Remember login on device — 2026-10-20



Owner explicitly requested retaining entered email/password across restarts. Login

now saves only after successful teacher authentication in FlutterSecureStorage,

scoped to backend URL, and restores masked fields without overwriting user edits.

Existing secure Supabase session persistence/role validation remains unchanged;

explicit logout ends the session but retains owner-requested remembered fields.

Storage failure cannot block login. Two storage tests and four auth/router regression

cases PASS; focused analyzer PASS. No build/restart/hosted changes; physical-device

credential restoration remains pending owner testing.





## VS Code configured launch — 2026-10-20



No launch.json existed, so VS Code default Run omitted compile-time backend defines.

Added Centerly (development) launch using --dart-define-from-file=.env.local.json.

Validated launch JSON and required local config presence without logging values.

Documented restarting the launch once with this configuration. No build, app restart,

hosted change or device login verification performed for this setup correction.





## Dashboard date grouping — 2026-10-20



Selected Cairo current date displays localized Today; other dates retain the selected

calendar date. Date selector, four opening metrics and selected-date sessions share

one bordered primary-tint section; finance/attendance summaries remain separate.

Follow-up: opening metrics explicitly stay in two columns inside the section; Today

falls back to the existing localized day label when installed assets lack the new key.

No restart/build performed for this follow-up, per owner request.

Focused Dart analysis PASS. Initial change updated via configured Flutter attach/hot restart on

Redmi Note 9S; no APK built for this change. Owner visual acceptance pending.





## Home app bar UI — 2026-10-20



Home toolbar increased to 80 logical pixels with a 48px circular profile fallback

aligned beside the title using directional Row layout. No stored teacher photo

contract currently exists; no fabricated personal photo is used. Logout moved into

the overflow menu, retaining the existing AuthSessionCubit logout and other actions.

Other tabs retain their normal toolbar height. Analyzer PASS; configured debug APK

build PASS; update installed and launched on owner's connected Redmi Note 9S.

Visual acceptance on device remains with owner. APK SHA256:

1c12d34f66855d641e176f2bb01c339972d970fd2f38926073230a488a659942.





## Android configuration repair — 2026-10-20



Owner's Redmi Note 9S displayed NOT_CONFIGURED at login. The installed debug

build had been produced without runtime defines; credential-free CI/build APKs

are compile checks and cannot sign in. Rebuilt with ignored .env.local.json:

`flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json` PASS.

Confirmed public URL/key bytes are embedded (values not logged); installed with

`adb -s 7e8fce74 install -r` PASS and launched on the connected Redmi Note 9S.

APK SHA256: 476bffa873486363b2da93e962654781148cc481f9fa782003311544d2a4b381

(198665928 bytes). This supersedes the earlier APK checksum for this local build.

Owner device login/workflow acceptance remains pending; installation is not login

verification. No schema/Auth settings changed in this repair. Earlier owner-requested

synthetic teacher password change was separately verified with real Auth/profile.





## GitHub CI repair — 2026-10-19



Main run 39293622024 passed lockfile/codegen/format/analyzer/Flutter tests, SQL and

manifest checks, then failed in native PostgreSQL startup during concurrency tests

with an undefined rejection. The pinned embedded-postgres start() drops stderr and

rejects without an Error when postgres.exe exits before readiness. Local Windows

uses a different privilege environment from the hosted Windows runner.



Disposable Windows clusters now start/stop with the same pinned PG17 pg_ctl, which

supports restricted Windows tokens. Controller output goes to temporary files to

avoid inherited-pipe EOF hangs. Startup has bounded waits, stderr/server diagnostics

and password redaction; tests/SQL assertions are not weakened or skipped. Other

platforms keep the existing native start. Added a real invalid-port startup test

for clear redacted failures. No Flutter, hosted schema/data or Auth changes.

Local native suites passed 11/33/21/98/22 assertions with the new controller;

GitHub run 39299955574 confirmed startup/concurrency/detail/profile now pass, then

exposed host-default WIN1252 encoding rejecting Arabic completion fixtures. initdb

now explicitly selects UTF8; a real Arabic/emoji round-trip/server-encoding test

guards independence from the Windows code page.



Full GitHub verification PASS: run 39301090510 for repair commit 060d32f,

https://github.com/Centerly-it/Centerly_mobile/actions/runs/39301090510.

All 28 steps succeeded: enforced lock/codegen/drift/format/analyzer/Flutter tests,

SQL/manifest/native startup/Unicode/concurrency/detail/profile/completion/integrity,

debug and profile APK builds, artifact upload and cache/cleanup. The tested source

was a fresh Windows runner with pinned Flutter 3.44.2 and Node 22; hosted opt-in Auth

is still excluded from credential-free CI (its earlier real tests remain separate).

The final verification-record commit changes only this Markdown file and skips a

redundant CI run; no test or application change bypasses verification.

Pilot gates unchanged; no application or hosted backend changes.



## Teacher MVP completion — 2026-10-19 (current milestone)



This milestone supersedes the historical audit and intermediate task tables below.

Owner authorized implementation and explicitly approved the exact seven-file

completion package; approval does not include production, account/Auth changes or

publication. Existing design/assets and unrelated platform edits preserved.



- Approved/deployed 202610190004..010 to centerly-dev only. Immediately before

  deployment all twelve remote bodies and seven package hashes matched; dry run

  listed exactly those seven files. No seeds/roles/vault/backfill or existing

  migration edits. Postflight matched all nineteen bodies, 12 function metadata/

  grants/search paths, six indexes and two enabled triggers. Nineteen hashes pinned.

  Exact review/pins: docs/TEACHER_COMPLETION_CHANGE_REVIEW.md and

  supabase/completion-package-manifest.json. Sanitized verification JSON retained.

- Backend suite: local business 90 PASS; races 11 PASS; session detail 33 PASS;

  profile 21 PASS; completion 98 PASS; added integrity 22 PASS; SQL tokenizer 1 PASS.

  Integrity coverage includes simultaneous payment/reversal replay, exactly-one

  payment/removal notifications, competing note versions and Cairo DST boundary.

- Real hosted SDK login/restore/refresh/logout, secretary rejection and invalid

  password PASS. New hosted completion suite 98 PASS through real Auth/REST/RPC:

  both-tenant/secretary/anonymous checks; duplicate/reversed payment events; in-tx

  visibility and rollback of payment/event/invoice effects; null versus zero scores;

  pending then finalized correction after thirty days; note conflict/content restore;

  duplicate removal request, handled notification without deactivation; read marking

  and cancellation race. Only approved synthetic fixtures changed. No account/Auth

  configuration changes, provisioning or password resets. Test records remain for QA.

- Completion gate activated only after those backend checks. All core destinations

  now use deployed reads: profile/memberships, exams/assignments, student attendance,

  detailed global/student finance, notes, secretaries/removal and notifications.

  Finance placeholder replaced in the configured MVP. Dashboard/calendar derive

  status from server time; ended sessions hide cancellation. Secretaries remain

  read-only except removal requests; Teacher cannot write operations/finance.

- Regression additions: 14 AR/EN 320px/200% completion-page cases, note duplicate/

  conflict/ambiguous-write tests, real hosted native navigation test. Note reload

  failures preserve drafts and require reconciliation. Background account/token

  validation preserves nested navigation/drafts; startup/resume checks still gate,

  and failed account checks sign out. Tests cover nested navigation and deactivation.

- CI now includes profile/completion/integrity SQL suites. SDK/lock mismatch traced

  to five Flutter-pinned packages: existing Windows resolutions match 3.44.2; no

  dependency upgrade or unrelated lock edits. Enforced pub get PASS with existing

  lock bytes unchanged. Final analyzer clean; 82 Flutter tests PASS, one hosted

  opt-in skipped in default run (passed separately); format and whitespace PASS.

  Native Windows real hosted core navigation PASS, and separate actual secure

  persistence/restore/logout PASS. These are native reads/auth, not Android or full

  native UI mutation acceptance. Earlier test-harness failures (wrong fixture ID,

  ambiguous calendar icon, English-only back tooltip, CLI result format/last-row

  assumptions) were corrected and final runs passed; no SQL changes were needed.

- TEACHER MVP READY FOR OWNER DEVELOPMENT TESTING: final configured debug APK

  compiled after fixes; ZIP integrity and scan for all synthetic passwords/env

  files PASS. SHA256 9d058ca18d6f0a694bcc1169975922af081c793e454693fa81918296a7f780b7.

  Artifact: build/app/outputs/flutter-apk/app-debug.apk (170553861 bytes),

  Android >=7.0/API24, ARM64/ARMv7/x86_64, com.example.centrally 1.0.0+1 debug key.

  No core placeholders in this configured build. No physical-device installation,

  Android performance/storage verification, release signing or pilot claim.

- Support URL remains empty/configurable. No Android device/emulator is available;

  Windows native testing is supplementary, not Android acceptance. Cached Android

  SDK compiles despite some outstanding licenses for future SDK installs. Kotlin

  plugin warnings concern future Flutter versions, not this successful build.

- Next handoff: docs/SECRETARY_HANDOFF.md (canonical nineteen-version transfer,

  permissions, environment, exact money/manual attendance and remaining cross-app

  matrix). docs/TEACHER_MVP_TESTING.md contains install/manual steps. Pilot gates

  remain physical device/security/performance/accessibility/update/signing, real

  app identity/privacy/support, backup restore/monitoring and Secretary acceptance.



| Current IDs | Testing handoff status | Remaining acceptance |

|---|---|---|

| T-010/013 | Nineteen-version contract pinned; remaining typed reads/actions active | React shared pin and cross-app matrix |

| T-011/012 | Real Auth/native storage and AR/EN adaptive shell verified locally | Support URL; Android restore/accessibility/device QA |

| T-020..024 | Live overview/groups/calendar/detail/manual attendance/cancel flows wired | Owner Android QA; Secretary reception/correction matrix |

| T-030..034 | Live profile/memberships/academics/student attendance/finance/notes wired | Owner Android edge cases and cross-app reconciliation |

| T-040/041 | Own secretary/removal and real notifications/read marking wired | Operator/Secretary joint acceptance |

| T-042/050..054 | Automated suites and testing APK delivered; pilot acceptance open | Physical security/performance, signing/update, monitoring/restore, cross-app sign-off |



Exact next eligible task: begin the Secretary React app against this canonical

shared schema, using docs/SECRETARY_HANDOFF.md. Do not replay migrations or infer

pilot readiness; future hosted contract changes require separate owner review.



## Historical checkout audit — 2026-10-19, Windows



This section supersedes conflicting older status entries below. Audit only: no

implementation, deployment, Auth setting changes, password resets or hosted

fixture mutations. Only this ledger was edited; owner lockfile changes retained.



- HEAD `effcd270618f91f2e103e150f4c870d4402e097f`, branch

  `codex/teacher-auth-foundation`. Successful origin fetch: HEAD and remote branch

  match (0 ahead/0 behind), newer than de42879. Pre-existing sole modification:

  pubspec.lock downgrades intl, matcher, meta, test_api and vector_math relative

  to committed resolutions. No reset/merge/dependency installation performed.

- Rules, root plan, contract, roadmap and latest reviews/verification JSON read.

  Historical task table is stale: full profile code is wired; academics, student

  attendance, finance, notes, secretaries and notifications now have local code,

  rather than being NOT_STARTED. This does not make them hosted-complete.

- Production auth uses real Supabase SDK, secure session storage, live teacher/

  tenant validation and logout/refresh. Dashboard, group search/filter/pages,

  day/week/month sessions, reasoned cancellation, read-only session attendance,

  student directory and contact/membership profiles have live RPC/UI paths.

  Current audit did not perform a password-based Flutter/device end-to-end flow.

- Completion UI/models/repositories exist for academics, student attendance trends,

  exact-decimal finance, optimistic notes, secretary removal requests and recipient

  notifications. Entry points are gated by CENTERLY_COMPLETION_CONTRACTS (false

  by default and absent from local runtime config); Finance remains a placeholder

  in a normal build. New calendar/server-time path is gated too. Legacy mock/demo

  screens remain in source, outside the production router. No entire feature is

  newly accepted on the strength of mocks or SQL tests.

- Fresh authenticated, read-only hosted inventory: all twelve migration SQL bodies

  match local pinned history through 202610190003; 18 tables, 30 policies, no table

  lacking forced RLS, no anonymous Centerly RPC execute or unsafe definer search

  paths; four expected synthetic Auth users; platform helper retained. Separate

  read-only query confirms all seven completion public reads are absent remotely.

  Seven proposals 202610190004..010 remain under proposals/teacher_completion;

  none is a managed/deployed migration. Manifest's '0 pending' refers only to

  managed migrations, not these proposals. Completion package is not activated.

  Public Auth settings returned HTTP 200: email provider enabled and public signup

  disabled. This is fresh connectivity evidence, not a password-login test.

- Tools present: Flutter 3.44.2/Dart 3.12.2, Node 24.12.0, Java 17, Android SDK 36,

  Visual Studio Windows tooling, cached Supabase CLI 2.121.0. CLI authentication

  works and ignored project-ref matches expected development project.

  .env.local.json, .env.development-accounts.json and .env.native-auth.json exist

  and parse; public runtime URL/key present, support URL empty. No secret values

  printed; none of these files tracked. Password validity not tested this audit.

  Older Mac-specific missing-credential/tool-version statements are historical.

- Fresh checks: analyzer clean; Flutter suite 64 PASS / 1 opt-in hosted SKIP;

  format check lib/test/integration_test 261 files unchanged; SQL suite 90 PASS;

  native PostgreSQL concurrency 11 PASS; session-detail 33 PASS; student-profile

  21 PASS; completion-package 98 PASS on disposable local DB only; 12 manifest

  hashes unchanged; git diff whitespace check clean before ledger edit.

  Raw CLI preflight included a diagnostic prefix; extracted JSON validated

  successfully against all twelve exact SQL bodies. Evidence logs in ignored

  .buildlog/audit_*; no sensitive payloads included in this ledger.

- Not rerun: hosted password SDK/native integration, hosted mutation/fixture tests,

  APK/profile/release builds, codegen, clean-checkout replay, remote CI, visual

  captures or physical-device acceptance. Earlier Windows native auth and hosted

  36-case results, later Mac debug APKs and deployment role checks are historical.

  CI currently targets PRs/main pushes and omits the completion-package suite.

- flutter doctor: Android licenses outstanding; only Windows/Chrome/Edge detected,

  no physical Android device. iOS requires a Mac. Committed lockfile/current SDK

  compatibility needs an explicit review; existing release uses debug signing and

  com.example.centrally. No signed pilot or device-ready artifact certified here.

- Next eligible implementation slice (only after audit authorization): T-010/013

  completion-package review/compatibility pin and missing feature regression tests,

  preparing one concrete deployment review; do not enable the gate before explicit

  hosted approval and postflight verification. Then T-030..034/T-040..041 acceptance.

  Inputs: real support URL, completion-package approval before deployment, Android

  license acceptance/device, later app identity/signing/privacy/recovery ownership

  and Secretary environment. Credentials/access are present, not a current blocker.

  Pilot gates remain real two-tenant password/UI/cross-app tests, pending/cancelled/

  correction/ledger cases, device accessibility/performance/storage, signing,

  monitoring and an encrypted backup with successful restore drill.



Updated: 2026-10-19 (Africa/Cairo). Session detail deployment and Flutter activation after 66ee032.

Current phase: T2 live session detail/read-only attendance; T-030 profile contract proposal.

Development backend is deployed with explicit owner approval; not production ready.



## Approved read deployment and activation — 2026-10-19



Owner approved only 202610190001. CLI login completed on this Mac; verified and

linked the expected centerly-dev project. Read-only preflight matched exact SQL

history and all nine pinned hashes, 18 tables/30 policies/forced RLS and four

synthetic accounts. Dry run listed only 202610190001, no seeds or roles. Deployment

used --skip-vault; postflight confirmed all ten SQL bodies match local history.

Manifest now pins the tenth hash (6830529e…71f817b8). No other migration, fixture

mutation, Auth configuration, password reset or account creation ran.



New RPCs: three empty-search-path SECURITY DEFINER reads; authenticated execute,

no anonymous execute. Real read-only hosted role/JWT-subject checks with the

existing synthetic UUIDs passed for both tenants, teacher authorization, counts,

secretary denial and anonymous denial. Three anonymous REST calls returned 401.

Current hosted fixtures contain zero not_marked and zero cancelled attendance

rows: positive preservation/exclusion was verified locally, not claimed hosted.

Local SQL suite now has 90 assertions including an isolated cancelled/pending case.



Public config was reconstructed with owner-only permissions and remains ignored.

The original operator environment is not mounted/configured via SSH. Synthetic

account passwords remain unavailable; no attempt to retrieve them was made.

Password-based hosted SDK/Flutter tests require the original credential file.

Approval and deployment are no longer blockers for this read extension.



Production activation: overview attendance counts remain distinct, including

not_marked; named sessions enable identified cancellation; Groups now has real

server search/grade filter, cursor pagination, retry/refresh and bounded roster/

schedule previews. Typed errors and stale-search/duplicate-page guards are tested.

Physical device/full hosted UI/Figma acceptance remains open. Gradle 8.12 failed

configuration against Flutter 3.47.2; updated Gradle/AGP/Kotlin to the installed

SDK's supported minimums (8.14/8.11.1/2.2.20). Debug compilation then passed, and a

second current-source debug APK with public development config compiled successfully.

APK SHA256: 66ec39db51b754685329f12c9436165901eb840544c44c1676df0b10cb162b91.

No device installation, signed release, iOS build or production-readiness claim.



Next eligible T-030 slice implemented using existing list_students: global

read-only student directory plus group-scoped roster, bounded search/cursor pages,

missing contact values shown as missing, stale search and duplicate page guards.

Logout regression verifies nested contact screens are removed. Full profile,

membership/academic/financial history and notes remain incomplete.



Final local checks: analyzer clean; full Flutter suite 52 PASS / 1 hosted opt-in

SKIP; eight font-loaded shell captures at AR/EN 320/430, 100%/200% text PASS;

local SQL 90 PASS; independent PostgreSQL races 11 PASS; migration-history tokenizer

unit test PASS; 10 deployed hashes unchanged / 0 pending; Dart format and diff checks

PASS. Default SDK tests use synthetic HTTP; native hosted Auth/SDK/UI tests were not

rerun without original development credentials. Sanitized deployment evidence:

docs/verification/teacher_read_20261019.json.



## Historical repository audit (before implementation resumed, 2026-10-19)



- Branch: `codex/teacher-auth-foundation`; HEAD:

  `de428791d6097d659ffbbde15d1b0746cc6a27f5`

  (Add typed teacher read repositories and record verified milestones).

- Active implementation stop: T-013, partial typed read infrastructure. Dashboard,

  student and session models/repositories, bounded reads, one transient-network

  retry and sanitized access/error handling exist. Student/session repositories

  are registered but have no production UI consumers. Caching, remaining

  operational models/contracts and live feature integration remain unfinished.

  T-011 remains open for configured support; T-012 full live shell is incomplete

  (a minimal workspace exists). No task was advanced during this audit.

- Production routing reaches TeacherWorkspace: Home renders four live aggregate

  values through get_teacher_dashboard; Sessions/Groups/Finance render pending

  text. Full legacy home/groups/sessions/details/attendance/student profile and

  secretary screens still use CenterlyMockData and are not production routes.

  Backend RPC availability is not Flutter feature completion.

- Authentication has a real SDK/repository/UI path, secure persistence, live

  profile/role validation, refresh, logout and resume/periodic revalidation.

  Earlier hosted SDK and native Windows passes are historical reports below;

  this audit did not contact hosted Supabase or re-run native integration.

  The live dashboard is wired but its rendered hosted values are not independently

  proven by this audit or the native auth test (which checks workspace presence).

- Required CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md is absent from this checkout,

  the searched Desktop tree and this repository's available git history. Task IDs

  below come from the retained ledger; exact plan acceptance cannot be checked.

- Fresh checks: flutter analyze --no-pub PASS (no issues); flutter test --no-pub

  PASS (25 passed, 1 hosted opt-in skipped); npm ci --prefix supabase/tests PASS;

  node supabase/tests/run.mjs PASS (64); node supabase/tests/concurrency.mjs PASS

  (11); node supabase/tests/check_manifest.mjs PASS (9 unchanged, 0 pending);

  git diff --check PASS before this documentation edit.

  Initial SQL test attempt lacked dependencies; rerun passed after npm ci.

- Default SDK tests use synthetic HTTP fixtures, not hosted Auth. The visual test

  checks legacy RTL layout/no exceptions; it is not a pixel golden comparison or

  proof of the live workspace design. No screenshot recapture was requested.

- Current host: Flutter 3.47.2/Dart 3.13.2, Node 25.2.1, differing from the pinned

  Flutter 3.44.2/Dart 3.12.2/Node 22+ baseline. No builds, codegen, device tests,

  hosted tests, CI runs or full clean-checkout verification were rerun here.

- Pre-existing uncommitted files: analysis_options.yaml (platform/build excludes),

  pubspec.lock (five SDK-related resolutions), ios/Podfile.lock (plugin changes),

  ios/Runner.xcodeproj/project.pbxproj (13 -> 15 deployment target and removed

  CocoaPods resources phase). Origin/native validity of iOS edits is unverified.

  This audit only changes IMPLEMENTATION_PROGRESS.md; no hosted changes.

- Deployment/security claims below are historical, corroborated by committed SQL,

  manifest and review documents plus fresh local tests, not a fresh remote inventory.

  docs/HOSTED_CHANGE_REVIEW.md retains predeployment wording in its historical

  sections; do not treat those sections as current migration state.

- Owner input: real support URL; recover/provide the missing plan for exact

  acceptance mapping. Later approvals/access are required for additional hosted

  migrations, pilot operations, target devices/signing and Secretary cross-app QA.

  Neither support URL nor missing plan prevents independent repository analysis

  or bounded work from the existing contract once implementation is authorized.

- Next implementation task after authorization: finish T-013 caching and typed

  operational contracts against existing approved RPCs; explicitly review any

  backend gaps before proposing new migrations. Then finish T-012 live shell and

  T-011 support, T-020..024 dashboard/schedule/attendance, T-030..034 student and

  records/finance/notes, T-040..042 secretary/notifications/polish, and T-050..054

  integration/security/performance/device/signing/cross-app acceptance. Backups,

  restore, monitoring and remaining backend contracts remain pilot gates.



## Resumed implementation — plan reconciliation (2026-10-19)



The root plan is now available and read in full with repository rules, README,

shared contracts and ADRs. Owner overrides remain authoritative: this repo owns

canonical migrations; manual attendance has no time lock/conversion; deployed

001..009 are immutable; hosted changes require explicit approval. Support remains

pending/configurable and does not gate unrelated work.



Acceptance reconciliation: T-010 remains accepted under the owner override, not

under the plan's original no-teacher-migrations ownership. T-011 is incomplete

only where evidence/configuration is missing; do not claim full device acceptance.

T-012 was incorrectly labelled NOT_STARTED despite an existing minimal workspace;

it is IN_PROGRESS and needs production visual/scaling/semantics acceptance.

T-013 acceptance is repository infrastructure (not every future feature model);

student/session UI wiring belongs to subsequent tasks. T-020 is incomplete even

though aggregate reads exist. Existing T0 passes refer to the recorded historical

baseline, not a new clean-checkout result on the current SDK or working tree.



T-013 local slice: cache is memory-only, 30-second TTL, max 64 entries, keyed by

SDK user + endpoint + parameters. It returns decoded copies, never serves stale

fallback, clears on account validation/signout, rejects late replies across

session/token/generation changes, and supports refresh bypass. Sensitive data is

not persisted. Nine targeted repository/cache/error/model tests passed. A typed group-summary

repository/model is also prepared and tested for the pending contract; it is not

registered or called by production navigation. Refresh

and retry callbacks were also corrected to avoid returning Futures from setState;

refresh failures remain in the localized retry UI.



T-012 local slice: safe areas in production workspace, scalable navigation height,

localized loading semantics, scrollable error/pending content, and shared metric

cards wrapping instead of overflowing at 200% text. Production widget regression

matrix passed in Arabic/English at 320/430 pixels and 200% text. Actual font-loaded

screenshots are retained; visual differences and pending physical TalkBack acceptance

are documented in VISUAL_PRESERVATION.md. No hosted backend mutation/deployment occurred.



### Subsequent local milestones



- T-020 slice: dashboard now parses real session rows, uses the server date,

  accepts a selected date through the existing p_date argument and displays

  session counts/scheduled minutes excluding cancellations. Financial values stay

  server-calculated. Attendance counters are not invented; approval proposal below.

- T-022 slice: production Sessions tab replaces pending text with existing RPC

  day/week/month reads, Sunday-based weeks, useful empty/error/retry states, Cairo

  IANA display independent of device timezone, manual finalization labels.

- T-024 slice: cancellation dialog validates reason and confirms preservation of

  attendance/notification to secretaries via existing RPC. It disables duplicate

  submission; mutations are never automatically retried. Errors require returning

  to refresh, and the list reconciles after closing. No fake successful cancellation. Session cancellation controls are gated on

  group identity: current deployed list_sessions lacks names, so production shows

  read-only cards until the reviewed named-session RPC is approved and wired.

  Workflow tests include explicit group identity; full hosted acceptance stays open.

- Pending migration 202610190001 adds three teacher-only read functions only. Local

  SQL suite passes 88 assertions including 10k bounded group fixture checks,

  cross-tenant/role/anonymous denial and explicit not_marked counts. Original nine

  hashes unchanged, one pending version; 11 concurrency assertions pass.

- Full Flutter suite: 37 passed, one opt-in hosted test skipped. Analyzer passed

  before the final documentation-only changes. Font-loaded capture matrix: 4 pass.

  Debug APK attempt was interrupted during the Gradle 8.12 distribution download

  after more than six minutes; compilation was not reached and no APK pass is claimed; no native-device/hosted verification claimed.

- Next contract-dependent work requires owner approval of the concrete proposal in

  docs/TEACHER_READ_CHANGE_REVIEW.md before hosted deployment. No hosted state was

  contacted or changed in this slice. Support URL remains pending and configurable.



## Historical task ledger (superseded by current milestone above)



| ID | Status | Evidence / remaining acceptance |

|---|---|---|

| T-001 | DONE | Original audit and screen map retained |

| T-002 | DONE | ADR-001, actual Arabic home/groups/sessions captures, visual comparison in VISUAL_PRESERVATION.md; original Figma PNGs preserved |

| T-003 | DONE | All 12 documented checks passed on clean checkout of 3f6f16b, including debug/profile builds; CI configured |

| T-010 | DONE (owner override) | Canonical schema here, nine hosted versions verified, deployed hashes pinned, shared contracts and typed auth profile tested |

| T-011 | IN_PROGRESS | Real SDK auth, secure storage, guards, logout/refresh/role checks implemented; native Windows verification passed; configured support channel pending |

| T-012 | IN_PROGRESS | Blue/white live shell, adaptive paired metrics, safe areas, accessible actions; 8 font-loaded AR/EN scale captures pass; physical TalkBack/full Figma acceptance remain |

| T-013 | DONE (local acceptance) | Existing read RPC models/repositories, bounded pagination, safe errors/retry, 30-second bounded memory cache and stale-session rejection pass regression tests; hosted cross-app acceptance remains T-050/T-054 |

| T-020 | IN_PROGRESS | Live date-filtered metrics, scheduled minutes, session cards, refresh; attendance-count contract proposed locally, hosted fixture/UI reconciliation pending |

| T-021 | IN_PROGRESS | Approved RPC deployed; production search/grade filtering/cursor pagination/previews wired; hosted SQL isolation passes, full Flutter/scale-device acceptance remains |

| T-022 | IN_PROGRESS | Production day/week/month sessions wired to deployed RPC; server initial date, Cairo DST display, ranges/empty-state tests pass; hosted/web/device acceptance pending |

| T-023 | IMPLEMENTED / acceptance pending | Deployed typed detail, all four read-only status filters, bounded pages, finalized/sync/marker metadata and correction refresh; local UI/race/SQL tests pass; password-hosted Flutter/device and cross-app acceptance remain |

| T-024 | IN_PROGRESS | Reason/confirmation, duplicate guard, secure RPC, no automatic mutation retry, cache invalidation and refreshed status tested with synthetic transport; production action now uses named-session contract; actor/reason/time history now wired; hosted Flutter/cross-app acceptance remain |

| T-030 | IN_PROGRESS | Production server-search directory and group roster with read-only contacts, bounded pagination and logout guard tested; full profile/membership and hosted Flutter acceptance remain |

| T-031..T-034 | NOT_STARTED | Live academic/attendance/finance history and notes require remaining read contracts/UI |

| T-040..T-042 | NOT_STARTED | Live secretaries/notifications and design polish |

| T-050..T-054 | NOT_STARTED | Full integration/security/performance/signing/cross-app acceptance |

| T-LATER-01..03 | DEFERRED | QR scanning, push, public stores/billing |



## Original hosted milestone (approved in chat; historical)



- Supabase CLI 2.121.0 authenticated through user-authorized login. Discovered the

  sole project centerly-dev, reference yfeubomyglmhuwizaqoj; repository linked.

- Read-only preflight: zero business tables/policies/Auth users/migration history;

  pre-existing rls_auto_enable() helper. No application-name conflicts found.

- Owner separately approved the nine migrations, four development accounts/fixtures,

  and public signup denial. Deployed exactly versions 202610180001..202610180009.

- Postflight: 18 application tables, 30 policies, every table ENABLE/FORCE RLS,

  zero anonymous Centerly RPC grants, zero unsafe Centerly definer search paths.

- Four synthetic accounts and two isolated fixture tenants provisioned through

  approved trusted tooling. Credentials only in ignored .env.development-accounts.json.

- Public signup disabled; email/password login enabled. Corrected the CLI email

  provider flag after verification showed it also disabled email login. Only scoped

  Auth settings changed; undeclared hosted properties preserved.

- Security Advisor warnings documented in BACKEND_REVIEW.md; none silently hidden.



## App and tooling changes



- Preserved theme/fonts/assets/widgets and baseline teacher screenshots. Replaced

  fake-token login, role selector and cached/query role authorization with live

  get_current_profile() validation. Public registration routes removed.

- Supabase session persisted via FlutterSecureStorage; SDK refresh/logout, duplicate

  submission and stale-result protection; periodic/resume account revalidation.

- Production route never enters secretary operations or mock-data screens. Initial

  dashboard reads real server aggregates; unfinished tabs explicitly show pending.

- Arabic/English errors/support labels; no invented support number. Config rejects

  privileged keys and remote plaintext HTTP; Android INTERNET permission added.

- Unused Firebase dependencies removed (no app references, push deferred). Existing

  REST adapters are unreachable from production and retained for staged cleanup.

- Added CI, setup docs, codegen drift check, schema manifest, native/hosted/local

  auth tests, real PostgreSQL 17 concurrency tests and trusted provisioning scripts.



## Earlier baseline verification (historical)



- pub get and codegen: PASS; analyzer: PASS (no issues).

- Debug APK with public hosted config: PASS; debug/profile builds on clean checkout: PASS.

- Local PostgreSQL/PGlite: 64 authorization/business assertions PASS.

- Independent PostgreSQL 17.10 connections: 11 race assertions PASS.

- Hosted Auth/REST/RPC: 36 fixture-only assertions PASS (including real concurrent

  payment/cancellation calls, tenant denial and inactive access).

- Actual hosted Dart SDK: teacher login/profile/refresh/logout, secretary rejection

  and invalid credentials PASS. Local unit tests cover secure storage, stale results,

  duplicate taps, errors and profile validation. Final baseline suite: 25 PASS; one opt-in hosted test skipped in default run (passed separately).

- Native Windows login, secure persistence, restore and logout: PASS after removing unused Firebase packages. Android device disconnected; no Android device

  installation or iOS native verification claimed.

- Clean checkout of 3f6f16b: all 12 documented commands PASS. Remote GitHub CI execution remains pending push.



## Files and decisions



See git diff / local commits for full file list: .github/workflows/verify.yml,

docs/{SETUP,VISUAL_PRESERVATION,BACKEND_REVIEW,HOSTED_CHANGE_REVIEW,DEVELOPMENT_ACCOUNTS}.md,

lib/app and core auth/config/router, auth domain/data/presentation, initial dashboard,

translations, pubspec/lock, Android manifest, supabase config/admin/tests/manifest,

test auth/visual helpers and integration_test/auth_session_test.dart.

The two original migration fixes occurred before first deployment; deployed files

are now immutable and hash-checked. No further schema changes are approved implicitly.



## Exact next task / blockers



T-023/T-024 detail and read-only attendance are wired against approved deployed

202610190002. Password-hosted Flutter/device acceptance remains open; SQL checks

are not substitutes. Next eligible T-030 profile contract is prepared locally in

`supabase/proposals/202610190003_student_profile.sql`, with review in

`docs/STUDENT_PROFILE_CHANGE_REVIEW.md`. It is not a managed migration and requires

separate explicit approval before hosted activation. No other deployment is authorized.

Support remains configurable/pending. Existing uncommitted SDK/iOS/config work

and the user-added root plan are preserved. Physical TalkBack/safe-area/Figma QA,

backup/restore, monitoring, device/signing and Secretary acceptance remain pilot gates.



## Approved session-detail deployment — 2026-10-19



Deployed only `202610190002_session_detail.sql`, exact reviewed SHA256

`7a93684737cab4be2b9b0a281c000c139271770532131533f92c54615f7d8273`.

Preflight matched all ten pinned local hashes and remote SQL bodies; dry run listed

only this version (no seeds/roles, vault skipped). Postflight matched all eleven

remote SQL bodies and expected 18 tables/30 policies/four synthetic accounts.

Read-only SQL role checks passed: teacher reads, other-tenant NOT_FOUND, both

secretaries FORBIDDEN_ROLE, anonymous execution denial, missing-session NOT_FOUND,

unprovisioned ACCOUNT_INACTIVE. Function is definer with empty search_path,

authenticated grant, no PUBLIC/anon grant. No fixture/Auth configuration changes.

Existing teacher fixtures: two sessions; counts and bounded first pages agree with

persisted rows. Zero positive not_marked/cancelled-history rows; multi-page and

positive pending/cancelled-history cases remain local-only. Existing inactive

account fixtures unavailable: positive inactive/subscription denial tested locally,

not claimed hosted. Password-based Auth/SDK acceptance still awaits credentials.

Hash pinned. Flutter T-023/T-024 integration is in progress; deployment alone does

not complete these tasks.





## T-023/T-024 Flutter milestone — 2026-10-19



Production dashboard and session cards open the real typed detail contract. The

Teacher UI provides all/present/absent/excused/not_marked filters, bounded cursor

pages, manual finalization and last-sync timestamps, student/marker/update data,

and cancellation reason/actor/time. No attendance edit/finalize or automatic

absence controls exist. Missing rows are explained separately from not_marked.

Refresh resets accumulated pages and shows corrections after finalization; late

filters, duplicate pages and access revalidation fail safely. Existing cancellation

reason/confirmation/conflict reconciliation remains; ended detail actions use server

sync time. Return from detail refreshes parent aggregates/list. Backend notification

creation has local coverage; Secretary reception is not claimed verified.



Fresh checks: analyzer PASS; final combined Flutter suite 59 PASS/1 hosted opt-in SKIP.

Local SQL: 90 business assertions PASS; session detail 33 PASS; independent native

concurrency 11 PASS; tokenizer 1 PASS; eleven immutable hashes/zero pending PASS.

Configured debug APK compiled successfully (assembleDebug completed), SHA256

`98604e1fadbb13a08fb820df8a2a491bf218c14580833108c6aa1adf93c23316`.

No device installation/iOS/release build or current remote CI run claimed.



Continued T-030: bounded read-only profile/membership proposal prepared outside

managed migrations; 21 disposable PostgreSQL assertions PASS. Not deployed or

called by production. Next activation needs explicit reviewed approval; academic,

student attendance/finance/notes and later modules remain incomplete.





## Completion-path and approved profile milestone — 2026-10-19



Remaining checklist, implementation/acceptance estimates and separate owner-test/

pilot definitions: docs/TEACHER_COMPLETION_ROADMAP.md. Review all T-001..054 gates;

existing mock screens remain excluded. Plan range: 21–37 engineering days of

implementation plus 14–23 acceptance days, external waiting/Secretary work extra.



Owner separately approved only 202610190003_student_profile. Eleven-version

hash/remote SQL preflight and only-this-version dry run passed; deployed with vault

skipped and no seeds/roles. Twelve-version postflight passed; exact approved SHA

760740f7d4ea2c59cbaa645619fcf8f22375d73eadd115c12277c4ff3ce291e5 pinned.

Read-only existing-fixture SQL checks passed contacts/membership counts/scope,

tenant/secretary/anonymous/missing denial and grants/search_path. No fixture writes,

Auth/account changes or other migration deployed. Password SDK/UI remains pending.

Profile/membership Flutter integration is being tested; not marked fully accepted.

Remaining reads and event producers are being consolidated into one local package;

all unapproved production entry points default disabled until approved deployment.





## Controlled-pilot preparation — 23 October 2026



SEC27 remains complete; no mutations/cleanup were rerun and no hosted reads or writes were needed this milestone. Existing credential file was read securely by the artifact scanner; no credential values entered reports. Previous credentials-absent text is superseded. No production resources/accounts, migration deployment, push or publication occurred.



- CP-105: desired owner access to archived attendance/academics/notes/finance now has one concrete SHA-pinned local proposal in Teacher `supabase/proposals/controlled_pilot/`; operational edits restricted, reasoned payment reversals retained. 65 isolated PostgreSQL role-simulation checks PASS; this is not hosted SDK/UI evidence. Review: docs/CONTROLLED_PILOT_REVIEW.md.

- Void API review found Secretary browse balance bug; same proposal fixes it and adds consistent original/ledger/payable decimal aliases across invoice APIs. Existing UI fallback remains. 27 managed migration hashes unchanged; zero pending versions.

- CP-202/203: no connected Android or emulator; physical login/restore/logout, weak network, contact handlers, cross-app refresh, RTL/TalkBack and performance unavailable. Checklist and current configured APK hash: docs/ANDROID_PILOT_ACCEPTANCE.md. No physical pass claimed.

- CP-301/302/303: local CI extended for candidate/monitor tests; safe read-only shell monitor prepared/tested, not scheduled; deterministic artifact inventory and decompressed credential scan pass. Provider recovery, alert delivery, remote CI and signing remain gates. Configuration/recovery/notice/support handoff and exact owner inputs are in docs/PILOT_LAUNCH_DECISION.md and linked runbooks.

- Development synthetic testing may continue. NO-GO for real teacher/student data until owner/device, backend review/deployment, signed identity, provider recovery, privacy/support/monitoring and onboarding approvals close. Final blocker table is in docs/PILOT_LAUNCH_DECISION.md. No optional feature work added.



Final local verification: Secretary npm run check PASS (format, lint, 25 tests, configured web build); monitoring hook test PASS; three negative build release gates PASS; refreshed web/APK inventory and credential scan PASS (679 decompressed APK entries). Teacher proposal 65 checks PASS; 27 deployed hashes unchanged. No Flutter application code changed this milestone; prior Flutter results are historical, not rerun Android evidence.
