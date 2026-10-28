# Centerly — Teacher Mobile

Start with [CODEX_HANDOFF.md](CODEX_HANDOFF.md) for current knowledge of both projects, product decisions, secure setup, environments, tests, deployments, APK updates and owner acceptance.

- Teacher/backend: https://github.com/Centerly-it/Centerly_mobile
- Secretary: https://github.com/atamer7112002/Centerly_secretary
- Website: https://centerly-secretary.pages.dev — prod; synthetic accounts use local dev.
- Signed APKs: https://github.com/Centerly-it/Centerly-releases/releases
- Backend: 40 immutable migrations through `202610280001_group_billing_modes.sql`; physically separate dev/prod.

See [documentation map](docs/README.md) and [current checkpoint](IMPLEMENTATION_PROGRESS.md). Old evidence is not a setup checklist. Credentials, environments and signing secrets are intentionally absent from Git. A new account does not inherit chat history or secret files.
