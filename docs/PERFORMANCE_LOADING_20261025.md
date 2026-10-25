# Teacher performance and loading pass — 25 October 2026

Implemented on the production-connected Flutter routes. No Secretary changes, hosted SQL, account changes, financial writes, publishing, APK builds or installation in this pass. Earlier owner-requested finance scrolling/menu, student avatar and archived-student menu edits are included in the same delivery.

## Evidence and baseline

Flutter 3.44.2, Dart 3.12.2, Windows Flutter widget-test runner. The reproducible 1,000-row, 390 × 909 reference constructs 1,000 item widgets with the former eager pattern. The new production `PagedReadBody` constructs 13 initially and 20 cumulatively after a 600-pixel drag. These are construction counts, **not** FPS, latency, native/profile measurements or a percentage speedup. See [machine-readable evidence](performance/20261025.json) and `test/performance_viewport_test.dart`.

The final ADB inventory had no device connected. No running application was restarted, replaced or attached for profiling. Device frame/raster timings, memory residency, startup duration and slow-network field behavior remain unmeasured; no native-performance claim is made.

## Changes

- Extended the existing `PagedReadCubit`, rather than adding a competing paginator. It owns request generations, independent initial/refresh/more flags, one load-more at a time, end detection, incoming duplicate/empty-ID validation, opaque cursor-cycle rejection, disposal and failed-page retry. An ID set validates each incoming batch without rescanning all previous records. Endpoint-specific ordering, limits, server totals and summaries remain in repositories. A failed retained filter restores its displayed query so the next request cannot append records from a failed filter.
- `MappedPagedCubit` adapts existing feature state APIs synchronously to that engine. Students (including archived reads and group rosters), groups and session attendance now share it. Existing finance/invoices, attendance/academic histories, profile memberships, secretaries and notifications already use the same engine. Directory endpoints have no total: their internal adapter sentinel is never presented as a server count.
- Same-query refresh retains content; access/auth denial clears it. Filter generations suppress late responses; the existing account/session guard suppresses results after token/account changes. No authenticated cache or sensitive records were moved to disk.
- Lazy item construction now covers shared paged card lists, students, groups, session cards and session-detail attendance. Stable record keys preserve row identity. Calendar day markers use date sets instead of scanning every session for every calendar cell. Retained inactive workspace tabs disable tickers. No blanket repaint boundaries, isolates or speculative business-data memoization.
- The existing shared skeleton API now uses pinned Skeletonizer 3.0.0; unused Shimmer was removed. SDK resolution updated Flutter-pinned transitive versions in the lockfile, without dependency overrides. `pub get --enforce-lockfile` and code generation were checked. Presentation-only `Bone` geometry never enters repositories, financial calculations or actions. One lightweight skeleton tree renders each loading block; interactions and fake semantics are excluded, with one localized loading announcement. Reduced motion, accessibility navigation, inactive tabs/routes and app background use a nonanimated effect. Tickers stop/dispose normally.
- The 1,254 × 1,254 default student PNG remains byte-for-byte intact. Lists and avatars now request decoding at physical display size. A 32dp avatar at 3× targets 96 × 96 pixels: theoretical RGBA storage is 36,864 bytes versus 6,290,064 for a full decode. This is an estimate, not a measured resident-memory reduction. No network-image consumers were found; no image-cache package or bulk precache was added. Existing bounded teacher-thumbnail disposal remains intact.
- Successful transport JSON is encoded once for both the coalescer and memory cache. Per-caller decoding, refresh bypass, 64-entry/2 MiB cache bounds, 256 KiB per-entry ceiling, TTLs and project/user/session isolation remain unchanged. Explicit keyboard-submit search semantics and mutation retry/reconciliation rules remain unchanged.

## Loading coverage and exceptions

Dashboard/finance overview: summary geometry. Groups/rosters/students: card or avatar-row geometry. Profile/session detail: identity and content geometry. Calendar: controls, calendar and cards. Attendance/academics: table geometry through shared reports. Invoice/receipt lists and notification payment details: receipt geometry. Secretaries/notifications: card/row geometry. Notes use skeletons only for the initial read; saving retains its progress feedback. Existing content stays visible during refresh where supported; additional pages use a small footer/progress state.

Login, saves, cancellation, downloads, authentication checking and other action progress were deliberately retained. Small dashboard compositions, the calendar grid and horizontally coordinated academic/attendance table composites remain eagerly composed to preserve geometry and horizontal alignment; their requests/pagination still use the shared mechanism. Device profiling should determine whether further table virtualization warrants the added layout complexity. Arabic/English and the current light visual identity remain; skeleton colors also derive from the active color scheme.

## Validation

- Full Flutter suite: **293 passed, 1 pre-existing skip**.
- Final focused pagination/query/disposal, session and connected-route regressions: **12 passed**.
- Final reduced-motion/semantic/transition and background-ticker skeleton tests: **3 passed**. Structural viewport tests and page retry tests passed separately.
- Explicit offline UI-preview suite: **3 passed**.
- Analyzer: no issues; formatting, dependency lock enforcement and `build_runner` checked. Source-code generation did not introduce unrelated generated changes.
- Existing full-suite finance precision, attendance, protected logout/account isolation, note workflows and read-cache safety tests passed. No APK/device acceptance is claimed.
- Arabic/English 320px, 200% text skeleton captures were inspected; contrast was corrected after visual review. See [Arabic](performance/skeleton-ar.png) and [English](performance/skeleton-en.png).

Local test logs live in ignored `build/performance/`. The report and synthetic evidence contain no credentials or real customer data.
