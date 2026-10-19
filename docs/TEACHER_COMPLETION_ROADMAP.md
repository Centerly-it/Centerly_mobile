# Teacher completion path — 2026-10-19

Baseline: branch codex/teacher-auth-foundation, 16b9599. Eleven deployed immutable
migrations. Real auth/dashboard/groups/sessions/detail/directory routes exist;
legacy mock screens are not production feature completion. This repository owns
the shared backend by owner override. Attendance remains manual indefinitely.

## Milestones and effort

Estimates are remaining focused engineering days (about six productive hours/day),
one experienced Flutter/Postgres engineer, Android first, existing design reused.
They include local implementation, meaningful tests and ordinary defect fixing;
acceptance effort is listed separately. These are planning ranges, not elapsed
agent runtime or a promised delivery date. External waiting is additional.

| Milestone / plan IDs | Remaining implementation | Acceptance effort | Prerequisites / uncertainty |
|---|---|---|---|
| M1 contracts + compatibility (T-010/013) | 3–5 days | 1–2 days | One reviewed package approval; hosted read-only verification; no fixture/Auth changes |
| M2 profile + academics + attendance (T-030/031/032) | 5–8 days | 2–3 days | M1; original test credentials; meaningful Secretary records |
| M3 finance + notes (T-033/034, Finance tab) | 4–7 days | 2–3 days | M1/M2; exact decimal display; concurrency, reversal/receipt reconciliation |
| M4 secretaries + notifications (T-040/041) | 2–4 days | 1–2 days | M1; trusted operator removal workflow; real event producers |
| M5 finish auth/shell/dashboard/calendar + polish (T-011/012/020..024/042) | 3–5 days | 2–3 days | Existing design/assets; support URL; server clock; Android device/Figma comparison |
| M6 integrated security/stability (T-003/050/051/052) | 2–4 days | 3–5 days | Above features; staging credentials, budget Android, CI execution |
| M7 signed pilot/recovery/cross-app (T-053/054 + shared release gates) | 2–4 days | 3–5 days | Signing/app identity/privacy/support, two devices, Secretary app/operator, tested backup restore |

Implementation subtotal 21–37 days; acceptance 14–23 days. Approximately 35–60
person-days (7–12 working weeks for one person), with some acceptance overlappable.
A feature-complete development APK for owner testing is roughly M1–M5 plus a smoke
pass: 18–31 days, about 4–7 working weeks. A larger redesign, missing Secretary app,
iOS issues or new business decisions can extend this; re-estimate after each milestone.
Secretary React implementation is a separate workstream and is not estimated here.

## Complete remaining checklist: implementation versus acceptance

Unchecked means remaining; a working UI or SQL alone does not satisfy acceptance.

