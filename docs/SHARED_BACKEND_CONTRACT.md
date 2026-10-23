CURRENT 23 October: owner-approved R2 deployed and verified on centerly-dev as migration 29. Connected creation/billing enabled; grade-level UI removed. All business data remains empty. Earlier pending/28-version statements below are historical. See docs/R2_ACTIVATION_ACCEPTANCE.md.

Pending R2 creation contract (local review only): `secretary_create_group(uuid,text,text,numeric,numeric)` creates a group without client capacity/year inputs; `secretary_create_student(uuid,uuid,text,text,text,text)` atomically creates a student, required active same-tenant enrollment and its charge. Client-generated UUIDs make response-loss retries idempotent with exact payload checks. No automatic hosted seed. Existing hosted API/migration manifest remains at version 28 until the new R2 hash is approved and deployed.

Current update, 23 October: owner-requested synthetic development reset completed; all business tables empty and accounts retained. Earlier fixture/installed-APK statements below are historical. Group-pricing backend is local review only, not deployed; see [current acceptance](OWNER_RESET_AND_PRICING_ACCEPTANCE.md) and [one pricing review](GROUP_PRICING_REVIEW_AR.md). Hosted baseline remains 28.

# Current development contract — migration 28, 23 October 2026

Canonical source: sibling Teacher repository `Centerly_mobile/supabase/migrations`; identical normalized SHA manifest in Teacher `supabase/schema-manifest.json` and Secretary `docs/backend-baseline.json`, through `202610230001_controlled_pilot_history_balances.sql`. Owner-approved raw transaction SHA256: `6651349fd37f8d4682fa4bd42bfadda664b2eab910026ee9a0bde0c111c78cc2`. Normalized migration hash is recorded separately in the manifest; approved raw bytes remain unchanged.

Fresh preflight: 27 versions / 54 functions / 18 tables / 30 policies / 13 triggers. Dry run listed only 202610230001; transactional deployment succeeded. Fresh postflight: 28 exact migration bodies / 55 functions / 18 tables / 30 policies / 20 triggers, full local catalog/grants/RLS match, zero invalid enrollments. All 18 public business-table fingerprints remained unchanged. Existing authenticated synthetic SDK reads passed; no SEC27 mutation/cleanup was rerun.

Archived ownership: active owning Teacher can read profile, attendance, exams/assignments, note and student-scoped finance. Teacher profile adds nullable archived_at. Active list_students remains active-only; Teacher archived directory uses existing SELECT/RLS restricted to the current teacher ID. Archived operational student/note/academic/invoice/collection/attendance edits are blocked by triggers; active enrollment guards remain. Reasoned existing payment reversal stays available for correction, including archived students. Generation skips archived students while retaining existing attendance. No new account/Auth/grant policy or deletion behavior.

Invoice APIs: amount_egp and original_amount_egp are original face value; net_paid_egp / Secretary paid_egp and ledger_net_egp are signed original receipts minus reversals; outstanding_egp / Secretary balance_egp and payable_balance_egp are payable (zero for void). Decimal strings preserve exact cents. Dues excludes void, dashboard aggregates already exclude void, receipt movements remain signed events. Never infer payable from raw invoice amount. Teacher UI exposes archived history and read-only archived notes; physical owner acceptance remains separate.

Current goal: local synthetic owner testing of connected development apps. See OWNER_LOCAL_TESTING.md and OWNER28_SYNTHETIC_SCOPE.md. Production decisions are deferred and do not block this milestone. All checkpoint text below is historical where inconsistent.

# Shared pilot checkpoint — 22 October 2026

Current status and stable task IDs: [SHARED_COMPLETION_CHECKLIST.md](SHARED_COMPLETION_CHECKLIST.md). Real credentials are available; real Auth/Chrome and native Windows reads passed. All 27 migration hashes/history/catalog verified. See [PILOT_EVIDENCE.json](PILOT_EVIDENCE.json), [CROSS_APP_ACCEPTANCE.md](CROSS_APP_ACCEPTANCE.md) and [PILOT_OPERATIONS.md](PILOT_OPERATIONS.md). No hosted business/schema/config changes or publication. The following checkpoint text is historical where inconsistent.

# Current Secretary consumer pin — migration 27 deployed

The canonical Teacher worktree `.canonical-review` and `docs/backend-baseline.json` pin the identical 27-migration contract through 202610220002. Fresh full preflight/postflight verified the approved migration hash and exact catalog, grants, policies and guards. Original Teacher root remains untouched at its historical 26-version checkout; for local tests use `.canonical-review` or set `CENTERLY_CANONICAL_REPO` to the canonical commit checkout. The resolver verifies every pinned migration before use; it will not silently use an incomplete/stale source. Deployment evidence: SECRETARY_DEPLOYMENT_2026-10-22.md/json. Historical pre-deployment text below is superseded for baseline/gate status only.

# Shared backend consumer contract

Canonical: `/Users/mohamedsalem/Desktop/Centerly_mobile/supabase/migrations`. Teacher GitHub: https://github.com/Centerly-it/Centerly_mobile. Checkout be94122be24a43627dac944be52f6e7aba859872. Pinned manifest `backend-baseline.json`: 26 immutable migrations, last 202610220001. Fresh local and hosted verification results belong in progress, not inferred from historical counts.

Identity: get_current_profile() returns id/teacher_id/role only for active account and teacher subscription. Reject role != secretary. RLS derives tenant from Auth UUID, never editable metadata. Direct authorized writes: students, grade_levels, groups, exams, assignments; supplied tenant comes only from validated profile, with server RLS mandatory. Enrollment uses reviewed server RPC for capacity/real exit time. No direct sensitive table writes/deletes.

Existing RPCs: add_schedule, generate_sessions (inclusive <=62 days, idempotent), set_attendance, finalize_attendance, cancel_session, create_invoice, record_payment, reverse_payment, mark_notification_read, get_daily_collections. Teacher report functions forbidden for secretary. See canonical SHARED_BACKEND_CONTRACT.md for exact historical baseline signatures.

Local extension review: secretary_browse(entity,filters,search,cursor,limit), secretary_dashboard(), secretary_enroll(group,student,enrollment?), secretary_set_attendance(session,student,status,expected_updated_at,reason), secretary_revise_schedule(id,from,weekday,start,end,to). Named API parameters carry p_ prefix. Browse uses fixed table/filter allowlists, tenant+recipient scoping, literal search, limit+1 UUID paging, count, server_date/synced_at. Invoice money/balance and payment money are decimal strings. Session status is derived on server. Dashboard cash uses receipt Cairo day, outstanding excludes void and subtracts reversals. Pending counts persisted not_marked records for noncancelled selected-day sessions, not inferred missing rows.

Errors are localized allowlisted categories. No SQL details shown. Payments use exact payload/key replay and server invoice locks; ambiguity requires key lookup. Reversals append and keep original attribution. No UPDATE/DELETE ledger/history.

Local verification: `npm run verify:backend` checks hashes against canonical and applies all exact migrations plus candidate to disposable PGlite. Canonical independent PostgreSQL suites remain separate. No hosted replay/reset/push.
