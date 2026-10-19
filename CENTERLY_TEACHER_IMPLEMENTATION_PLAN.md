# Centerly Teacher Mobile — Production Implementation Plan
**Document:** `IMPLEMENTATION_PLAN_TEACHER.md`  
**Version:** 1.0 (Centerly product decisions v6.1) — 2026-10-18  
**Ownership:** Flutter teacher mobile app, consuming secretary repo's canonical Supabase schema  
**Status:** Proposed; unchecked tasks have not been verified.

> **Codex START HERE:** Read all sections before touching source. Teacher app is primarily a read-only business monitor (not a secretary app with different colors). Supabase data/permissions are owned by the secretary repo; no second backend or schema fork. Do not implement v6.0's 30-minute attendance lock.

## Existing Flutter app / Figma decision
**REUSE the existing Flutter teacher application and existing Figma design as the default starting point, rather than creating a new blank app.** This recommendation is conditional on a quick technical audit, not a claim that the code has been inspected. Preserve branding, Arabic screens/components, navigation ideas and useful assets. Audit dependencies, build, routing, state management, architecture, outdated flows and code quality **before** refactoring. If the existing repo is mostly static/fragile prototype, keep its design/assets and build a clean feature-first architecture in a NEW branch or new Flutter project **only after producing an audit comparison**. Avoid a risky wholesale rewrite without evidence. The link supplied by owner is design reference (may require access):
https://www.figma.com/design/iAEfLCYGeeGRYkvwUyEA9H/Centrely-Tech?node-id=0-1&p=f&t=bxJaGJGwFtIcfaNs-0

**Screen mapping:** retain/refine login, daily teacher overview, groups, calendar/day-week-month sessions, session details, read-only attendance, student details (data/academic/attendance/payments), teacher notes, notification list and My Secretaries. Replace any signup CTA with Contact Us, remove direct manage-secretary CRUD, remove attendance countdown/lock states. Finance is read-only for teacher. Teacher can cancel session and request secretary removal only; secretary handles operational changes.

Flutter stack: stable Flutter/Dart pinned in docs; flutter_bloc/Cubit + go_router + supabase_flutter + freezed/json_serializable where useful + intl; use a modest feature-first data/domain/presentation architecture rather than ritualistic abstractions. Android first for low-cost pilot, iOS support if account/device available; publishing to Apple/Google stores is **not free**. For free pilot use consented Android APK distribution with clear update/install policy; don't claim Play/App Store publication without accounts.

## Shared system contract — authoritative in BOTH repositories

**Product:** Centerly, Arabic-first, Egyptian tutoring/teacher operations SaaS. Teacher = tenant/subscription owner, with one or more secretaries. Teacher uses Flutter Android/iOS; secretary uses React responsive web (desktop + mobile). Each interface talks to the **same Supabase project**. The v6.0 PRD is historical input, NOT an instruction to implement superseded decisions verbatim. This document defines **v6.1 implementation decisions** and must be mirrored in the other repository; any breaking contract change requires coordinated PRs and version bump.

### Scope & decisions, v6.1
- No public registration, no self-service tenant/secretary creation, no OTP flow, no in-app SaaS subscription payments. Internal owner CLI/secure script provisions users; login screen has *Contact Centerly* link. Never put admin credentials/service-role key in either client or public CI logs.
- **Critical v6.1 change: NO automatic 30-minute attendance lock, NO auto-convert `not_marked` to `absent`, NO time-based prevention of edits.** Secretary manually marks `present`/`absent`/`excused`; unmarked stays `not_marked` indefinitely until handled. Secretary can edit marks later with reason and audit trail. Optional manual **Finalize Attendance** operation per session to express completion; does not prohibit corrections, but corrections after finalization require an explicit reason and are logged. Teacher sees read-only attendance and finalized status. No countdown. No attendance jobs. This supersedes v6.0 sections 6, 7.2, 8.4, 11.5 and related UI/API details.
- Session schedule remains a **separate concern**: sessions can be generated from recurring group schedules; for MVP make generation idempotent with a documented job schedule or provision sessions on demand. Never conflate schedule generation with attendance automations. Server-authoritative Cairo timezone conversion; store instants in UTC timestamptz and a local calendar date where needed.
- Teacher: tenant-scoped reads across operational/financial/academic data; writes own student notes, can cancel sessions with reason, can request secretary removal (request only; owner completes manually). Secretary: manages students, grade levels, groups, enrollments, schedules, attendance, exams, assignments, invoices and collections, can cancel sessions. Both may view within own tenant. No cross-tenant data access, even with guessed UUIDs.
- MVP **includes exams, assignments and payments**, per original PRD. Later features, not blockers: QR scanner, offline mutations, guardian messaging, automated subscription billing, push notifications. Student's stable random QR value may be generated but scanning can be postponed.
- No native desktop client or NestJS service in MVP. Use React + TypeScript + Vite + TanStack Query + React Hook Form + Zod + Tailwind/shadcn/ui on web, Flutter + Dart + Cubit/BLoC on mobile; Supabase Auth/Postgres/RLS/SQL RPC functions, Edge Functions only for privileged orchestration where justified.

