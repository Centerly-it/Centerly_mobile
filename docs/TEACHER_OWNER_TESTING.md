# Shared pilot checkpoint — 22 October 2026

Current status and stable task IDs: [SHARED_COMPLETION_CHECKLIST.md](SHARED_COMPLETION_CHECKLIST.md). Real credentials are available; real Auth/Chrome and native Windows reads passed. All 27 migration hashes/history/catalog verified. See [PILOT_EVIDENCE.json](PILOT_EVIDENCE.json), [CROSS_APP_ACCEPTANCE.md](CROSS_APP_ACCEPTANCE.md) and [PILOT_OPERATIONS.md](PILOT_OPERATIONS.md). No hosted business/schema/config changes or publication. The following checkpoint text is historical where inconsistent.

# Teacher owner-testing checkpoint — 2026-10-22

Status: Teacher implementation is ready for the agreed owner-testing scope.
The approved receipt read is deployed and verified; no pending implementation or
backend approval blocks that scope. Authenticated owner acceptance remains pending
original development credentials. The owner confirmed they are unavailable.
No account was created/reset/reconfigured and no hosted fixture or finance row was
mutated. Group-note editing and QR remain the previously agreed exclusions.

Checkout starts at main `a3bb5e0`; existing startup/splash/router/test/SDK-lock changes
were preserved. Changes remain in the working tree. Only approved migration 26 was
deployed in the follow-up; the original25 versions remain unchanged. No build or
restart was run for this deployment request. Evidence:
FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md and IMPLEMENTATION_PROGRESS.md.

## Route and action checklist

“Live” below means connected-mode source uses the real scoped repository/contract.
It does not claim that a password-based session or physical-device flow was tested.
Preview mode remains a separate explicit debug configuration. Synthetic widget/native
checks are labelled separately and do not establish hosted Auth acceptance.

| Route / action | Connected mode | Preview / scope limits |
|---|---|---|
| Startup, onboarding, login, account check, restore, logout | Supabase SDK + get_current_profile; existing session/role/tenant guards | Preserved owner's splash removal. Original development passwords missing; fresh SDK acceptance not run |
| Shared AppBar, greeting, avatar, menu | Teacher name from narrow `teachers.select('name').eq('id', validatedTenant)` under existing RLS; generic fallback if unavailable; local avatar | No editable Auth metadata trusted for identity/permissions. Avatar remains device-local |
| Home and date selection | get_teacher_overview + calendar + server finance summary; ongoing-session attendance scope/time and manual refresh | Unpaid drilldown opens real monthly dues; no invented distinct-student unpaid count |
| Sessions / Calendar day, week, month | get_teacher_calendar; latest shared controls, calendar markers, session cards; cancelled sessions retained | No fabricated roster counts on cards when contract does not supply them. Calendar uses bounded <=62-day reads |
| Session detail, four attendance filters, more, refresh | get_teacher_session_detail, persisted counts/actor/update/finalization/cancellation history | Teacher attendance remains read-only; no automatic absence or time lock. Search across attendance pages is not offered without a server search contract |
| Cancel session | Existing reason/confirmation/cancel_session/conflict/reload flow | Teacher may cancel eligible sessions; no attendance mutation |
| Groups list, search, grade filter, pagination | list_teacher_groups with real schedules, capacity/count and bounded roster preview | Reuses design panel/assets; no hardcoded future-session dates |
| Group detail / upcoming / view all | Real session repository, next 31 days preview (max three); full day/week/month calendar link | No schedule-derived fake occurrences; empty/error/retry and refresh supported |
| Group students / student profile links | Real roster preview and list_students filtered by group; paginated full roster | Teacher cannot add/edit/enroll students |
| Group notes | Editing hidden; explicit unavailable message | Owner chose exclusion for this milestone. No in-memory note is represented as saved; no new notes contract proposed |
| Student directory, search/group filter/more/refresh | list_students with server search, UUID paging and group filter; shared directory rows | Unknown payment/attendance/grade badges are not filled with preview values |
| Profile info and membership history | get_teacher_student_profile; contacts and paginated membership history, including inactive memberships | No fake avatar identity, payment badge, attendance percentage or group membership |
| Call / WhatsApp | Real scoped contact number; validated URI, external app intent, translated failure/copy fallback | No message is sent automatically. External call/WhatsApp completion requires owner/device acceptance |
| QR | Static/scanner feature deferred per approved plan; actual profile UUID shown as identifier | Placeholder QR bitmap and invented student code never shown in connected mode; identifier is not advertised as a QR payload |
| Profile attendance tab/report | get_teacher_student_attendance; server summary, cancelled/pending denominator rules, dates/group/status, pages; shared table | not_marked remains separate; teacher cannot change records |
| Profile academics tab/report | get_teacher_student_academics; exams/assignments/date/group/pages and server distribution; shared table | Missing score stays missing; actual zero stays zero; teacher cannot write academics |
| Profile finance tab/report | get_teacher_finance filtered by student/group/collector/date; designed invoice amounts/status and invoice/receipt drilldown | Void invoices remain visible in history; no sums from loaded rows; no finance writes |
| Finance overview | get_teacher_finance_overview; complete cash/cohort/debt/collector/method aggregates; exact BigInt cents | Month changes and refresh discard old pending results; no full local ledger constructed |
| Finance dues | list_teacher_finance_dues; search/status/student/group BEFORE paging; full filtered totals, server as-of date | Invoice count is not mislabelled as a distinct student count |
| Finance movements | Deployed list_teacher_finance_movements; month/group/collector/search/method/kind filters before paging, full filtered count/gross/corrections/net | Enabled by default after26-version postflight; no totals or filters computed from partial pages |
| Invoice detail and receipt history | get_teacher_invoice_detail; complete invoice header plus paged movements, creator/current collector/original collector/reversal references/reason | Header totals independent of page size; parent list refreshes after return |
| Finance calculator | Shared calculator uses complete server overview net/outstanding, integer money and explicit hypothetical target | No example target is prefilled; no transaction or stored result |
| Student teacher note | Existing get_teacher_student_note/save_teacher_note with exact optimistic version and preserved draft/conflict/reload | Durable student notes are distinct from excluded group notes |
| Secretaries / removal request | list_teacher_secretaries/request_secretary_removal, confirm and refresh | Request only; teacher never deactivates accounts |
| Notifications / mark read | list_teacher_notifications/mark_notification_read, unread count and pagination | No demo events in connected mode; no push/email promise |
| Support / language / logout | Existing configured support URL, AR/EN localization, SDK sign-out and cache/session invalidation | Credentials are never build defines for an owner build |
| Legacy admin/Secretary/mock routes | Unreachable from production AppRouter/workspace | Future React implementation is separate |

