CURRENT 23 October: owner-approved R2 deployed and verified on centerly-dev as migration 29. Connected creation/billing enabled; grade-level UI removed. All business data remains empty. Earlier pending/28-version statements below are historical. See docs/R2_ACTIVATION_ACCEPTANCE.md.

Creation R2 verification: 40 local SQL checks, 31 unit tests and 16 local synthetic browser tests PASS. Four actual connected Chromium checks also PASS with zero business writes: masculine instructions, group-first prompt, no capacity/year controls, and explicit pending-backend save gate. No new hosted data or migration was created.

# Current owner testing state — 23 October 2026

This update supersedes the retained-fixture state in SEC27/PILOT28/SIMPLE_FLOWS evidence, which remains historical. The owner explicitly requested deletion of all development synthetic business data on 23 October. No prior acceptance seed or cleanup package was replayed.

## Completed development reset

- Project `centerly-dev` / `yfeubomyglmhuwizaqoj` only. Full 28-version baseline/catalog verified before and after: 55 functions, 18 tables, 30 policies, 20 triggers unchanged.
- Verified exact two synthetic Teacher tenants and two active Secretary memberships; no records outside these tenants. Locked snapshot comparison guarded the single atomic TRUNCATE of the 16 business tables; no CASCADE, no disabled hosted triggers, no schema/account/Auth changes.
- Removed 222 rows, including students/groups/reference years, enrollment/session/attendance/academics/notes, all synthetic invoices/payments/attendance logs/audits, notifications and all three removal requests. All 16 tables are empty. Teacher/Secretary account profiles unchanged; existing login credentials remain valid.
- Private ACL-restricted recovery files: Teacher `build/owner-reset-20261023/backup.json`, `executed.sql`, `completed.json`. Backup SHA256 `998ef6feb1b3e08f2298edb7932efab2667e67d4fd25db9b7f1f0b225c303106`. Do not commit these files or expose their contents. `supabase/tests/development_reset_restore.mjs` restored every business table in disposable PostgreSQL, compared all data with the snapshot under UTC, revalidated all foreign keys, then rolled back. It cannot access hosted Supabase.
- Actual authenticated SDK checks for all four existing accounts and connected Chromium checks: 73 PASS, zero business writes. Secretary daily home and student/group/dues/notification lists show empty results. Old OWNER28-AR/SEC27 registries are marked retired locally; the Arabic seed explicitly refuses retirement replay.

## Prepared group pricing; awaiting the required backend review approval

Read `GROUP_PRICING_REVIEW_AR.md` for the single concrete review. Enrollment date anchors the month; 700 monthly + 300 one-time materials produces 1000 initially, then 700 per cycle. End-of-month/leap-year dates preserve the original anchor. Enrollment and billing are atomic; transfer and both memberships' billing are atomic. Repeat requests do not duplicate dues. Periods missed while the website is closed are caught up when dues are opened; no cron or paid services. Zero-price cycles are tracked so later price changes do not bill those cycles retroactively. Price changes settle elapsed cycles first. Withdrawal/archive stops future charges and keeps issued balances.

40 local PostgreSQL assertions PASS; 16 desktop/narrow-RTL synthetic Auth/SQL browser tests PASS, including group prices → enrollment → automatic due → partial payment → lost response/reconciliation → reversal. These are local simulation, not hosted pricing acceptance. Secretary 31 unit tests and lint/typecheck/build PASS. Teacher analyzer and 18 targeted Flutter tests PASS.

Hosted manifests/contracts remain at migration 28. No migration 29 is registered/deployed yet. Connected Secretary uses `VITE_GROUP_BILLING=false`; pricing fields and renewing writes are gated until reviewed deployment. Manual invoice creation and visible invoice/receipt numbers were removed from the operational UI. IDs/idempotency keys remain internal.

## Owner handoff and actual blockers

Secretary remains at http://127.0.0.1:5173 in connected development mode. Do not manually run old fixture seed scripts. Clean testing begins by adding a priced group, then Ahmed/Mohamed/Abdelrahman as synthetic students and enrolling them, after the pricing package is approved/deployed. Student creation requires a group and saves student, enrollment and charge atomically. The group form has no capacity or year chooser. All Arabic operational instructions use masculine wording.

New configured Teacher debug APK: `build/app/outputs/flutter-apk/app-debug.apk`, SHA256 `8b301da2b694fbed9da1e768612f99ee3b433ec448fa59b32213127a961ca3a2`. Connected development Supabase, preview disabled. Current USB `adb devices -l` has no connected device, so this APK is not claimed installed or device-tested. Earlier installed artifacts/evidence are historical.

| Blocker                             | Prepared                                                              | Exact owner action                                                                                                                                                  |
| ----------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Automatic group dues not yet hosted | Exact GP29 transaction, hashes, tests, gated UI, deployment procedure | Approve GP29-OWNER-20261023-R2 review for centerly-dev only                                                                                                         |
| Install latest Teacher APK on Redmi | Configured debug APK built                                            | Reconnect/unlock phone, USB debugging enabled and authorize this computer                                                                                           |
| Hands-on cross-app acceptance       | Clean backend, running website, existing accounts                     | After activation: create year/group/student; enroll; mark attendance; add academics; collect a partial amount; refresh Teacher; verify totals/contact/notifications |

Production hosting, paid resources, distribution signing and real-customer onboarding remain deferred and do not block development testing. No real-data readiness claim is made.
