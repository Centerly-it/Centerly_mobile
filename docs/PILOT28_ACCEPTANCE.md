# Local owner-testing handoff - 23 October 2026

Exact approved transaction deployed to centerly-dev as 202610230001. Raw SHA256 remains 6651349fd37f8d4682fa4bd42bfadda664b2eab910026ee9a0bde0c111c78cc2. Preflight verified all 27 versions/catalog; dry run listed only the new version. Postflight verified 28 exact bodies, 55 functions, 18 tables, 30 policies and 20 triggers, including grants/RLS. All 18 business-table fingerprints are unchanged. Tenant A net/outstanding remain 240.00/200.04; B 0.00/0.00. Removal request 85bf1f3c-abd3-4220-858f-709b21bdd793 remains pending, synthetic Secretary A remains active. No SEC27 rerun/cleanup or new fixture/account/password/Auth configuration changes.

Actual authenticated SDK: 37 read-only checks PASS. Actual Secretary Chromium login/reads/logout PASS. Actual Windows Teacher archived directory -> profile -> read-only notes PASS. Local SQL-role simulation 65 checks, Secretary PGlite 53, targeted Flutter 20 and Secretary 25 tests PASS. Analyzer and enforce-lockfile PASS. Evidence modes are separate; see PILOT28_ACCEPTANCE.json.

Teacher fixes: archived directory uses existing owner-scoped SELECT/RLS with explicit ascending UUID pagination; nullable archived_at parsed; archived profile notes are selectable/read-only without Save. Native testing caught the SDK descending default; corrected and verified natively plus a pagination regression. SDK-pinned dependency versions were aligned with installed Flutter 3.44.2; no optional dependency upgrade.

Configured Teacher debug APK SHA256: a7f2d490be888d34d71b7a9f35ad8a7a72422bf8e27692c28b73eb32b7227a76. Centerly-dev, preview=false, finance filters=true. Credential scan PASS: 679 decompressed entries, zero matches. Final APK installed as update on authorized Redmi Note 9S / Android 12 API31; launch succeeded. ADB cold activity start measured 8265ms in debug; this is not time-to-usable or performance acceptance. Owner login, weak-network/contact/RTL/TalkBack/performance and manual cross-app checks remain unaccepted.

Secretary stays running at http://127.0.0.1:5173 (loopback, connected development, SQL fixture=false). Use OWNER_LOCAL_TESTING.md for secure account access and the six-step checklist. Existing SEC27 records are read-only. No production decisions block local testing.

| Remaining local action | Prepared work                                                                  | Exact owner action                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| Manual testing         | Installed APK, running website, credential-file instructions, retained history | Open both apps; privately use teacher-a / secretary-a and follow the checklist                                             |
| Fresh write testing    | OWNER28_SYNTHETIC_SCOPE.md with explicit ceilings and no SEC27 reuse           | Approve OWNER28-20261023 only if fresh create/edit/attendance/payment actions are wanted; until then read retained records |

Production hosting/paid resources/distribution signing/privacy launch/real onboarding are deferred. No production creation, account changes, push or publishing occurred. Development testing readiness is not real-customer data readiness.
