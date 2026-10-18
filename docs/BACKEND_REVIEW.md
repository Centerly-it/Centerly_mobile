# Shared backend security and compatibility review

Reviewed the nine migrations from e1312a2 before first hosted deployment.
Local fixes made before deployment: migration 008 now revokes only Centerly RPCs,
leaving existing platform functions intact; migration 009 defaults dashboard date
on the Cairo-aware server. These nine versions are now immutable deployed history.

## Authorization findings

- Auth UUIDs are the only identity source; no user_metadata role authorization.
- All 18 tables ENABLE/FORCE RLS, using active teacher/secretary/subscription lookup.
- All cross-entity operational FKs include tenant identity, preventing guessed
  UUIDs from linking a tenant's group to another tenant's student or schedule.
- Teachers cannot write secretary-only records. Student notes are teacher-only
  writes; secretaries may read. No client controls identities/subscriptions/seats.
- Money, attendance/finalization, cancellation and removal requests have no direct
  authenticated table write grants. RPCs infer actor/tenant, use empty search_path,
  scope object lookup and reject inactive actors. Helper EXECUTE grants are narrow.
- Ledger/audit tables reject UPDATE/DELETE and preserve reversals. Payment retries
  use a tenant/key advisory lock plus invoice row locks; overpayment is rejected.
- Session row locks serialize marking, finalization and cancellation. Corrections
  after finalization require reason. Cancellation preserves attendance history.
- Service-role is used only in approved operator tooling for Auth admin APIs.
  Business provisioning/status changes use trusted CLI SQL, not public RPCs or
  reliance on broad service-role REST table grants. Flutter receives public key only.

## Real verification and limitations

PGlite: 64 authorization/business assertions. Native PostgreSQL **17.10**: 11
independent-connection race assertions (payment retry/overpayment, correction and
cancellation). Hosted database is PostgreSQL 17.11. Native tests use a synthetic
Auth shim; hosted Auth/REST/RPC tests are reported separately in progress.
Hosted introspection after deployment: nine migrations, 18 tables, 30 policies,
zero non-forced-RLS application tables, zero anonymous Centerly RPC grants,
zero Centerly definers with unsafe search_path. Existing platform helper remains.

Security Advisor emits expected authenticated-executable definer warnings for
approved role-checking RPCs. It also flags the pre-existing platform helper's grants
and disabled leaked-password protection. These are documented, not claimed resolved.
No third-party paid protection/plan changes were made.

## Future React compatibility

Schema/functions are plain PostgreSQL and Supabase Auth/PostgREST: no Flutter-only
backend dependency or second user store. Named RPC arguments/status strings and
error codes are in SHARED_BACKEND_CONTRACT.md. Money uses server decimal arithmetic;
client apps display aggregates and never guess paid balances. Store instants in UTC,
use Cairo server dates, and paginate reads. Transfer existing migration history intact
when the Secretary repo becomes canonical. Never replay or duplicate these versions.

## Remaining release gates

Capacity and seat enforcement, schedule-closing/revision contracts, invoice void,
complete student/report endpoints, DST-edge generation tests, backups/restore,
export/privacy operations and full Secretary-to-Teacher acceptance remain open.
Privileged manual provisioning must check seat allocation until enforcement exists.
Do not interpret development connectivity or passing tests as production readiness.
