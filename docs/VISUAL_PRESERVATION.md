# T-002 — preserve, repair and migrate incrementally

Decision: keep the existing application. ADR-001 applies: reusable teacher cards,
Arabic copy, Cairo typography, blue palette, icons and navigation are retained.
Existing approved Figma PNGs under figma_screens/ remain untouched; no redesign.
The buildable baseline and working widget composition do not justify a new app.

Captured actual existing shell widgets with bundled Cairo/Material icon fonts at
390x844 Arabic RTL. Files under screenshots/e1312a2 show home, groups and sessions.
The harness uses the baseline mock fixtures for visual verification only; these
fixtures are never evidence of live operational data.

Visual inspection compared these captures with the corresponding original PNGs:

| Screen | Preserved | Existing differences recorded for T-042 |
|---|---|---|
| Home | Blue header, two stats, white rounded lesson cards, financial summary | Demo counts/dates differ; header avatar and some alignments differ |
| Groups | Search, grade headings, blue accents, rounded cards, next-session row | Existing content/dimensions differ; no pixel-perfect claim |
| Sessions | Day/week/month selector, summary, lesson cards, bottom navigation | Mock calendar/time values; status semantics need v6.1 migration |

No existing approved screen/assets were deleted. Baseline tests still cover
Arabic/English tab navigation; screenshot smoke tests check Arabic RTL and layout.
Production auth intentionally removes role selection, preset credentials, public
registration and fake success. Production workspace uses live reads and explicit
pending states instead of exposing prototype financial operations. This is a
product/security correction, not a new visual identity; full live screen fidelity
remains T-012/T-042. Do not mark those later tasks complete based on this ADR.

## Production workspace accessibility slice — 2026-10-19

Captured actual production TeacherWorkspace with synthetic RPC transport fixtures,
real Cairo and Material fonts, Arabic/English at 320x844 and 430x844, text scale 2:
`docs/screenshots/live-shell/`. Reproduce with:
`flutter test --no-pub test/live_workspace_test.dart --dart-define=CAPTURE_LIVE=true`.
These are test fixtures, not real tenant data or proof of hosted end-to-end behavior.

Inspected ar-320-scale2 against `figma_screens/داشبورد الأستاذ.png`. Font/palette/card
borders and spacing come from the existing design system; wrapped metrics remain
readable without a RenderFlex overflow. The live workspace is still a simplified
vertical aggregate composition: personalized blue greeting header, compact paired
stats, named session cards, detailed financial composition and notifications are
not yet equivalent to Figma. Do not mark T-012/T-042 visually complete. Test captures
currently cover scaled layout; 100% fidelity matrix and physical-device TalkBack/
safe-area acceptance remain open. No approved Figma reference was overwritten.

## Activated live reads and responsive composition — 2026-10-19

The shell capture matrix now includes Arabic/English, 320/430 pixels, text scale
1 and 2 (eight captures/tests). Compared `ar-430-scale1.png` with the original
teacher dashboard reference. Restored the blue header with white accessible
controls and paired metric layout at normal scale; larger text uses a single
column. Session, finance and manual attendance sections reuse existing cards,
fonts, colors and spacing. Student/group counts and Cairo server date are real
repository fields; fixture captures deliberately contain synthetic values.

Remaining intentional differences: generic account heading until a verified name
contract exists, student-directory/logout actions, no invented notifications or
avatar, no progress percentage combining daily receipts with all-time outstanding.
Finance labels explicitly state their distinct date scopes. This does not claim
full Figma parity or physical TalkBack/iOS/Android safe-area acceptance.
