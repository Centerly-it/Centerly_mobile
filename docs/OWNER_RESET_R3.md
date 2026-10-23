# Fresh owner test reset R3 — 23 October 2026

The owner explicitly requested another clean development reset and removal of the educational-level field from student data in the Secretary website.

Verified all 29 hosted migration bodies against the manifest, exact existing synthetic Teacher/Secretary identities, active statuses and tenant ownership. A new private backup was saved before the locked-snapshot atomic reset. The earlier reset/fixture packages were not replayed.

Removed 16 test rows: one internal grade reference, two groups, ten students, one enrollment, one invoice and one audit event. All 16 business tables were verified empty inside the same transaction. Both Teacher profiles and both Secretary profiles remain identical; login accounts and credentials are unchanged. No Auth or schema changes.

Private recovery folder: Teacher `build/owner-reset-20261023-r3/`. Backup SHA256: `3d8788291311833226a553bf43f07743550144ea4ec7624c28a7e4b059d80dae`. Local PostgreSQL recovery drill restored all 16 tables, compared their complete contents and revalidated every FK, then rolled back. No hosted restore was performed.

Educational level was removed from student creation, edit, details and list columns. New student creation sends no level value; the nullable shared backend field remains for API compatibility. Group selection and atomic enrollment/billing remain required. The connected website was restarted and six read-only browser checks passed without creating fixtures.

Secretary unit tests: 31 passed; lint/typecheck/build passed. The full local synthetic browser run passed 14 cases; two cases timed out on an incorrect test-only Guardian-phone label. That label was corrected and the affected desktop/mobile student workflows were rerun separately: both passed. This is local SQL with synthetic Auth, not a claim that owner manual/device testing passed.

Open http://127.0.0.1:5173/ and refresh. Start with a group and then a student. No new test fixtures were created after the reset. Production resources and real-customer onboarding remain deferred.
