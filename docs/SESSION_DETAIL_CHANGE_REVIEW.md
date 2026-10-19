# Session detail read contract — proposal only

Not deployed or copied into managed migrations. Current hosted history remains
exactly ten versions through 202610190001. Separate owner approval is required.
Proposal: `supabase/proposals/202610190002_session_detail.sql`.
SHA256: `7a93684737cab4be2b9b0a281c000c139271770532131533f92c54615f7d8273`.

## Scope

Adds only `get_teacher_session_detail(p_id uuid,p_status text=null,
p_cursor uuid=null,p_limit integer=30) -> jsonb`, a teacher-only stable read:

- Session/group/subject fields, manual finalized metadata, cancellation reason,
  timestamp and same-tenant actor name; server sync timestamp.
- Explicit present/absent/excused/not_marked counts and filtered record count.
- Persisted attendance rows with student and marker names, timestamps and stable
  UUID cursor pages (1..100). Limit+1 detects the final page accurately.
- Detail retains cancelled-session attendance history. The deployed overview
  continues to exclude cancelled sessions from its counters.
- No inference from missing rows, time lock, conversion, backfill, mutation,
  public/secretary access or client-supplied tenant. Student phones/emails and
  financial data are not part of this response.
- Existing actor/subscription checks, explicit tenant constraints, qualified
  relations, empty search_path, anonymous/PUBLIC revoke and authenticated grant.

No tables, policies, account/configuration changes, fixture writes or other RPC
changes. The proposed read unblocks T-023 attendance and T-024 actor/history UI;
those Flutter features are not marked complete by this SQL proposal.

## Evidence / activation

`node supabase/tests/session_detail_proposal.mjs` applies the ten actual migrations
plus this proposal to disposable native PostgreSQL only: **31 assertions pass**.
Coverage: both tenant/role boundaries, parameters, accurate cursor end, missing/
pending distinction, post-finalization correction metadata, retained cancelled
history, same-tenant actor names, grants/search_path and empty attendance.
No hosted access or business data mutation occurred in this proposal test.
The managed migration manifest still reports ten unchanged / zero pending.

After separate approval, copy these exact bytes to the proposed managed version;
preflight all ten deployed hashes and remote SQL history, dry-run only the new
version with vault/seeds/roles skipped, deploy, and verify read-only hosted behavior
before pinning and wiring Flutter. Do not mutate hosted fixtures or restore/reset
passwords for tests. Password-based hosted Flutter acceptance still needs the
original credentials; SQL role checks do not substitute for Auth/SDK verification.
