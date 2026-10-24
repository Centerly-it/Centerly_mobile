## 2026-10-24 — Direct attendance, development migration 34

Owner-requested removal of attendance approval: Secretary has no finalize action, manual-mode notice, finalization metadata or correction-reason field. Status choices save immediately; unmarked students remain unmarked. Existing finalized sessions can be corrected without a reason. The retired finalize RPC no longer grants execute to authenticated clients; historical metadata and immutable change logs are preserved. Tenant, role, cancelled-session and optimistic-concurrency checks remain enforced.

Session badges and history grouping use starts_at/ends_at, with a one-second foreground clock and focus refresh. A session completes only at its end time; cards display both start and end. Hosted APIs already derive status from timestamps, independently of attendance.

Deployed only 202610240002_direct_attendance.sql after a verified 33-version history/catalog baseline and dry run naming only this migration. Postflight matched all 34 migration bodies, 73 functions, 18 tables, 30 policies and 25 triggers. All 18 table fingerprints and financial totals matched pre/post; no hosted fixture or account mutations.

Validation: 39 Secretary unit tests; lint/typecheck/configured web build; 2 isolated SQL-fixture browser attendance tests (desktop/mobile); 9 native SQL-role direct-attendance assertions; baseline 90 assertions; Secretary contract 59 checks; concurrency 11 and Secretary concurrency 34; actual authenticated hosted Chromium 5 read-only checks. These are automated checks, not owner or physical-device acceptance. Teacher APK unchanged.