### Data model (tables in `public` unless specified)
- `teachers(id uuid pk references auth.users, name, phone, subscription_status active|inactive, secretary_seats, created_at)`; teacher UUID is tenant ID. NEVER store application password hashes in public teacher tables: Supabase Auth owns password handling.
- `secretaries(id uuid pk references auth.users, teacher_id uuid fk teachers, name, phone, status active|inactive, created_at)`; `id` is Auth UID. Exactly one teacher.
- `grade_levels(id, teacher_id, name, sort_order)`; `groups(id, teacher_id, grade_level_id, name, subject_name, capacity, archived_at)`; `group_schedules(id, teacher_id, group_id, weekday, local_start_time, local_end_time, effective_from, effective_to)`.
- `students(id, teacher_id, full_name, phone nullable, guardian_phone nullable, level_tag nullable, qr_code_value random unique, archived_at, created_at, updated_at)`; no shared global student across teachers.
- `group_enrollments(id, teacher_id, group_id, student_id, status active|inactive, joined_at, left_at)`; FK relationships/constraints guarantee all referenced objects share `teacher_id`; active uniqueness; archive instead of destructive deletion for financial/attendance history.
- `sessions(id, teacher_id, group_id, schedule_id nullable, local_date, starts_at timestamptz, ends_at timestamptz, status upcoming|ongoing|completed|cancelled, cancelled_by, cancel_reason, cancelled_at, attendance_finalized_at nullable, attendance_finalized_by nullable, created_at)`; unique deterministic schedule/date occurrence key, no duplicate generation; status timing may be derived instead of cron-mutated where practical.
- `attendance(id, teacher_id, session_id, student_id, status not_marked|present|absent|excused, marked_by nullable, marked_at nullable, updated_at, UNIQUE(session_id,student_id))`. **No `attendance_lock_at`, `is_locked`, `is_attendance_locked`, `is_locked` storage or timed worker**. Store explicit `attendance_change_log(id, teacher_id, attendance_id, actor_id, previous_status, next_status, reason nullable, changed_at)` append-only. Maintain entries for enrolled students even if no mark exists; never infer absent from null.
- `exams(id, teacher_id, student_id, group_id nullable, title, held_on, score_percent numeric(5,2) 0..100, entered_by, updated_at)` and `assignments(id, teacher_id, student_id, group_id nullable, title, due_on, status pending|submitted|late, entered_by, updated_at)`.
- Finance: `invoices(id, teacher_id, student_id, group_id nullable, invoice_number tenant-scoped, amount_egp numeric(12,2), due_on, status draft|due|partially_paid|paid|void, created_by, created_at, void_reason nullable)`; `payments(id, teacher_id, invoice_id, amount_egp numeric(12,2)>0, collected_by secretary, collected_at server time, method cash|transfer|other, idempotency_key, receipt_number, reversal_of nullable, reason nullable, created_at)`. **Append-only money ledger**: never overwrite paid amounts or silently delete payments. Void/reversal action via secure RPC; amounts and status derive from ledger in a transaction. Provide daily collection-per-secretary reconciliation and audit trail.
- `teacher_notes(id, teacher_id, student_id, content, updated_at, UNIQUE(teacher_id,student_id))`; `notifications(id, teacher_id, recipient_id, type, payload jsonb, read_at, created_at)`; `secretary_removal_requests(id, teacher_id, secretary_id, status pending|handled, requested_at, handled_at)`; `audit_events(id, teacher_id, actor_id, entity_type, entity_id, action, metadata jsonb, happened_at)` append-only.
- Use foreign keys, check constraints, composite tenant-safe FKs where appropriate, meaningful indexes including `(teacher_id,created_at)` and `(teacher_id,student_id)`, and server-side pagination. Avoid exposing guardian phones in logs/error telemetry.

