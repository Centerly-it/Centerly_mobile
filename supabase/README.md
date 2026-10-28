# Local shared backend

This directory is canonical for both the Flutter Teacher and React Secretary clients.
The current chain contains40 migrations through202610280001. Read ../CODEX_HANDOFF.md and ../docs/SHARED_BACKEND_CONTRACT.md before backend work. Hosted changes require applicable owner authorization and the documented exact-baseline/hash/catalog checks.

Run SQL tests without Docker:

```powershell
npm ci --prefix supabase/tests
node supabase/tests/run.mjs
```

PGlite applies actual PostgreSQL migrations using a test-only Auth shim. It does
not start Supabase Auth, REST, storage or independent concurrent connections.
Fixtures are synthetic and live in tests/fixtures.sql; do not load them into production.
No hosted seed creates passwords or public registrations. For full local Supabase,
install its CLI and Docker, initialize local configuration, disable signup, apply
these migrations and provision test Auth users with trusted tooling.
Read ../docs/SHARED_BACKEND_CONTRACT.md before integrating another client.
