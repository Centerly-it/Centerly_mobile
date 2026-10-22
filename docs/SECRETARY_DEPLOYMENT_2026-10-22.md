# Approved Secretary migration 27 — 2026-10-22

Deployed only `202610220002_secretary_operations.sql` to centerly-dev (`yfeubomyglmhuwizaqoj`) under explicit owner approval, exact SHA256 `b23fbfcc0ad6a55c21a03c4c4d1a85e42f3234cab63ef970ad72343633d6ff43`.

Fresh preflight matched every one of the 26 baseline bodies and the full catalog (45 functions / 18 tables / 30 policies / 10 triggers / zero enrollment timeline violations). Dry run listed only version 202610220002; --skip-vault, no seeds or role-file changes. Postflight matched all 27 exact bodies and the full local catalog (54 functions / 18 tables / 30 policies / 13 triggers / zero timeline violations). Function identity arguments, bodies and EXECUTE grants match local expected definitions; all three capacity/lifecycle/schedule guards are enabled. Table grants and RLS policies match the pre-deployment snapshot exactly. Teacher-only reads and Secretary-only writes remain protected.

Read-only hosted verification: 49 SQL-role simulation checks passed across both existing synthetic tenants, bounded entity reads/counts, foreign-ID/recipient denial, metadata independence, dashboard cash/due/outstanding reconciliation, Teacher/Secretary role rejection and unprovisioned/anonymous denial. Anonymous REST secretary_dashboard returned HTTP 401 / SQLSTATE 42501. No fixture, finance, account/password/Auth-configuration mutation was performed. SQL role simulation is not password Auth/REST/browser or Flutter acceptance.

The CLI history read initially failed with a temporary database-login connection error during overlapping inspections. Inspections were retried serially and completed successfully. The migration was applied exactly once; no credential reset/configuration change or migration replay occurred.

Canonical manifest now pins all 27 hashes; the Secretary consumer pins the identical manifest. The Secretary hosted extension was enabled only after postflight/catalog/role checks passed. The original Teacher worktree was not changed. This isolated canonical worktree contains the migration, tests, updated manifest and evidence for the requested canonical commit; no push or website publication is included.

Remaining hosted mutation acceptance needs separate approval of the concrete synthetic-fixture scope in Secretary `docs/HOSTED_FIXTURE_ACCEPTANCE_SCOPE.md`. Original development passwords remain unavailable. Local synthetic browser adapters do not establish hosted end-to-end readiness. The immutable migration's LOCAL REVIEW header is historical approved source text; its bytes must not be edited after deployment.

Evidence: `SECRETARY_DEPLOYMENT_2026-10-22.json`; checks: `supabase/tests/secretary_hosted_readonly.sql`, `secretary_operations.mjs`, `secretary_concurrency.mjs`. Canonical migration ownership remains in this Teacher repository.
