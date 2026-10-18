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
