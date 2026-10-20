# Students design implementation — 2026-10-20

| Figma frame | UI implemented |
| --- | --- |
| 961:5521 | Searchable student directory, payment badges, filters (Teacher add action removed by owner) |
| 961:5540 | Multi-select level sheet, background blur, clear/apply/cancel behavior |
| 961:5597 | Student identity, contact information, editable note and reference QR |
| 961:5669 | Attendance summary and history |
| 961:5743 | Exam scores and homework statuses |
| 961:5810 | Exact whole-pound summary and invoice rows |

## Integration and scope

The five-destination workspace's Students surface uses `FigmaStudentsPreview`
only with the debug UI-preview flag. The existing shared app bar, avatar editing,
notifications, bottom navigation and selected colors remain unchanged. Nested
profile pages have the Figma-style back navigation; native status/navigation bars
are not drawn into their content. Connected `StudentDirectory`, profile and
backend repositories remain intact. No hosted schema, account, permission or data
was changed.

Preview models live under `features/students/preview/`; focused display widgets
live under `presentation/design/`. `AppSurfacePanel` and `AppSurfaceSection`
provide shared card/heading layout; the groups panel delegates to the shared
panel with identical geometry. All new production Dart source files stay within
the repository's 100-line limit. Text is localized in Arabic and English through
the generated loader. Tables can scroll horizontally at large font sizes, and
profile tab labels remain unbroken. Existing exact money formatting is reused.

The workspace owns the synthetic student list so local notes survive
main-tab navigation during a preview session. Search and level/group/payment
filters combine; cancel preserves applied selections and clear resets the sheet.
The owner explicitly removed student creation from the Teacher UI; no add button,
dialog or local creation callback remains. Hosted creation permissions are unchanged. Note
editing validates trimmed text, updates its displayed date and affects only the
selected synthetic student. Data resets with the app session; persistence and
hosted writes are not implied.

Contact actions open a local sample-number/copy dialog. They do not dial or send
messages to the reference phone number. The QR is the original design image for
layout review, not an active attendance credential. Authentication, QR issuance,
scanning, attendance writes and real financial calculations are not activated
by this visual implementation.

## Design assets and data differences

Original exports, SHA256 values, root SVG dimensions and reused assets are recorded
in `FIGMA_STUDENT_ASSETS.json`. Temporary Figma URLs are absent from runtime code.
The referenced React `3DAvatars26` kit component has no Flutter implementation in
this repository; its matching original avatar export is reused at 32px and 56px.
QR display uses the reference's 57.002 × 58.196 geometry inside a 64px tile.
SVG and image render dimensions are checked at actual callsites in design tests.

The sample keeps a student's full name consistent between directory and profile,
where the references used two different names. Attendance is calculated as
24 / 30 = **80%**, correcting the reference's inconsistent 85%. Header badges and
summary share this calculation. Payment display retains the owner's grouped
numbers and `جـ` symbol. The sample summary is internally exact:
unpaid profiles use 1,900 = 1,300 + 600; paid profiles use 1,900 = 1,900 + 0.
Both summary and invoice table derive from the same two synthetic invoice records
(900 and 1,000). The second invoice is partial or settled according to the same
payment status used by the directory badge. These are local profile fixtures,
not the connected tenant's full ledger.
No hosted financial or attendance acceptance is claimed from these fixtures.

## Verification

Rendered all six states in Arabic and English to
`docs/screenshots/figma-students/` and visually compared them with their Figma
references. Twelve further cases cover 320px width at 200% text. Interaction tests
cover combined filters, cancellation/reset, no results, absence of student-creation controls,
note validation/isolation, all four profile tabs and exact summary arithmetic.
Existing workspace navigation and groups design regressions passed.

Full local analyzer: clean. Full Flutter suite: **176 passed, 1 hosted opt-in
skipped** before final attendance-label polish; affected render, interaction,
workspace and translation tests rerun after polish. No numeric pixel-diff or
physical-device comparison is claimed. No restart or APK build was performed.
New assets may require one owner-initiated Stop/Run if the active bundle predates
these files.
