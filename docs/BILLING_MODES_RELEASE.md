# Monthly/per-session billing — release review

2026-10-28. Implemented locally; **not deployed or hosted accepted**. Existing monthly groups are unchanged. New per-session creation is gated off against migration 39.

## Canonical package

Teacher is the migration owner: `Centerly-it/Centerly_mobile`. Candidate: `supabase/proposals/202610280001_group_billing_modes.sql`.

SHA256: `60b0f251ef16a91b1da737cac8fc5ffd37b13c5e74d3a14533c2baa421e45702`.

The proposal remains outside deployed migrations. Both pinned manifests remain at 39 through `202610270002_secretary_reactivation.sql`. On 28 October both environments passed exact migration-body/token, catalog, signatures, grants, policies and trigger comparison against disposable canonical PostgreSQL. CLI dry runs contained only `202610280001_group_billing_modes.sql`. No hosted business/Auth/settings writes occurred.

| Environment | Reference | Current contract | Candidate deployed |
| --- | --- | --- | --- |
| centerly-dev | yfeubomyglmhuwizaqoj | 39 | No |
| centerly-prod | ohhwccwwwxfmwpfypfyf | 39 | No |

## Behavior and coverage

| Journey | Implementation and local evidence | Hosted/device acceptance |
| --- | --- | --- |
| New group → enrollment → session | Choice monthly/per-session only on new groups; scheduled and manual creation snapshot exact price; enrollment adds only eligible sessions; one-time initial materials | Pending approved migration/fixtures |
| Existing monthly group | Legacy implementation retained, 120.00 monthly/materials control and baseline compatibility suite | Baseline only verified read-only |
| Attendance → financial review | Direct attendance; financial preview/version check; present retained, other statuses exempt; no attendance finalization | Pending |
| Paid then exempt | Unpaid part removed; actual cash retained and settlement flagged; explicit manual payment edit; immutable historical ledger | Pending |
| Retry/concurrency | Stable request IDs across uncertain response/reload; stale snapshot rejected; same tenant financial/attendance mutations serialized; duplicate generation safe | Local only |
| Cancellation/archive | Historical attendance/payments retained; financial review respects cancellation and membership/archive timelines; archived settlement allowed through audited API | Local only |
| Teacher reads | Group mode/tariff; invoice settlement note; server session summary; permissions unchanged | Flutter tests/build; actual cross-app device acceptance pending |
| Money/reporting | Shared invoices/payments, exact decimals; existing Cairo calendar-month boundaries preserved, no parallel client totals | Production data acceptance pending |

Backend evidence: 54 new real PostgreSQL assertions; 90 original authorization/business assertions with candidate applied. Web: 82 unit/component tests, 34 local browser cases (desktop/mobile RTL), lint/format/TypeScript/build. Teacher: clean analyzer, 325 full tests passed/2 skipped, dev/prod debug APK builds. Browser SQL/Auth adapter is synthetic; these results do **not** establish hosted Supabase end-to-end readiness.

## Reproduce

Use Node/npm and a matching canonical Teacher checkout. `CENTERLY_CANONICAL_REPO` can point to its root; otherwise the sibling Teacher checkout is used. Run `npm ci` in Secretary and `npm ci --prefix supabase/tests` in Teacher. The canonical source resolver fails closed on migration drift.

From Secretary:

```sh
node scripts/build-billing-review.mjs
node ../Centerly_mobile/supabase/tests/billing_modes.mjs
node scripts/test-billing-compatibility.mjs
npm run check
CENTERLY_BILLING_FIXTURE=true npm run test:browser
npm run build:pages
```

The builder derives unchanged legacy bodies from a disposable native PostgreSQL database through migration 39. Never run local test scripts against hosted data. Preflight requires an already authorized Supabase CLI path in `CENTERLY_SUPABASE_CLI`; run `node scripts/billing-hosted-preflight.mjs PROJECT_REF`. It performs read-only capture, local link setup and dry run, not deployment.

## Activation gate

1. Obtain explicit approval for this exact candidate hash and target environment. Recheck full baseline/catalog/hash and require a dry run with only this version; stop on drift.
2. Deploy dev first, then verify migration 40, all function signatures/grants/triggers, role/tenant denial and Teacher compatibility. Do not replay baseline migrations. Update canonical manifest and matching Secretary dev pin only after verification. Production needs its own specified approval/verification and production manifest pin.
3. Production `build-pages.mjs` derives `VITE_SESSION_BILLING` from the verified production manifest. Migration 39 builds keep it false. After production verification, build/check and publish with `npm run deploy:pages`. No fixture modes are shipped. Teacher uses `CENTERLY_SESSION_BILLING=true` only for a verified target.
4. Read-only public verification then separate authorized hosted fixture/device acceptance. No account creation, password/reset/Auth settings or real student records are included.

Emergency pause: `VITE_SESSION_BILLING_CREATE=false` blocks new per-session groups while keeping review/settlement/history accessible. Never remove columns or historical payment rows as rollback. Roll forward a reviewed additive fix; retain existing session prices.

## Proposed hosted synthetic acceptance scope — separate approval

Dev only, within an existing synthetic teacher tenant and its authorized secretary (never prod/real tenants): create one uniquely prefixed monthly control group and one per-session group, three synthetic students, enrollments, recurring schedules and a bounded two-day set of generated sessions. Set synthetic attendance (present/absent/not_marked), edit one status after review, collect one partial synthetic cash payment, then manually correct it to zero after exemption. Revise the synthetic schedule, archive/restore the created student/group, check old invoices remain collectable, capacity refusal with a fourth synthetic student, cancellation and retained attendance. Read matching Teacher APIs and foreign-tenant/Teacher denied writes.

Only the created UUIDs may be mutated; record IDs before each step. No existing group membership, tariff, student or payment changes. Cleanup archives created entities and cancels future synthetic sessions; issued invoices/payment/audit rows remain as clearly prefixed test history. No SQL deletes, Auth changes or misleading claim that cash was actually refunded. If owner requires deletion, use a separately approved disposable environment instead. This scope has not been executed or authorized.

No unresolved product policy remains for V1. Existing group mode conversion, automatic wallet/refunds, and automatic financial attendance review are intentionally excluded.