Lists use loading, localized error/retry, empty, refresh and bounded pagination where
contracted. UUID order, duplicate/backward pages, cursor integrity and malformed money
fail closed. Sensitive reads have no stored TTL. Client summaries never sum a partial
ledger. SQL/RLS remains authoritative for every permission.

## Implementation limitations and agreed exclusions

- No blocking implementation gap remains for the agreed owner-testing scope.
- Attendance free-text search across all pages is not offered; the deployed four
  status filters and pagination work. No unapproved attendance contract was added.
- Group-note editing is excluded by explicit owner decision. QR cards/scanning are
  deferred by the approved plan. Push/email and cloud avatar sync remain deferred.
- Teacher attendance, academics and financial records remain read-only.

## Acceptance checks pending credentials or owner operation

1. Restore the original development credential file at this exact local path:
   `/Users/mohamedsalem/Desktop/Centerly_mobile/.env.development-accounts.json`.
   It is ignored by Git and currently absent. The SDK test expects an `accounts`
   array with the existing `teacher-a` and `secretary-a` names and their original
   id/email/password fields. Transfer it privately; do not paste secrets into chat,
   command arguments, docs, application defines or builds. Do not provision/reset
   accounts to replace it.
2. Then run the opt-in SDK login/restore/refresh/logout/Secretary-denial test and
   password-authenticated connected navigation, filter/page/refresh reconciliation,
   account restoration/logout and access-revocation acceptance.
3. The owner requests the final configured Android build and performs connected
   device/contact checks. Prior native secure-storage/URL-handler/synthetic Finance
   smoke passed on Android17/API37; it does not establish password-based acceptance
   of the newly enabled receipt filters or external call/WhatsApp completion.

Independent verification while credentials were unavailable: exact26-version
remote body/catalog comparison,60 read-only filter reports/230 pages/2,466 checks,
additional role/tenant denials, anonymous REST401,251 Flutter PASS/1 hosted Auth
SKIP,3 activation/UI PASS,3 preview PASS,119 local SQL assertions PASS and clean
analyzer. These are separate evidence, not substituted for the blocked Auth checks.

## One final owner-testing build

Use ignored `.env.local.json` containing the verified development URL/public key,
`APP_ENV=development`, support URL and `CENTERLY_UI_PREVIEW=false`. No passwords or
service-role key belong in it. Existing SDK resolutions in the local lockfile were
preserved; current Mac SDK differs from the historical Windows/CI version.

```sh
flutter build apk --debug --no-pub \
  --dart-define-from-file=.env.local.json \
  --dart-define=CENTERLY_UI_PREVIEW=false \
  --dart-define=CENTERLY_FINANCE_MOVEMENT_FILTERS=true
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`. This is a development testing
build, not pilot signing/distribution. The26-version contract is approved/deployed/
verified and receipt filters are enabled. Do not run the build until the owner
requests it. The previous native test-harness APK was moved to ignored
`build/owner-testing/native-smoke-test.apk`; it must not be distributed as the owner
app. Run the command above to produce the actual configured owner APK.

```sh
# Once the original ignored credential file is restored:
flutter test --no-pub --dart-define=RUN_HOSTED_AUTH_TESTS=true \
  test/hosted_auth_integration_test.dart
# Credential-free native smoke (explicit synthetic transport):
flutter test integration_test/owner_native_smoke_test.dart -d emulator-5554 \
  --no-pub --dart-define=CENTERLY_UI_PREVIEW=false
```

Pilot signing/recovery and future React cross-app acceptance are tracked separately
in PILOT_RELEASE_GATES.md and SECRETARY_HANDOFF.md. They do not block finishing the
Teacher implementation or supplying the owner-testing configuration.
