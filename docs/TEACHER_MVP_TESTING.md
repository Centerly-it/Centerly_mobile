# Teacher MVP development testing

Target backend: centerly-dev, schema through 202610190010 (nineteen pinned versions).
Completion workflows are enabled by default only after approved deployment and
hosted verification. No public signup. Use the existing synthetic teacher account
from the restricted ignored development credential file; never distribute that
file, test binary or passwords with the APK. The normal APK contains public backend
URL/publishable key only. Support destination remains configurable and pending.

## Build and installation

Flutter 3.44.2 / Dart 3.12.2, Java 17, Android SDK 36. The five pre-existing lockfile
resolutions match this pinned SDK exactly (intl .20.2, matcher .12.19, meta 1.18.0,
test_api .7.11, vector_math 2.2.0); do not restore the incompatible Mac SDK versions.
Keep Android licenses accepted for any further SDK package installation.

```powershell
flutter build apk --debug --no-pub --dart-define-from-file=.env.local.json
adb devices
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Credential-free CI APKs are build checks only and cannot log in. Use the configured
local build command above for device testing.

The configured APK is build/app/outputs/flutter-apk/app-debug.apk (198667524 bytes),
Android 7.0/API24 or later, ARM64/ARMv7/x86_64. SHA256:
1c12d34f66855d641e176f2bb01c339972d970fd2f38926073230a488a659942.
Package currently
com.example.centrally, version 1.0.0+1, debug-signed for development only. Existing
installs signed with a different key cannot update in place; preserve any needed
local settings before uninstalling. Business data remains in the development DB.
Never use .env.native-auth.json to build the APK distributed for testing: it exists
only for local integration test binaries and contains a synthetic test password.
The verification JSON records the final APK checksum and actual checks/limitations.

## Short owner test script (synthetic data only)

1. Wrong password gives a localized error; secretary credentials are rejected.
   Correct teacher login opens the workspace. Close/reopen the app: session restores.
2. Home: refresh and select dates; inspect actual student/group/session counts,
   scheduled hours, collected/outstanding money and separate pending attendance.
3. Groups: server search/grade filter; inspect schedule/roster preview, open roster,
   then a student's profile. Confirm contacts/missing values and membership history.
4. Calendar: switch day/week/month and dates; inspect Cairo times, server statuses,
   session detail, four attendance filters, finalization/sync/marker timestamps.
   Existing synthetic late-correction session is thirty days in the past: expand
   the student attendance date range to include it. Pending is never absence.
5. On a future synthetic session only, cancel with a reason/confirmation. Refresh:
   cancelled status, actor/time/reason and retained attendance remain visible.
6. Profile: open academics, switch exams/assignments, date/group filters. Missing
   score differs from a true zero. Attendance history shows cancelled records while
   excluding them and pending from the marked denominator.
7. Finance tab/profile: switch invoices/payments, dates, group and collector; inspect
   due balances, receipts, reversals, collector and daily net totals. The displayed
   basis explains due-date invoice totals versus receipt-date collections. Teacher
   has no collect/edit/reverse controls.
8. Notes: edit/save/reload; leave a draft and confirm back-navigation protection.
   A competing editor produces a conflict; reload explicitly before resubmitting.
9. More menu: inspect own secretaries/status and request removal on a synthetic
   secretary. This requests operator action; it never deactivates an account.
   Notifications show real payment/reversal/cancellation/handled events; mark read,
   refresh and reopen. No demo events or fabricated success.
10. Disable network: reads show retry; mutations reconcile ambiguous results without
    automatic repeat. Restore network/refresh. Logout: protected/nested screens
    disappear. Teacher B must never display teacher A's students/records.

The existing synthetic hosted suite writes only fixture records: exams/assignments,
late attendance/finalization/correction, notes (restored content), invoices/payments/
reversals, cancelled sessions, removal handling and notification reads. Historical
test fixtures remain available; aggregate totals may grow between runs.

## Testing milestone versus pilot

Testing candidate means the agreed core screens call deployed contracts, core
placeholders are absent in the configured APK, automated checks pass and the APK
compiles. Native Windows hosted navigation supplements SDK/REST tests; it does not
prove Android secure storage, installation, performance or TalkBack behavior.
No physical Android/emulator was available during this milestone unless explicitly
recorded otherwise in verification. Record your device/model/Android version and
any failing step. Use synthetic data while the pilot gates remain open.

Pilot requires real-device storage/restore/update, accessibility/performance/offline
QA, app ID/signing/privacy/support/update policy, monitoring, encrypted backups and
a successful restore drill, plus the future Secretary cross-app matrix and owner
sign-off. Missing future Secretary acceptance does not block starting that app.
See SECRETARY_HANDOFF.md; no production/store/publication claim is made.

## Current UI review checks (2026-10-20)

In offline preview, tap the visible bell to open notifications. Tap the avatar edit
icon, choose a gallery image, cancel once, then choose a valid image and restart:
the device-local photo should remain for that account. No photo is uploaded. Check
Android background/process recovery and permission denial separately. iOS permission
metadata requires a full native launch when testing iOS. Native splash is visible
only on a cold app start; hot restart does not test Android 12 system-mask sizing.
The larger Flutter splash follows the unchanged native white launch screen.
