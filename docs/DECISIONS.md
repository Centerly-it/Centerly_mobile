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
