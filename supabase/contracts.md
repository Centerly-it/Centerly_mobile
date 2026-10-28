# Canonical shared backend contract

Teacher owns the40-version migration chain through `202610280001_group_billing_modes.sql`. Exact hashes live in schema-manifest.json; current behavior and deployment protocol are in [the shared contract](../docs/SHARED_BACKEND_CONTRACT.md). Development and production are separate projects; see [environments](../docs/ENVIRONMENTS.md).

Preserve tenant isolation, immutable financial/audit history and existing data. Do not replay historical acceptance/reset packages. Source changes require fresh exact-baseline/catalog verification and a candidate-only dry run before authorized hosted deployment.
