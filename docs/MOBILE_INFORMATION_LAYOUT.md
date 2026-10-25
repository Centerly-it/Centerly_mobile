# UI-MOB-025 — Organized operational details

Implemented in the Teacher Flutter checkout on 25 October 2026. No backend, financial calculation, authorization or history changes.

The connected invoice detail now separates student/group/status, a prominent outstanding balance, paired invoice/paid totals, due date and creator. Receipts distinguish collection/correction with a lightweight Material icon, signed amount, label/value metadata, original collector and preserved correction reason. Student financial records reuse the same receipt layout; shared financial drill-down rows preserve selectable text. Daily collection rows, group details, notification summaries and notification payment sheets use clear alignment, spacing and small built-in icons.

The audit covered connected finance, group details, notifications, session information/cancellation history, student contacts/notes, attendance and academics. Existing structured tables, session info panels, contact actions and deliberate free-text teacher notes were retained. Preview financial drill-downs benefit from the shared detail row. No production fixtures, decorative chart library, paid asset or new image dependency was added.

Shared AppInfoRow follows the existing colors, typography, RTL and spacing tokens. Amounts remain BigInt minor units from existing server-backed models. Narrow layouts wrap long names; the paired amount layout stacks at large text scales. Arabic/English JSON and the production CodegenLoader contain matching labels.

Validation:
- flutter analyze: no issues.
- flutter test: 270 passed, 1 skipped. Existing obsolete live_groups assertions expected a removed grade ActionChip; updated them to verify search/empty state and no grade control, without restoring removed UI.
- Four new layout cases cover Arabic/English, 320/390/800 logical pixels, 100/200% text, long names, exact partial amounts, negative correcting receipts and original/correcting attribution. Screenshots use explicitly synthetic test data.
- Existing connected navigation/finance regressions passed. The new Arabic screenshot was visually inspected: build/ui-review/invoice-ar.png. Full log: build/ui-review/all-tests.log.
- No hosted requests or mutations were needed for this visual work. Physical-device/owner visual acceptance remains pending. Reload the existing Flutter debug session to see the source changes; no app install or website publish performed.
