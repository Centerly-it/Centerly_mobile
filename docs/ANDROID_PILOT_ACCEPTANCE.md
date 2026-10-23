## Current local-owner milestone — 23 October 2026

Production hosting, paid services, distribution signing, privacy launch and real onboarding are deferred and are not local-testing blockers. The exact approved migration 202610230001 is deployed to centerly-dev; existing synthetic records/history were preserved. Secretary is running at http://127.0.0.1:5173 in connected development mode. A configured non-preview Teacher debug APK was built and installed successfully on the connected Redmi Note 9S (Android 12, API31); launch command succeeded. Phone/manual acceptance has not passed by inference. See OWNER_LOCAL_TESTING.md and the proposed OWNER28_SYNTHETIC_SCOPE.md. New fixture mutations require scope approval; existing retained records are read-only. Historical launch gates below do not redefine this local milestone.

# Physical Android acceptance — 23 October 2026

Result: UNAVAILABLE. `flutter devices` found Windows, Chrome and Edge only; `flutter emulators` found none. No Android install, login, radio shaping, contact handler, TalkBack or performance result is claimed. Existing Windows/native and synthetic browser evidence is separate.

Use the current configured development APK, not a preview/test runner: `app-debug.apk`, SHA256 `a7f2d490be888d34d71b7a9f35ad8a7a72422bf8e27692c28b73eb32b7227a76`. Full inventory: `pilot-artifact-manifest.json`. It targets centerly-dev, preview=false, finance movement filters=true; it is debug-signed and unsuitable for real-data distribution. Scan passed including 679 decompressed APK entries, zero credential matches.

Record tester/date, model/Android version, APK hash and each PASS/FAIL with redacted evidence. Prefer the intended owner's lowest-spec phone. Install with `adb install -r PATH`; first verify device authorization and existing application identity. Never uninstall an app containing unreconciled data.

| Check | Acceptance / evidence | Current result |

| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |

| Login, restore, logout | Original synthetic credentials entered privately; valid/invalid login; force-stop/reopen; offline logout then reopen; switch tenant with no old content | Unavailable |

| Weak network | Airplane mode and throttled Wi-Fi: bounded loading, useful retry, no false success; restore connection and refresh; no silent duplicate/replayed write | Unavailable |

| Cross-app refresh | Read existing retained SEC27 records in both apps and compare receipt/reversal, void payable=0, cancelled attendance and note history. Never rerun SEC27 mutations | Unavailable |

| Contact actions | Synthetic/dedicated tester contact only: open dialer/email/support correctly; cancel before placing call/sending; absent handler fails safely | Unavailable |

| RTL/accessibility | Arabic/English, RTL money/date order, 200% font, small screen, keyboard, TalkBack labels/order, touch targets, contrast, no clipped critical actions | Unavailable |

| Performance | Record cold start to usable view (target <=3s), warm page load on normal network (<=2s), 10-minute navigation/scroll with no ANR/crash or growing memory. Targets proposed; debug timings are indicative only | Unavailable |

Do not save passwords, session storage, raw request bodies or student contacts in screenshots/logcat. Check Android contact intents and hardware back independently of Windows behavior. A signed profile/release candidate must repeat performance and identity checks before pilot distribution. New write scenarios require a separate synthetic staging namespace and authorization; these instructions grant none.
