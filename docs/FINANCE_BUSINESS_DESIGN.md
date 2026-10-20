# Teacher finance business design — 2026-10-20

Current delivery is the debug offline UI preview, preserving the shared app bar and
navigation. No Supabase data is used by this preview and no hosted mutation or APK/
hot restart was performed. Production `LiveFinance` remains on its existing path;
this new UI is not claimed operational against hosted data.

## Questions answered

1. What actually came in during the selected month? Gross receipts minus full
   correction rows, with clear original/replacement receipt history.
2. What was due for this month, how much is settled and what remains? Invoice due
   dates define this cohort; earlier/advance collections are not conflated with it.
3. Who is overdue, partially paid, not yet late or settled? Search/filter invoice
   cards, remaining balance and due date; tap to inspect the complete invoice trail.
4. Who recorded each movement? Secretary filter, counts, signed net and payment
   method. Invoice creator and correcting actor are separate from original collector.
   Creation attribution does not assign responsibility for unpaid debts.
5. What would collecting a chosen percentage of remaining dues add? Local scenario
   and target gap/daily pace, with warning when a target exceeds current dues. No
   promise of collection, payment action or persisted target.

Overview, dues and movement tabs share month selection. Changes reset dependent
filters. Invoice history spans months; movement reports use Cairo receipt dates.
Today is not overdue until its due date has passed. Empty/future periods render
without fabricated received payments. Synthetic full reversals retain both rows.
The teacher never gets collection/refund/edit controls. No profit, expenses,
secretary cash custody or unmodeled cash-handover claims are presented.

## Reconciliation fixture at 2026-10-20

| Measure | EGP |
|---|---:|
| Selected-month invoices | 18,000 |
| Settled against those invoices | 11,400 |
| Outstanding against those invoices | 6,600 |
| Overdue portion | 3,000 |
| Due today or later | 3,600 |
| Gross receipts during month | 17,900 |
| Full corrections during month | 5,000 |
| Actual net receipts during month | 12,900 |
| Sara recorded net | 8,300 |
| Nour recorded net | 4,600 |

Net receipts include 1,000 against an older invoice and 500 paid in advance; this
explains the 1,500 difference from this month's invoice settlements. Prior-month
payment against the older invoice appears in its history, not current receipts.
The dashboard due-cohort card now uses paid_against_invoices_egp instead of period
net; its preview summary shares the same finance fixture. The dashboard unpaid
card/list now derives from the same ledger: five unpaid students totaling 6,600 at
the fixed review date, and each row opens its invoice history. Student-profile,
group and session design fixtures remain separate samples. Shared live contracts
must replace them before claiming cross-screen production reconciliation.

## Engineering and remaining activation

BigInt minor units preserve every piastre; comma-grouped currency displays decimals
only when needed. Exact invoice/receipt details preserve cents. Arabic/English
localization, shared theme surfaces, narrow screens and enlarged text are covered.
The new read-only proposals and their limits are documented separately in
FINANCE_BACKEND_CHANGE_REVIEW.md. No deployment approval is requested during the
owner's current UI-preview iteration. Live wiring and device/security/performance/
Secretary cross-app acceptance remain separate work; current mock tests do not
complete T-033 live acceptance.


Pre-push review: goal input now accepts Arabic/Persian/Latin digits through a
shared integer formatter. Financial-write permissions and hosted state unchanged.
See PRE_PUSH_REVIEW_2026-10-20.md for current verification and activation gaps.
