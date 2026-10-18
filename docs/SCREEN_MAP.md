# T-001 screen and architecture audit — 2026-10-18

Figma metadata read successfully for file `iAEfLCYGeeGRYkvwUyEA9H`, canvas `0:1`.
18 committed PNG references exist in `figma_screens/`; dashboard PNG inspected.
These mappings establish screen coverage, not pixel-perfect runtime verification.

| Figma node / flow | Existing implementation / entry | Decision and gap |
|---|---|---|
| 114:4289 splash; 38:3182, 114:2943, 114:3644 onboarding | `/`, `/onboarding`; features/splash, features/onboarding | Keep branding/assets; verify first-launch persistence |
| 797:2995 login | `/login`; features/auth/presentation/views/login_view.dart | Keep layout; replace fake token, role selector, preset credentials and invented support number |
| No approved registration | `/create_center`, `/create_admin`, `/register_success` | Remove public registration routes in auth slice |
| 860:3512 teacher dashboard | `/home`; TeacherHomeScreen | Keep blue header/cards; fixed April date, counts and mock totals must become server data |
| 902:4223 groups; 857:3053 empty | TeacherGroupsScreen via Groups tab | Keep cards/search; local filtering, no pagination; teacher group tap currently does nothing |
| 947:4518, 947:6387 group detail | No dedicated teacher group detail | Implement read-only roster and schedule |
| 689:2690 day; 888:3360 week; 926:4742 month; 953:4802 empty | TeacherSessionsScreen via Sessions tab | Keep view selector; replace mock calendar and date handling |
| 683:3642 session detail; 843:3323 cancellation | TeacherSessionDetailsScreen, Navigator push | Keep layout/dialog; server cancellation with reason/concurrency required |
| 546:2673 attendance; 551:2305 present; 554:2536 absent; 699:2970 empty | TeacherAttendanceSheetScreen | Keep read-only table/filter; distinguish unmarked; show audited finalization |
| 628:2277 students; 682:3519 filter | features/students/students_demo.dart; profile reached from attendance | Promote paginated directory into app navigation |
| 879:3573 student information; 947:6200 note; 964:7234 success | TeacherStudentProfileScreen, StudentInfoTab | Reuse tabs and form; mock note mutation needs conflict-protected RPC |
| 506:1697 academic | StudentAcademicTab | Keep visual structure; real nullable scores and assignment status |
| 499:1271 attendance history | StudentAttendanceTab | Keep structure; document denominator, exclude unmarked |
| 506:1834 student payments | StudentPaymentsTab | Replace doubles/mock invoices with server ledger balances |
| No dedicated finance frame verified | Finance tab currently SecretaryFinanceScreen | Critical: teacher sees invoice/payment write controls; provide teacher-only read screen |
| My Secretaries (approved product extension) | TeacherMySecretaryScreen from dashboard | Reuse list/confirmation; replace mock request, retain account until admin acts |
| Notifications | notification_demo.dart; dashboard bell is decorative | Implement recipient-scoped real list and read marker |
| Secretary operations outside teacher product | screens/secretary and role-dependent shell | Remove production mobile entry paths; reuse appropriate visual components only |

## Reusable foundation

Feature-first auth has data sources, repositories, use cases, Cubit, Freezed states,
GetIt/Injectable and GoRouter. Preserve these boundaries while replacing REST adapters.
Core has Cairo typography, blue semantic colors, spacing/radius tokens,
Arabic/English JSON translations, responsive context extensions, shared fields,
cards, error/empty/skeleton states and session/status widgets.
Keep fonts, icons, onboarding art and logo. No wholesale rebuild warranted.

## Gaps and risks

- `LoginView._submit` writes `fake-dev-token` to SharedPreferences; the existing
  login Cubit is not called. Query/cache roles are editable and do not authorize access.
- REST base URL is `centerly.runasp.net/api`; no Supabase SDK, migrations or tests existed.
- Audit found REST logging of bodies/authorization headers and full BLoC payloads;
  removed in this slice. Secure-storage and cache token paths still disagree.
- `Session.attendanceLockAt` / `isAttendanceLocked` and secretary countdown implement
  obsolete v6.0 behavior; remove during integration. No equivalent exists in new SQL.
- All operational views consume mutable `CenterlyMockData`; financial success,
  notes, cancellation and removal are local changes, not persisted server operations.
- Existing models omit tenant-safe enrollments, ledger/reversals, finalization and audit.
- Screen files frequently exceed repository 100-line guidance; extract incrementally.
- Android package remains `com.example.centrally`; release uses debug signing.
- Firebase/Sentry dependencies exist without verified production configuration.
- Sole original widget test expected removed English prototype headings and omitted
  localization/theme; baseline failed. Real theme exposed invalid infinite-width
  buttons in rows and narrow-screen overflow; regression repair is in this slice.

## Baseline

Flutter 3.44.2 stable / Dart 3.12.2. `flutter pub get` succeeded without upgrades.
Doctor: Android licenses partly unaccepted; Windows/Chrome available; physical
Android device detected, no deployment to it performed. iOS cannot build on Windows.
Initial analyzer: 3 warnings + 1 info; initial test: 1 failed; format check: 40
files differ. Actual final verification results are in IMPLEMENTATION_PROGRESS.md.
