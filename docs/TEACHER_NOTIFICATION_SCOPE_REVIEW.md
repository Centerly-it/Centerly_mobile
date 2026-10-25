# NOTIFY36 — Teacher operational inbox

Status: exact candidate deployed after explicit owner approval on 25 October 2026; postflight migration 36 verified. See NOTIFY36_DEPLOYMENT.json. Previous deployed baseline was migration 35 at f145365bd016d1b37d56015472d1a464e8dfa47a.

Candidate: supabase/proposals/202610250002_teacher_notification_scope.sql
SHA256: 823946e86d5326c23b47adf4b13a4cbd1513a95793abe4c1199bbd6a1b04f17c

Teacher recipients receive only student_added, student_withdrawn, student_removed and payment_collected (the owner's three product categories). Student-added means identity creation, not every enrollment/edit. Withdrawal is a transition out of a group; removal is the existing archive-based delete workflow. No backfill. Plain edits, timetable/attendance actions, admin events, cancellations and payment reversals do not create Teacher inbox notices. Secretary recipients keep their current behavior, including cancellation reasons resolved from sessions.

A teacher-recipient insert trigger suppresses other new event types; lifecycle triggers create student notices transactionally. The existing list_teacher_notifications signature is preserved but it now filters both pages and total/unread counts to this same allowlist. Old notification rows are retained unchanged. Payload exposes only allowlisted IDs; student_name is a tenant-checked top-level join (including archived history), never client authorization metadata. Existing payment producer/reversal ledger, audit history, RLS and mark-read authorization remain unchanged.

Teacher Flutter adds 12px below read/unread status, explicit student event labels and optional authorized student names, with generated Arabic/English localization. The full inbox restriction is now deployed and verified through hosted read-only authorization/count checks. Older app clients ignore the extra top-level name safely and continue using the same page contract, but need the updated app for the new event labels.

Checks: node supabase/tests/teacher_notification_scope.mjs PASS, 30 assertions using disposable native PostgreSQL and all 35 baseline migrations plus the candidate. Covers creation versus plain edits/enrollment, withdrawal and rejected repeat, archive and rejected repeat, receipt retry deduplication, preserved reversal history, suppression of unrelated new Teacher events, retained old rows, exact filtered unread/pagination/mark-read, tenant isolation, secretary denial of Teacher reads and preserved Secretary cancellation notification. No hosted fixtures/Auth/business changes were made.

Owner approved and deployed ONLY the exact file above on centerly-dev (yfeubomyglmhuwizaqoj). Before deployment verify all 35 hosted migration bodies/catalog and require a dry run naming only 202610250002. Stop on drift. Promote the proposal unchanged; postflight migration 36, signatures/grants, unchanged old data/Teacher and Secretary access, and advance manifests/pins only after verification. This approval is separate from hosted fixture mutations, Auth changes, production or publishing.
