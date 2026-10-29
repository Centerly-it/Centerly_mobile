# Current checkpoint — 2026-10-28

Owner provisioning update — 2026-10-29: explicit owner request authorized one production teacher account for Release/update testing. Auth account and active teacher/subscription profile were created; actual password Auth and tenant-scoped get_current_profile passed; verification session signed out. No secretary or business fixtures were created. Private identity registry remains ignored in Teacher .env.production-owner-account.json; do not duplicate credentials into docs. Physical-device/update acceptance remains pending.

Read [CODEX_HANDOFF.md](CODEX_HANDOFF.md) for both projects. Old verbose ledgers remain in Git; historical acceptance/reset commands are not new authorization.

- Main in both repositories; Teacher owns 40 deployed immutable migrations through 202610280001. Separate dev/prod refs are in handoff/manifests.
- Secretary website targets prod; synthetic testing is local dev at 127.0.0.1:5173.
- Monthly/per-session billing migration 40 deployed dev/prod; hosted per-session write acceptance and real onboarding remain owner actions.
- Immediate secretary stop/reactivate, manual subscription suspension/sign-out, archived history, cold-start Home/background retention, support, approved icon/white splash, safe diagnostics and native flavors implemented.
- Signed APK 1.0.0+1 / com.centerly.teacher published; prod policy latest=1/minimum=1, dev disabled. Signer pinned; private backup ignored. Never regenerate on another computer.
- Updater checkpoint: 354 Flutter passed / 2 conditional skipped; analyzer clean; 8 JVM tests; APK signer/credential scan and anonymous public hash passed; website 82 baseline + 3 policy tests; live policy/cache/build/six assets matched. Dated evidence, not device/hosted mutation acceptance.
- Owner still needs physical upgrade acceptance, secure off-computer signing backup, authorized onboarding and provider recovery/monitoring/notice acceptance. See docs/OPERATIONS_AND_RECOVERY.md.
- This cleanup changes docs only, consolidates current knowledge and retains source-dependent evidence. Recovery/validation map: docs/documentation-cleanup.json. No app/backend/account/fixture/device changes.
- Cleanup verification: 40 migration hashes unchanged; 90 local PostgreSQL authorization/business assertions, 29 finance movement assertions and 3 reviewed SQL hashes passed. Retained dependency paths, entry links and private credential-value scan passed. Secretary formatting/lint, all 85 client tests, TypeScript and production build passed. Documentation only: no deployment or physical-device test was performed.