### Auth/RLS/transactional operations
- Supabase Auth email+password. Roles/tenant mappings are server-controlled from tables keyed to `auth.uid()`; never trust a client-provided `teacher_id`, `role`, `collected_by`, `amount_paid`, `is_admin` or arbitrary JWT user_metadata. JWT expiry/refresh handled by SDK, **status/inactive checked by DB on each sensitive RPC/query**. Subscription inactive denies all tenant data except necessary account/help messaging; disabling user must invalidate practical access via live DB policy checks.
- All tenant tables **ENABLE and FORCE RLS** where compatible; default deny; define tenant read policies and precise per-role write policies using stable SECURITY DEFINER helper (`current_tenant_id`, `current_role`) hardened `SET search_path`, explicit grants and SQL tests. SECURITY DEFINER functions validate actor, tenant, status and write fields; revoke public execution; grant only `authenticated` when needed. No direct client write path bypass for payments, attendance correction, session cancellation, secretary-removal requests.
- Mutating RPC contracts must be **idempotent** for payment collection and session generation. DB transaction locks invoice row and computes updated paid status atomically. Session cancellation race: one wins, second receives stable conflict code. Finalization: only secretary; post-finalization correction requires explanation and emits audit entry. Teacher never mutates a student's attendance.
- Recommended stable RPC/view interface in migrations: `get_current_profile()`, `get_teacher_dashboard(p_date)`, `list_students(p_search,p_group_id,p_cursor,p_limit)`, `get_student_profile(p_id)`, `list_sessions(p_from,p_to,p_group_id)`, `set_attendance(p_session_id,p_student_id,p_status,p_reason)`, `finalize_attendance(p_session_id)`, `cancel_session(p_session_id,p_reason)`, `create_invoice(...)`, `record_payment(p_invoice_id,p_amount,p_method,p_idempotency_key)`, `reverse_payment(p_payment_id,p_reason)`, `request_secretary_removal(p_secretary_id)`, `get_daily_collections(p_date,p_secretary_id)`; exact migration signatures in version-controlled `supabase/contracts.md` are canonical and generated typed clients should match.
- Error codes: `AUTH_REQUIRED`, `ACCOUNT_INACTIVE`, `SUBSCRIPTION_INACTIVE`, `FORBIDDEN_ROLE`, `TENANT_SCOPE`, `VALIDATION_ERROR`, `NOT_FOUND`, `CONFLICT`, `ALREADY_CANCELLED`, `ATTENDANCE_CORRECTION_REASON_REQUIRED`, `PAYMENT_ALREADY_RECORDED`, `RATE_LIMITED`, `SERVICE_UNAVAILABLE`. Translate to clear Arabic UI; never expose raw SQL stack traces.

### Baseline deliverables shared across repos
- One **canonical schema owner**: secretary web repo's `supabase/migrations`, `supabase/seed.sql`, `supabase/tests/`, `supabase/contracts.md`. Teacher Flutter repo is a **consumer**, not a second migrations owner; link to schema-owner repository/commit. Migration modifications require updating generated Dart/TypeScript models and compatibility notes in BOTH projects.
- Environment tiers: local Supabase where tooling permits; staging separate from production if feasible; `.env.example` only with public URL and anon/publishable key. No service role key in mobile/web. `.env*`, credentials, real student data, exports excluded from source control.
- Backups: Free plan must not be relied on as the sole durable record. Define encrypted, restricted, tested offsite backups with restoration drill, retention, and explicit owner responsibility **before storing real clients' finance and student data**; budget paid managed backup if production reliability requires it. Include user-requested data export and deletion policy consistent with legal/privacy obligations.
- Safety: Arabic RTL/accessibility, Egypt phone input and EGP currency, server-side search (not load all students), optimistic UI only where safe, no fake financial successes, auth loading/expired states, pagination, slow-network handling, basic rate limiting (privileged functions), Sentry/other telemetry opt-in without PII, structured monitoring of errors, cron, DB capacity.
- Production means no hidden mock data, real RLS tests and tenant isolation, transactional financial integrity, deterministic seeds/test accounts, repeatable deploy, documented recovery. **Free tiers are for validation; do not promise zero cost at growing production scale.**

