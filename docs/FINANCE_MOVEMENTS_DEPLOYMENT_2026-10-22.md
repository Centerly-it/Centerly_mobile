# Approved Finance movement deployment — 2026-10-22

Only `202610220001_finance_movements.sql` was approved and deployed to development
project centerly-dev (`yfeubomyglmhuwizaqoj`). Exact SHA256:
`e59af624e58ddb7875fc59c6f02278806fcdb8eb8c93ec8b0765a17848e2eedf`.
The reviewed bytes, including the historical LOCAL REVIEW comment, were copied
unchanged into managed migrations. No old version was edited or replayed.

## Preflight and deployment

- Verified linked ref and fresh project identity: centerly-dev, ACTIVE_HEALTHY.
- Fresh remote history matched all 25 baseline migration bodies. Full catalog
  matched the local 25-version schema:44 functions,18 tables,30 policies, grants,
  forced RLS, indexes, triggers and constraints. Enrollment violations0.
- Rechecked exact approved proposal SHA256 before copying and immediately before
  application. Dry run listed only 202610220001_finance_movements.sql; seeds/roles
  empty. Used --skip-vault; no Auth, account, configuration or data mutation scope.
- Applied only that file. Postflight verified all 26 remote migration bodies and
  the full local 26 catalog:45 functions,18 tables,30 policies. The only new schema
  object is the approved read function with its reviewed execute grants. Existing
  catalog objects/permissions remain identical. Enrollment violations0.
- Function body matches local approved SQL; SECURITY DEFINER/empty search_path,
  public+anon execute revoked, authenticated execute granted, teacher-only actor
  validation. Tenant/student/group/collector checks verified below.
- Pinned migration 26 in schema-manifest.json only after postflight passed. Re-ran
  complete pinned baseline verification and manifest hash check. Final dry run:
  up to date, migrations/seeds/roles all empty.

## Read-only hosted verification

`supabase/tests/finance_movements_readonly.sql` ran inside BEGIN READ ONLY using
only existing synthetic teacher-a/teacher-b/secretary-a records. No fixture writes,
account/status changes, provisioning, financial writes or data repairs occurred.

- 60 report combinations: empty/exact receipt/invoice/student/literal nonmatching
 search, each method and collection/correction kind.
- 230 limit-one pages, up to22 rows in a full report, including9 existing corrections.
- 2,466 teacher-side checks: full filtered count/gross/corrections/net on every page,
 exact signed amounts, UUID progression/no loss or duplicate pages, cursor identity,
 accumulated page net reconciles independently to the complete server report,
 original/current collector attribution and entity filters.
- Additional existing other-teacher scope check, foreign student/group/collector
 denial, invalid method/kind denial, Secretary denial and anonymous denial.
- Unauthenticated HTTP PostgREST request with the public publishable key returned401.

These are actual deployed SQL-role and anonymous HTTP checks, not password-based
teacher SDK/Auth acceptance. Original development credentials remain unavailable.
No JWT was fabricated or password reset. Active/inactive actor helper body and its
permissions are unchanged from the verified baseline; no account was toggled to
manufacture a test case.

## Client activation and independent checks

CENTERLY_FINANCE_MOVEMENT_FILTERS now defaults true in FinanceRepository; connected
VS Code launch explicitly enables it and disables preview. A complete explicit
synthetic transport handles the new read for offline/connected-widget tests; it is
not substituted into real connected mode. No optional feature was added.

- Flutter full suite251 PASS,1 hosted Auth opt-in SKIP.
- Activated Finance adapter and AR/EN200% connected traversal3 PASS, including
  correction-filter empty state and clearing the filter.
- Explicit preview transport/navigation3 PASS; analyzer no issues.
- Disposable local 26-version foundation90 PASS and movement contract29 PASS.
- Manifest26 hashes unchanged/zero pending; final pinned remote catalog comparison
  PASS. No new build or app restart was run during this deployment request.

Native synthetic smoke from the preceding implementation checkpoint remains
historical evidence; native filtering with a password-authenticated session and
manual contact completion await owner acceptance. The owner will request the final
configured build. Exact command and credential path: TEACHER_OWNER_TESTING.md.

Ignored evidence: build/finance-movements-deployment/{project-identity.json,
preflight-history.json,preflight-catalog.json,preflight-verification.log,dry-run.log,
deploy.log,postflight-history.json,postflight-catalog.json,postflight-verification.log,
pinned-baseline-verification.log,read-only-postflight.json,anonymous-rest.json,
manifest.log,final-dry-run.log,flutter-tests.log,activation-ui-tests.log,
preview-tests.log,foundation.log,local-finance-regression.log,analyze.log}.