| IDs | Implementation still needed | Acceptance still needed |
|---|---|---|
| T-001/002 | No new baseline implementation; retain screen map/assets/ADR | Preserve approved visual decisions as new screens replace mocks |
| T-003 | Resolve/pin current SDK/lock/iOS compatibility after reviewing owner edits; extend CI regression coverage | Current clean checkout build/codegen/format/analyze/test; remote CI; profile/release checks |
| T-010 | Completion package, canonical signature/version manifest and future React pin | Shared deployed version and owner review; no second schema |
| T-011 | Configured support destination pending; review device persistence edge cases | Real invalid/expired/offline/inactive/subscription/secretary-role tests; Android restore/logout; iOS if in scope |
| T-012 | Complete destination navigation, deep-link policy review, consistent scalable shell | Figma comparison, safe areas, AR/EN 200%, physical TalkBack and touch targets |
| T-013 | Typed models/repositories for remaining endpoints; session guards on every new flow | Pagination/cache/retry/unauthorized/stale-session tests for each feature; no unrestricted table-read shortcut |
| T-020 | Reconcile final filtered dashboard/finance UX and server-authoritative refresh | Hosted fixture totals, date filters, tenant denial, empty/offline states |
| T-021 | Any final browse/detail usability gaps; existing group browse is wired | 0/100/10k, AR edge cases, device pagination and real tenant checks |
| T-022 | Server-time-derived temporal status and final calendar consistency | Cairo DST/cross-midnight/skew, web parity, generation uniqueness/history |
| T-023 | Existing detail/read-only workflow implemented; finish any QA fixes | Hosted Flutter correction after finalization, indefinite pending, missing vs pending, all filters/pages, Secretary integration |
| T-024 | Existing cancellation workflow implemented; final reconciliation QA | Real teacher cancellation/Secretary notification, simultaneous conflict, retained history, device recovery |
| T-030 | Full profile, membership pages and links from directory/rosters | Scoped guardian contact, no edit controls, archived/missing records, narrow screens/long Arabic |
| T-031 | Academic pages, exam/assignment filters, missing values and score distribution | Real exam/assignment data matches, null not zero, Arabic fixtures |
| T-032 | Student attendance history/trends/date/group filters; explicit denominator/pending | Exclude cancelled from trend denominator; pending never absent; server counts/date boundaries |
| T-033 | Student/global Finance, invoices/receipts/reversals/collector/date/group filters | Exact ledger reconciliation, read-only, duplicate/overpay/reversal tests, Secretary totals |
| T-034 | Note read/edit/save, optimistic timestamp conflict and unsaved draft protection | Concurrent editors, teacher B/secretary denial, offline/ambiguous-save reconciliation |
| T-040 | Secretary list/status/email/removal request confirmation and pending state | No deactivate/CRUD; idempotent request; operator handling and refresh |
| T-041 | Recipient-scoped event list, safe payload rendering/read marking/refresh | Real producers only; recipient denial; unknown type safe fallback; no demo notifications |
| T-042 | Screen-by-screen design polish; dense data/EGP/Arabic typography | Small/large Android captures, contrast/targets/200%; iOS size if feasible |
| T-050 | New feature unit/widget/integration suites and CI wiring | Staging flows with two tenants, no skipped critical scenarios; Secretary workflows |
| T-051 | Privacy/redaction/dependency review, cache/logout/account switch fixes | Inspect APK/device storage/logs; privileged keys absent, no leaked PII, advisory disposition |
| T-052 | Fix measured startup/frame/network/reconnect issues | Budget Android benchmarks, slow/offline/retry/auth refresh and load evidence |
| T-053 | Approved app ID/version/signing/update/rollback/privacy/onboarding docs | Signed install/update/uninstall on two Android devices; release configuration verification |
| T-054 | Cross-app runner/manual script and operator request/recovery path | Recorded two-tenant Secretary→Teacher matrix, errors/recovery, owner sign-off |
| Shared backend/operations | Capacity/seats/schedule revisions/invoice void/export/privacy procedures reviewed with Secretary owner; backups/monitoring/runbooks | Restore drill, retention/access, export/deletion policy, session history/integrity, finance durability and staging→pilot checklist |

Deferred, not first pilot blockers: QR scanning/printing beyond optional static
value, push/background sync, guardian portal, offline mutation, subscription checkout,
public store publication. iOS native release is separate unless owner includes it.

## Definition: ready for your testing

A configured development Android APK installs and lets an authorized teacher log
in and complete every in-scope Teacher flow on synthetic development data: home,
groups/calendar, session detail/cancel, student profile/academics/attendance/finance/
notes, secretaries/removal requests and notifications. No required production tab
is a placeholder or mock. Manual attendance and exact finance rules are enforced.
Local automated checks and APK compilation pass; a real-device smoke pass and
known-issues/test script are supplied. Original credentials or an independently
approved provisioning action are required for login. A temporary pending support
link may be explicit in development. Hosted Auth/SDK smoke must pass before calling
the build verified for owner testing. No real student/financial data is required.

This is an owner development test candidate, not permission to onboard clients.
Secretary events may be exercised with already-approved synthetic tooling when
separately authorized; SQL impersonation does not count as a Flutter login test.

## Definition: pilot-ready

All above plus T-050..054 evidence: signed updateable Android build, stable app ID,
privacy/support/update/recovery policy, two-device performance/accessibility/secure
storage checks, staging security/ledger/concurrency tests, real two-tenant Secretary
cross-app workflows, operator provisioning/seats/removal process, monitoring and
restricted encrypted offsite backup with successful restoration drill. Owner signs
off known limitations before real student/finance data. Store publication is not
required. iOS pilot requires its own native/device/signing checks if included.

## Blockers and independent work

Owner/external inputs: original credential file (never paste secrets); approval of
one exact completion package before hosted deployment; later app identity/signing,
privacy/support destination, target devices and owner recovery/retention decisions.
Secretary app/repository/access is needed for cross-app acceptance; its completion
is not assumed. None prevents local contracts, interfaces, tests, UI or documentation.

Independent next sequence: package all known Teacher read gaps and locally verify;
build typed feature flows against those contracts behind an explicit inactive
configuration gate; production enable only after approved deployment verification.
Then profiles→academics/attendance→finance/notes→people/events→polish→integrated QA.
Do not repeatedly request approval for individual read functions in this package.