### Codex execution protocol (follow in both repos)
1. At each session read THIS file, repository README, `docs/PROGRESS.md`, `supabase/contracts.md` (from schema owner), `docs/DECISIONS.md`, latest git status and tests. Do not start a random phase.
2. Select the first uncompleted task whose dependencies are done, complete at most one coherent task slice, write/adjust tests and docs, then run relevant checks. NEVER mark a checkbox complete if build/tests fail or acceptance criteria are not verified; explain blocked items.
3. After each slice update `docs/PROGRESS.md` with `Task ID | DONE/IN_PROGRESS/BLOCKED | commit SHA | files changed | commands/results | next task | blockers`. Log architectural deviations in `docs/DECISIONS.md` with why, alternatives, migration and cross-repo impact. Commit with meaningful user-configured author identity; never fabricate test results.
4. When blocked on secret/service access, implement only mockable interface, note the missing input and stop at safe boundary; NEVER invent credentials, live URLs, business data, app package names, support WhatsApp, financial figures, or actual deployment completion.
5. Work from tests and acceptance criteria. Re-read the task before implementation. Ask owner only for genuinely blocking external values (keys, account access, deployment permission); otherwise choose simple documented defaults. Avoid uncontrolled scope expansion.

### Shared release gates (must be evidenced, not presumed)
- Two teachers, each with own secretary, seeded concurrently; attacks via direct REST/RPC and guessed UUIDs from one tenant return no data/403. Secretary cannot update teacher notes or other teacher's records; teacher cannot create/edit invoices, attendance, exams, assignments.
- Financial duplicate submission/retry makes exactly one collection; concurrent submissions cannot overpay without explicit policy; reversal preserves original ledger; reports reconcile to ledger per day/secretary.
- Manual attendance works before/after any session start, remains `not_marked` until secretary changes it, never automatically becomes absent. Finalization is optional manual act; correction with reason logged and visible in audit; cancelled-session policy documented and tested.
- Timezone Cairo, DST, cross-midnight and clock skew tests; session uniqueness and preservation of history after rescheduling.
- Logs scrub phones, emails, tokens, financial secrets; restore drill passes; export works; staging-to-production checklist complete; mobile/web load acceptable on low-end Android and ordinary office PCs.

## Proposed repository layout
```
centerly-teacher/
  lib/app/{app.dart,router.dart,bootstrap.dart,theme/}
  lib/core/{auth,errors,network,format,widgets,config/}
  lib/features/{auth,dashboard,groups,sessions,attendance,students,academics,finances,secretaries,notifications}/
  lib/shared/{models,repositories/}
  test/{unit,widget/}
  integration_test/
  docs/{PROGRESS.md,DECISIONS.md,SCREEN_MAP.md,RELEASE.md,BACKEND_COMPAT.md}
  IMPLEMENTATION_PLAN_TEACHER.md
```
Use a single source of truth for user roles from database-backed `get_current_profile`. Keep app client storage minimal, no persistent sensitive student export unless explicitly requested. No mobile secret/service-role key. Teacher can view full student profile within own tenant only.

