# R2 activated — local owner testing ready

Owner-approved R2 transaction SHA256 `f157d3aed95331ba55ec5265ac8daaed112be2fb5763cdf094fc70d501666c30` was deployed to centerly-dev only as Teacher migration `202610230002_group_pricing.sql`. Migration body SHA256: `d3cf4a30a25cf6bf2d5d06f5c0c9fde905b3dff0a31c6a72dd893fc69ae51786`.

Preflight matched all 28 prior migration bodies and catalog. The dry run listed only the new migration; transactional push succeeded. Postflight matched 29 migration bodies, 66 functions and their grants, 18 tables, 30 policies and 24 triggers against local PostgreSQL. Both manifests now pin version 29.

All 18 account/business fingerprints are unchanged; all 16 business tables remain empty. Existing accounts and credentials remain unchanged. No fixtures were created and no earlier seed/reset package was replayed.

Actual authenticated SDK: 7 checks passed for identities, new RPC presence/validation, Teacher write-role denial and empty dues refresh. Actual connected Chromium: 6 checks passed for masculine instructions, group-first prompt, enabled group creation with prices and without capacity/year controls, removed grade navigation/filter and old grade routes redirected. No business write was attempted by these checks. Positive creation/enrollment/payment tests used local SQL and synthetic Auth: 40 SQL assertions, 16 browser tests. Manual hosted/device acceptance remains for the owner.

Secretary: http://127.0.0.1:5173/ . Connected development with group billing enabled. No stage setup is needed. The shared backend keeps its required internal grade reference; the Secretary interface has no grade-level section, filter or creation chooser.

Start: create «فيزياء ٣ ثانوي», monthly 700 and materials 300. Add «أحمد علي» and choose that group. Expect 1000 due automatically; collect a partial amount and refresh Teacher. Then test attendance, academics, guardian contact and cancellation notifications through normal actions. These instructions do not claim manual testing has passed.

| Remaining owner action                                              | Prepared                                                        |
| ------------------------------------------------------------------- | --------------------------------------------------------------- |
| Open both apps and perform the clean checklist                      | Connected website, deployed APIs, empty business data           |
| Reconnect/unlock Redmi with USB debugging if installation is needed | Configured Teacher APK is built; current adb list has no device |

Teacher APK: `build/app/outputs/flutter-apk/app-debug.apk`, SHA256 `8b301da2b694fbed9da1e768612f99ee3b433ec448fa59b32213127a961ca3a2`. Credentials remain in the existing ignored local credential file. Production hosting, paid services, distribution signing and real-customer onboarding stay deferred.
