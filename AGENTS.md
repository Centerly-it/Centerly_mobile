# Centerly agent entry instructions

Before editing, read `CODEX_HANDOFF.md` completely, then `IMPLEMENTATION_PROGRESS.md` and `docs/README.md`. Read the sibling handoff for shared-flow changes. Preserve Teacher `agent_rules.md` conventions.

- Latest owner instructions outrank old documents. Current source/manifests outrank historical reports. Do not execute historical plans or admin/fixture scripts as onboarding.
- Preserve owner changes and local secrets. Never print or commit credentials, signing keys, dumps or private account files.
- Teacher is sole migration owner; dev/prod are separate projects. Never replay/edit deployed migrations or reset data. Authorized new migrations need exact baseline/hash/catalog checks and candidate-only dry run.
- Implement authorized work, validate, then commit/push own changes to main. No force-push/unrelated staging. Deploy actual website/runtime/public-policy changes to existing Pages after checks; docs-only changes need no unchanged-site redeploy.
- APK/device changes, real accounts/Auth, hosted fixture writes, paid resources and higher mandatory update thresholds need relevant owner direction. Restore production signing keys, never regenerate them.
- Flutter pub/test/build run sequentially; web check/build/deploy sequentially; native PostgreSQL modules serially. Generated files/dist/test port are shared.
- Use concise Egyptian Arabic, useful progress, localized AR/EN UI and existing Cairo/Centerly styling. Separate simulation/browser/hosted proof from real-device acceptance.

Keep handoff current when behavior, configuration, deployments or decisions change. Keep dated evidence separate from startup/current-state documents.
