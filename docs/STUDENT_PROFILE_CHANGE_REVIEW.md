# Student profile read — approved and deployed

Owner separately approved exactly this migration. Deployed 2026-10-19 after all
eleven baseline hashes/remote SQL bodies matched and dry run listed only this
version, with vault skipped and no seeds/roles. All twelve postflight SQL bodies
matched; hash pinned. No fixture/Auth changes or other deployment occurred.
[Read-only hosted results](STUDENT_PROFILE_VERIFICATION.json): contact/membership
matching, tenant/missing/secretary/anonymous denial and hardened grants/search_path
passed using existing synthetic accounts. Positive multi-page/archive/inactive
cases remain local evidence. Password SDK/Flutter acceptance remains pending.
Proposal: `supabase/proposals/202610190003_student_profile.sql`.
SHA256: `760740f7d4ea2c59cbaa645619fcf8f22375d73eadd115c12277c4ff3ce291e5`.

Adds only teacher-only `get_teacher_student_profile(p_id uuid,p_cursor uuid=null,
p_limit integer=30) -> jsonb`: current student identity/contact/level fields,
created/updated timestamps; UUID cursor membership history (1..100), joined/left
and active/inactive state, group/subject/grade and explicit group archive timestamp.
Includes historical memberships without mislabelling them active. Accurate limit+1
next_cursor, membership_count and synced_at. Null contacts remain missing. Archived
or other-tenant students return NOT_FOUND. QR, academics, attendance, finance and
notes are outside this proposed response and are not marked complete.

Uses existing active teacher/subscription helper, explicit tenant constraints,
empty search_path, PUBLIC/anonymous revoke and authenticated grant. No tables,
policies, writes, account/fixture/Auth changes or edits to the eleven deployed files.

`node supabase/tests/student_profile_proposal.mjs`: 21 assertions PASS on disposable
native PostgreSQL: contacts/missing values, teacher/secretary/tenant boundaries,
limits, pagination end, historical membership/archive metadata, archived-student
and inactive teacher denial, grants/search_path. No hosted access in this test.

Original activation procedure (historical): verify all eleven pinned hashes/remote SQL bodies, copy
exact proposal bytes, dry-run only the approved version with vault/seeds/roles
skipped, deploy and verify read-only existing-fixture behavior before pinning and
wiring profile UI. Do not mutate hosted fixtures or reset passwords. Password-based
hosted SDK/UI acceptance still requires restored original development credentials.
