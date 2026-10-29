# Documentation map

Start with [CODEX_HANDOFF.md](../CODEX_HANDOFF.md), [AGENTS.md](../AGENTS.md) and the [current checkpoint](../IMPLEMENTATION_PROGRESS.md).

## Current references

- [Environments](ENVIRONMENTS.md): separate dev/prod and private local configuration.
- [Shared backend contract](SHARED_BACKEND_CONTRACT.md): schema40, tenant authorization and financial invariants.
- [Operations and recovery](OPERATIONS_AND_RECOVERY.md): safe recovery and remaining owner actions.
- [Android updates](ANDROID_UPDATES.md): signed release and update policy.
- [Build2 upgrade-trial evidence](android-update-build2.json): current optional update; owner device result remains pending.
- [Billing modes](BILLING_MODES_RELEASE.md): monthly/per-session release evidence.
- [Subscription administration](SUBSCRIPTION_ADMIN.md): manual account access controls.
- [Privacy/support draft](PRIVACY_SUPPORT_DRAFT.md): draft, not approved launch policy.
- [Setup](SETUP.md) and [diagnostics/flavors](DIAGNOSTICS_AND_FLAVORS.md).

## Historical evidence

Other retained reviews, JSON snapshots and acceptance documents are historical evidence or dependencies of existing verification scripts. They are **not instructions to rerun** migrations, resets, SEC27, fixture creation or cleanup. Current source, manifests and handoff supersede their old status statements.

[Cleanup inventory](documentation-cleanup.json) records removed files and retained source dependencies. Removed documents remain recoverable from Git at the recorded pre-cleanup revision; no application or database history was deleted.
