# Decisions

## ADR-001 — Preserve and incrementally repair the Flutter UI

2026-10-18. Source and Figma inventory supports reuse of existing teacher screens,
Cairo typography, blue palette, localization and reusable core widgets. Keep
GetIt, Cubit and GoRouter; migrate data sources incrementally. A blank app would
discard useful work. Runtime screenshot comparison and accessibility remain open.

## ADR-002 — Temporary canonical backend ownership (explicit user override)

2026-10-18. User explicitly overrode the plan's Secretary repository ownership:
this repository temporarily owns `supabase/migrations` for both clients.
No second backend. When the Secretary repository exists, transfer the files and
existing migration history unchanged; pin the owning commit in mobile docs.
Never reapply transferred migration versions. Hosted deployment requires approval.

## ADR-003 — Local SQL verification without Docker

Use pinned npm dependency PGlite (embedded PostgreSQL) to apply actual migration
SQL and test RLS with `SET ROLE authenticated` and a synthetic `auth.uid()` shim.
This is not Supabase Auth/PostgREST integration or independent concurrent sessions.
Full local/staging Supabase tests remain release gates. No hosted project contacted.

## ADR-004 — Manual attendance and immutable ledger

No time locks, scheduled absence conversion or attendance jobs in the backend.
Session-row locking serializes attendance/finalization/cancellation. Cancelled
sessions retain history and reject new marks; post-finalization correction requires
reason. Payments use positive decimal EGP entries; reversal rows subtract from
balance and preserve original entries. Invoice-row locks prevent overpayment;
advisory key locks serialize tenant idempotency across invoice IDs. Session
generation is bounded, on demand and idempotent; existing occurrences are preserved.

## ADR-005 — Supabase session ownership and unused Firebase dependencies

2026-10-18. Production auth now uses Supabase SDK and a dedicated session Cubit,
with secure platform storage and live database role/tenant checks. Cached REST
tokens and role query parameters are never authoritative. The old REST adapters
remain unreachable from production navigation pending incremental cleanup.
No Firebase imports or initialization exist in lib/. Remove unused firebase_core
and firebase_messaging dependencies; push is deferred and these packages forced
a large unrelated Windows SDK download during native auth verification.

## ADR-006 — Bounded session-scoped reads and Cairo display

2026-10-19. Cache approved read RPC responses in memory for at most 30 seconds/64
entries, not in SharedPreferences or exports. Invalidate on account checks, logout
and mutations; discard responses across generation/user/token changes. This uses
logical cancellation because Supabase RPC futures do not expose transport cancel
handles. Refresh bypasses cache. Mutations are not retried automatically.
Use the timezone package's IANA Africa/Cairo rules for displaying instants; use
server dashboard dates to initialize browsing, not the device's current calendar.
Keep invoice arithmetic on the backend. No shared schema or attendance behavior
change results from these client choices. UI reuses Cairo/theme/core cards; complete
Figma composition and physical-device accessibility remain separate acceptance.

## ADR-007 — Additive read contracts require hosted approval

2026-10-19. Existing deployed contracts lack group summaries, named session identity and
dashboard manual attendance counts. Prepare an additive migration rather than unrestricted client
reads or editing the immutable nine versions. The three new teacher-only reads are
locally verified and remain undeployed; no production call depends on them yet.
Review is docs/TEACHER_READ_CHANGE_REVIEW.md. Future React clients can reuse these
contracts after approval/version pinning; no duplicate backend or write grants.

## ADR-008 — Approved reads activated; operator verification without passwords

2026-10-19. Deploy exactly 202610190001 after explicit owner approval, exact
historical SQL/hash comparison and a single-version dry run. Skip vault updates,
seeds and roles. Pin all ten hashes after grants/search paths and read-only
synthetic-UUID tenant/role checks pass. No fixture or Auth-setting mutations.
Read-only SQL role/JWT-subject checks do not replace password-based Auth/SDK/UI
acceptance. Original credential file is unavailable; do not reset or reconstruct
passwords. Reconstruct only ignored public app config from verified project metadata.

Wire overview + named-session reads and group browsing; guard the whole multi-read
overview against account changes, not just individual HTTP responses. Reuse the
existing list_students contract for a bounded directory and group rosters. Full
student profiles, academic/financial history and detailed attendance remain
contract gaps; no unrestricted table-read shortcut or extra hosted migration.

## ADR-009 — Minimum supported Android build tooling

2026-10-19. Current installed Flutter requires Gradle 8.14, Android Gradle Plugin
8.11.1 and Kotlin 2.2.20. Upgrade those project versions after real configuration
failures, instead of disabling validation. Preserve app ID/signing behavior.
This changes local/CI Android tooling only; no backend or client data contract.
Do not infer APK success from configuration or dependency downloads; record the
actual final build result and keep historical pinned-SDK checks separate.
