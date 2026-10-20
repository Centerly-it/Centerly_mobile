# Sessions and attendance Figma implementation

Reference: [Centrely Tech](https://www.figma.com/design/iAEfLCYGeeGRYkvwUyEA9H/Centrely-Tech?node-id=961-6002).
Reviewed 2026-10-20 using design context and screenshots for all ten frames.

| Frame | Node | Implemented local state |
| --- | --- | --- |
| Day sessions | 961:6002 | Day selector, three statistics, current/other session cards |
| Week sessions | 961:6386 | Week navigation, seven selectable dates, period statistics |
| Month sessions | 961:6499 | Navigable month grid, status legend, month summary, selected-day list |
| Month empty | 961:6600 | Empty Friday selection with original calendar illustration |
| Session details | 961:5879 | Session information, expected/present summary, student tabs, actions |
| Cancellation | 961:5922 | Blurred backdrop, three reasons, required other reason, return/confirm |
| Attendance all | 961:6025 | Read-only sheet, counts, search, rows, fixed secretary notice |
| Attendance present | 961:6065 | Present filter with matching rows |
| Attendance absent | 961:6106 | Absent filter with matching rows |
| Search empty | 961:6143 | Live empty search with original illustration |

## Architecture and scope

`presentation/design/` contains composable Flutter widgets, original local Figma
assets and the section's design tokens. `domain/session_design_data.dart` is an
independent view-data model. `preview/` supplies explicit local fixtures and wires
the interactions. The main sessions tab selects this composition only when the
existing debug-only offline preview flag is enabled. Connected repositories,
authorization and hosted data are untouched. No production rollout is implied.

The owner-requested shared blue app bar and existing bottom navigation are retained.
Native OS status/navigation bars are not recreated from Figma's iPhone chrome.
Dates, labels and sample values are dynamic/localized rather than frozen to the
reference's April dates/counts. English mirrors direction and navigation arrows.
An optional unmarked filter is retained when that data exists; unmarked is never
automatically converted into absence. These are intentional compatibility choices.

Local cancellation changes only the current in-memory fixture and preserves its
attendance history. No notification is sent. The existing connected implementation
remains separate until this visual review is accepted and adapters are wired.

## Assets and verification

Original exported PNG/SVG assets are bundled under `assets/figma/sessions/`.
No temporary Figma URL is used at runtime and design screenshots are not UI assets.
Hashes/provenance: `FIGMA_SESSION_ASSETS.json`. Rendered implementation references
for all ten states: `screenshots/figma-sessions/`. Screenshots were visually inspected
against the reference for typography, spacing, asset slots and interaction states.
They are widget renders, not physical-device or numeric pixel-difference evidence.

Checks: full analyzer; all ten state renders; Arabic/English 320px/200% layouts;
filter/search behavior; cancellation validation/history; full Flutter regressions;
main-tab navigation with offline preview actually enabled. Exact results are in
`IMPLEMENTATION_PROGRESS.md`. Device visual sign-off remains with the owner.

No restart or APK build was performed. Because a new asset directory was added,
stop and launch the existing **Centerly (UI preview — offline)** configuration once
to install those assets. Subsequent code/compiled-translation changes support normal
Hot Reload/Restart. Full launch here does not authorize a hosted deployment.