## Ordered implementation tasks — resumable with acceptance criteria
### Phase T0 — inspect and preserve teacher UI
- [ ] **T-001 [deps: none] Existing project technical audit.** Read pubspec, versions, actual screens, architecture, navigation and Figma screen inventory; run `flutter doctor`, `flutter pub get`, `flutter analyze`, `flutter test`, representative Android build. Do not pretend to have audited an inaccessible repo. **Accept:** `docs/SCREEN_MAP.md` maps Figma/existing routes to target teacher flows with keep/refactor/remove; documented blockers and reuse recommendation.
- [ ] **T-002 [deps: T-001] Choose repair vs rebuild based on evidence.** Prefer incremental cleanup when code builds and component structure reusable; if major defects, create clean architecture in isolated branch with component migration plan. **Accept:** ADR explains decision, preserves exact approved visuals and screenshots; no accidental loss of working UI.
- [ ] **T-003 [deps: T-002] Baseline tooling and CI.** Dart format, analyzer, tests, build variants, `.env.example`, codegen, GitHub CI, reproducible setup, docs progress. **Accept:** check commands green on clean checkout and no credentials stored.

### Phase T1 — shared backend integration
- [ ] **T-010 [deps: T-003; external S-012,S-014] Backend compatibility pin.** Link canonical secretary repo schema release/migration SHA, transcribe RPC signatures and generated models, write `docs/BACKEND_COMPAT.md`. **Accept:** schema version and drift check documented; no teacher-side DB migrations.
- [ ] **T-011 [deps: T-010] Auth/session handling.** Supabase password login, logout, secure session persistence, refresh, disabled teacher and inactive subscription behavior, Contact Us with configured channel. **Accept:** invalid login, expired token, no network, account deactivation, role secretary signing into teacher app all handled without data leakage.
- [ ] **T-012 [deps: T-011] App shell & design system.** Arabic RTL typography, theme, accessible buttons, error/loading/empty layouts, navigation tabs, deep-link policy, device text scaling and iOS/Android safe areas. **Accept:** screenshots visually compared to Figma at common device sizes; 200% text scale and talkback labels tested.
- [ ] **T-013 [deps: T-011] Typed Supabase repository layer.** Read RPCs via repositories, pagination, caching and safe error mapping, cancellation tokens where available; user tenant never accepted from UI. **Accept:** unit tests for error mapping, unauthorized, retry, stale sessions; no direct unrestricted reads bypass contracts.

