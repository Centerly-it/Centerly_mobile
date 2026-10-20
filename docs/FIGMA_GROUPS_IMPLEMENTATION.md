# Groups design implementation — 2026-10-20

| Figma node | Implemented state |
| --- | --- |
| 961:6366 | Groups grouped by grade, live local group/student search, next-session cards |
| 961:6356 | Empty groups illustration and copy |
| 961:6177 | Group detail with upcoming sessions, empty notes, five roster rows |
| 961:6259 | Note editor with required trimmed text and save navigation |
| 961:6268 | Group detail with dated saved note and view-all action |

`FigmaGroupsPreview` is used only when `PreviewMode.enabled`. Connected
`LiveGroups` and its repositories remain intact. The existing shared workspace
app bar and five-destination navigation are unchanged. New nested detail/editor
pages use the design's back navigation, with native system chrome rather than
drawn status bars. Existing owner-approved time direction and AM/PM placement
take precedence over static reference strings. Sample dates are design fixtures,
not claims about upcoming hosted sessions; weekdays are formatted from dates.

`GroupDesignCard`, `GroupSection`, `GroupInfoHeader`, note/student/upcoming rows,
grade heading and empty state are focused reusable widgets. Original exports are
local under `assets/figma/groups/`; original matching avatar and back arrow are
reused from the sessions assets. Provenance, SHA256 and SVG dimensions are in
`FIGMA_GROUP_ASSETS.json`. Original root SVG sizes are retained, including the
24px clock export. The desktop-only text-area resize glyph is omitted from the
native mobile field. The note form scrolls with the software keyboard.

View-all opens local upcoming-session, note and student lists. Notes are scoped
to the selected synthetic group and retained while switching main tabs through
workspace-owned fixtures. They reset on app/session restart; no persistent or
hosted write is implied. The reference roster uses repeated example names and
avatar images. Group-level notes are not wired to a hosted contract.

Validation: 10 Arabic/English state render tests; six 320px/200%-text tests; note
validation/isolation/save; three view-all routes; existing two main-tab navigation
tests and two translation parity tests. All passed. SVG render geometry is
checked against the asset manifest. Render images for all five states in both
languages are under `docs/screenshots/figma-groups/` and were visually inspected.
No numeric pixel-diff or physical-device comparison is claimed. No restart,
APK build, deployment or hosted mutation was performed. New assets may require
Stop/Run once if they are absent from the currently running asset bundle; the
agent has not restarted the user's app.
