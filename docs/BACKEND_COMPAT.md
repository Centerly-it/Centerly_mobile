# Backend compatibility — development deployment

Schema version range: 202610180001 through 202610190001, canonical in this repo.
The original nine plus the approved additive read version are deployed and verified on centerly-dev / yfeubomyglmhuwizaqoj,
PostgreSQL 17.11, after explicit owner approval on 2026-10-18. Hosted introspection
confirms 18 tables, 30 policies, forced RLS and restricted RPCs. Current Flutter auth
uses Supabase Auth and the database-backed profile contract; legacy prototype
operational models are not production data adapters.

Typed TeacherProfile matches get_current_profile(); role/tenant validation and
actual Dart SDK hosted login/refresh/logout/secretary-denial tests pass. Current read repositories are typed; remaining feature-specific contracts and
full cross-app acceptance remain open. supabase/schema-manifest.json
pins the exact deployed migration hashes; check it before coordinated releases.
Transfer ownership without reapplying migration IDs when Secretary repo is ready.

The 2026-10-19 read deployment compared exact migration-history SQL to local files,
verified grants/search paths and tenant/role behavior in hosted read-only
transactions. No fixture/Auth-setting mutations ran. Hosted Auth/SDK password tests
were not repeated: the original ignored account credentials are unavailable here.
