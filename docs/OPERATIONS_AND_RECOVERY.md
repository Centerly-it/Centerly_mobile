# Operations, recovery and remaining owner acceptance

Current 2026-10-28. Read [handoff](../CODEX_HANDOFF.md), current manifests and [APK runbook](ANDROID_UPDATES.md) first. This is a procedure, not authorization to execute destructive/hosted actions.

## Restore access on another Codex account/computer

Preserve the working checkout and ignored files if staying on the same OS account. Check git status/fetch and provider access. On a fresh clone, securely restore public-key client profiles, only necessary private operator credentials, and the SAME production signing key/properties from owner backup. Never paste credentials or regenerate the key. External connector connections may need owner reconnection; Git history does not contain secrets.

## Incidents and immutable history

Inspect environment, app/site build identity, current policy/manifests and sanitized diagnostics first. Do not reset production, rerun SEC27/old seed/reset scripts, delete ledger rows, change Auth/passwords or replay a possibly committed migration. Reconcile exact retained IDs/history/version. Apply reviewed additive fixes; preserve payments/reversals, attendance, audit and original totals. Disable a problematic feature or withdraw an APK requirement through the documented owner controls instead of dropping schema.

For update emergency use the runbook's explicit lower/disable flags and deploy website metadata after verification. A bad binary is replaced with a higher build, not overwritten/downgraded. Back up the existing signing material securely outside this computer; local ZIP creation alone is not offsite backup.

## Provider recovery drill — not yet accepted

On explicit owner approval, inventory source/config/migration hashes, DB/Auth/service settings, Storage inventory and recoverable backup timestamps. Use an isolated restore target, outbound mail disabled, then restore through provider-supported DB/Auth/Storage procedures. Compare full catalog/grants/RLS, row counts, exact financial totals and immutable histories. Test authorized teacher/secretary/foreign-tenant denial. Record measured loss/time-to-service and disposal/retention. Never redirect prod or contact customers as part of an unapproved drill. No successful real-provider restore or RPO/RTO guarantee is claimed.

## Monitoring

Existing Secretary `scripts/pilot-health.mjs` is a bounded anonymous web-shell health hook; it is not authenticated RPC/end-to-end health or proof of scheduled alert delivery. Teacher has sanitized prod Sentry hooks, disabled remotely without owner DSN. No raw payload/contact/auth data should enter monitoring. Owner must choose/configure recipients, schedules and external service access, then verify actual alert delivery. Do not silently provision paid services or send test messages.

## Real-data readiness versus local testing

Local connected dev with existing synthetic accounts is ready. The deployed schema, published website and signed APK are NOT a claim that real operator provisioning/device/recovery/privacy acceptance is complete.

| Remaining item                | Prepared                                                            | Exact owner action                                                                                      |
| ----------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Signed physical upgrade       | APK/policy/signature/digest/JVM/widget tests                        | Confirm one-device upgrade preserves login/state before mandatory promotion                             |
| Signing custody               | Ignored key/properties and owner-protected local backup; public pin | Store a secure off-computer backup and restore it on other trusted builders                             |
| Real teachers/secretaries     | Separate prod backend, trusted profile/seat contract                | Explicitly authorize/provide real onboarding via secure credential delivery; test role/tenant isolation |
| Per-session hosted acceptance | Migration 40/tests/proposed bounded fixture scope                   | Approve exact dev-only writes if hosted mutation testing is wanted                                      |
| Recovery                      | Source/manifests/local simulation                                   | Approve isolated provider DB/Auth/Storage restore drill                                                 |
| Remote monitoring             | Sanitized hooks/health script                                       | Supply configured access/DSN/recipient and verify delivery                                              |
| Privacy/support launch        | Draft documents + explicit support contact                          | Review/approve customer-facing notice and support/recovery responsibilities                             |

Production inventory may change after handoff; use read-only verification before assuming empty. Keep real and synthetic data separated. No automatic account creation or data deletion is part of startup.