### Phase T2 — live dashboard & schedule
- [ ] **T-020 [deps: T-013; external S-014] Teacher dashboard.** Date/current sessions, hours, group/student counts, attendance status and real paid/outstanding financial aggregates with filters; refresh/pull-to-refresh. **Accept:** seeded totals equal backend fixtures and teacher A never sees teacher B.
- [ ] **T-021 [deps: T-013; external S-030] Groups browse.** Search/filter groups, grade, students count, schedule and roster previews. **Accept:** teacher cannot see edit actions; 0/100/10k dataset behavior sensible.
- [ ] **T-022 [deps: T-013; external S-041] Day/week/month sessions.** Cairo timezone with day boundary tests, future/past/cancelled and displayed times, no duplicate schedule entries. **Accept:** dates/timezones match web and database; useful empty state.
- [ ] **T-023 [deps: T-022; external S-042,S-043] Session detail and attendance.** Read-only list of present/absent/excused/**not_marked**; clear finalized status, no countdown, no auto-absent claims; show latest sync/update. **Accept:** unmarked displays distinctly forever until secretary marks, teacher never edits attendance; after-finalization correction visible after refresh.
- [ ] **T-024 [deps: T-022; external S-044] Cancel session.** Teacher provides reason, guarded confirmation, mutation via secure RPC and conflict handling; show who cancelled and when, notify secretary. **Accept:** teacher allowed, secretary access to same group unaffected except cancelled session, simultaneous cancellation returns stable conflict.

### Phase T3 — student intelligence / academics / money
- [ ] **T-030 [deps: T-013; external S-031,S-032] Student directory/profile.** Efficient paginated search, personal/contact data, group memberships, stable QR display if implemented; don't reveal students from other tenants. **Accept:** guardian phone access scoped, read-only fields, narrow screens/text handling.
- [ ] **T-031 [deps: T-030; external S-060,S-061] Academics tab.** Exams and assignments summary, score distribution, missing values shown as missing (not zero), read-only. **Accept:** DB fixtures and Arabic edge cases tested.
- [ ] **T-032 [deps: T-030; external S-042,S-043] Attendance tab.** Trends based on manually recorded statuses; denominator excludes `not_marked` or explicitly shows pending; group and date filters. **Accept:** no silent pending→absent conversion in UI math; documented denominator and tests.
- [ ] **T-033 [deps: T-030; external S-050..S-053] Finance tab.** Read-only invoice status, due balance, payment/receipt history, who collected, date ranges and daily totals; audit corrections visible. **Accept:** teacher balances reconcile precisely with backend ledger; no write controls.
- [ ] **T-034 [deps: T-030] Teacher notes.** Single teacher-only editable note per student via secured mutation, version/updated_at conflict warning, secretary reads but can't write. **Accept:** teacher B cannot read/write; racing updates never silently overwrite.

### Phase T4 — secretaries, notifications, polish
- [ ] **T-040 [deps: T-013; external S-013] My Secretaries.** View own secretaries name/email/status and pending removal requests, submit new request with confirmation; **do not deactivate user**. **Accept:** removal duplicates handled; no tenant cross-read; statuses update following operator action.
- [ ] **T-041 [deps: T-013; external S-062] Notifications.** Display cancellation/payment/admin events only when backed by real backend; read marking and basic refresh. **Accept:** no demo notifications in production; scoped recipient.
- [ ] **T-042 [deps: T-012] Design polish and usability audit.** Reconcile screen-by-screen Figma fidelity with updated business constraints; support dark mode only if design supports it; Arabic numerals/EGP and readable dense tables. **Accept:** screenshots/QA list at small & large Android, common iOS size if feasible; contrast and accessible target sizes.

### Phase T5 — production-grade release
- [ ] **T-050 [deps: T-040,T-041,T-034; external S-070] Automated tests.** Cubit/repo/model unit tests, widget tests, Flutter integration flow against staging, offline/error/no-data states, RLS integration with two tenants. **Accept:** CI executes and reports, no skipped critical scenarios.
- [ ] **T-051 [deps: T-050] Security and privacy.** No service-role keys, redact Sentry, prevent screenshots of secrets where appropriate, token logout/account switch, sensitive local cache policy, dependencies scanned. **Accept:** on-device inspection and test credentials removed.
- [ ] **T-052 [deps: T-050] Stability/performance.** Startup and frame benchmarks on budget Android device, pagination, safe incremental refresh, reconnect, auth renewal, duplicate taps and timeout handling. **Accept:** metrics in `docs/RELEASE.md`, tested slow networks.
- [ ] **T-053 [deps: T-051,T-052; external S-074] Pilot signing/distribution.** Configure app ID, signing keystore kept secret, versioning, privacy links, sample account onboarding, signed Android APK pilot and rollback process. **Accept:** install/uninstall/update on two devices; end-to-end with secretary web and live staging; no claim of store publication.
- [ ] **T-054 [deps: T-053] Cross-app acceptance.** Secretary creates student/group, marks late attendance, corrects after finalization with reason, collects payment; teacher sees updates and ledger totals; teacher cancellation visible to secretary; removal request reaches admin CLI. **Accept:** recorded matrix incl two isolated tenants, errors and recovery; owner sign-off.

## Deferred (not blockers for first paid pilot)
- [ ] **T-LATER-01** Optional QR scanner / printable QR cards beyond static display.
- [ ] **T-LATER-02** Push notifications and scheduled background sync after privacy/cost evaluation.
- [ ] **T-LATER-03** Public app store launches, guardian portal, subscription checkout.

## Verification commands
```
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
# Later, with configured signing: flutter build apk --release
```
Log outputs; don't assert iOS builds without a Mac/Xcode runner. For backend auth/tenant security, rely on real Supabase test environment—not only mocked repository unit tests.

## Initial Codex prompt
> Read `IMPLEMENTATION_PLAN_TEACHER.md`, inspect my existing Flutter code and `docs/PROGRESS.md`. Begin with T-001 technical/Figma-to-screen inventory and proof of whether to preserve/refactor the existing app. Don't create a new project before audit. Then do only the first unblocked task, with tests, commit and progress log. Attendance is manual, with no 30-minute auto-lock/auto-absence. Secretary web repository owns Supabase migrations; never fork schema.
