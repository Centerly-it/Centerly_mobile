# Simple daily workspace — 2026-10-23

One schedule navigation entry with recurring group/day/time cards and per-day edits. Header shows actual teacher and secretary names. Groups use dropdowns without search; new prices start blank. Direct edit links simplify daily work. Operational payment views show current collections while preserving raw ledger history.

No hosted business/schema writes, resets, account changes or new fixtures occurred. FIN30 financial editing is prepared locally, NOT deployed or registered; both manifests remain at 29 and connected financial saving is disabled pending the exact review in SIMPLE_FINANCE_EDIT_REVIEW.md.

Validation: Secretary 36 unit tests plus lint/build; 16 synthetic SQL-fixture browser scenarios across desktop/mobile; 26 local PostgreSQL SQL-role checks; Teacher 14 targeted tests plus analyzer/configured APK build. Actual authenticated connected Chromium: 9 read-only UI checks, zero business writes. Renewal RPC was guarded/stubbed by the probe, not encountered. Device absent from ADB; no physical acceptance or new installation claimed.

Web: http://127.0.0.1:5173/. Configured APK SHA256: aefc8ec616ab204cad2d72dabc4b9ae1955f502f40316786d0a53a81a4a59fd2. Artifact inventories refreshed; decompressed APK and web credential scan found zero matches. Production remains deferred. Remaining owner actions: approve FIN30 for development deployment to enable financial edits; reconnect phone for installing this APK and owner testing.

Proposed shared API: secretary_edit_finance(text,uuid,numeric,numeric,uuid,date,text), with expected-value concurrency protection, transaction locks and idempotent immutable audit. original_amount_egp remains original face; amount_egp is adjusted effective total; ledger_net_egp and payable_balance_egp retain their existing meanings. No ledger rows erased. Teacher movement history remains complete and prepared parsers allow zero adjusted dues. Connected finance-edit flag stays false until approved deployment.
