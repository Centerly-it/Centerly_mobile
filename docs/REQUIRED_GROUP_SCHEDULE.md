# Required group schedule — deployed 23 October 2026

Owner authorized immediate development backend implementation without another approval. One Teacher-owned migration deployed to centerly-dev only: 202610230004_required_group_schedule.sql. No production, account or business-data changes.

New groups require weekday, start/end time and effective-from date (the form defaults the date to Cairo today). secretary_create_scheduled_group creates group, initial schedule and immutable request audit atomically. Same UUID/payload replay returns the original result; mismatched replay conflicts. Failed schedule insertion rolls back group creation. Teacher role and cross-tenant writes remain denied. Direct authenticated group INSERT is revoked; the legacy five-argument creation RPC accepts only matching existing-group replays and cannot create unscheduled groups. Existing update/archive flows remain available. More weekly days can be added through the existing schedule action.

Calendar loads every authorized page of active groups and schedules, showing all current/future weekly appointments. Existing groups with no unexpired schedule are explicitly shown with «حدد ميعاد المجموعة». No times were invented: both current owner groups lack schedules and need the owner to choose them. Archived group history remains preserved; no schedule/session history rewritten.

- Migration SHA256: 006e350c0847773da71f68af2f9d8b36d278d2d8a95f06590af38ccbb621e6c6.
- Exact transaction preview SHA256: 7e971ccaa01698421413e20454302b743f5a02ff47105027717360f82b4ce5b1.
- Preflight matched 30 migration bodies/full catalog. Dry run listed only this migration, with skip-vault and no roles/seeds. Applied once. Final dry run: up to date.
- Postflight matched 31 bodies and full catalog/grants: 68 functions, 18 tables, 30 policies, 24 triggers. All 18 table row fingerprints and financial totals identical before/after. No fixture mutations, cleanup or SEC27 replay.
- Local PostgreSQL role simulation: 20 checks, including missing schedule, direct insert denial, retry, cross-tenant isolation and rollback after schedule failure. Teacher baseline: 90 assertions. Secretary: 36 unit tests/lint/build; 16 local synthetic browser scenarios across desktop/mobile, including required schedule submission. No physical acceptance claimed.
- Actual connected Chromium: 15 read-only UI checks; all 2 existing active groups shown, both correctly flagged missing schedules. Renewal RPC explicitly stubbed twice to keep verification read-only. No group or schedule submitted to hosted data.

Both backend manifests pin version 31. Local website: http://127.0.0.1:5173/. Teacher app uses existing read contracts and requires no application change or new APK for this migration. Owner manual/device testing remains outstanding. Web development artifact rebuilt and credential-scanned.
