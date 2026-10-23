# Proposed minimal fresh owner-test scope — approval required, not executed

Namespace: `OWNER28-20261023`, centerly-dev only. Existing synthetic Teacher A / Secretary A and tenant membership must match the approved credential file; B is read-only for denial checks. No account/password/Auth changes. Do not reuse or mutate SEC27 fixtures.

Purpose: let the owner exercise student/group edits, attendance, academics, payment/receipt notification and Teacher refresh once. Before starting, inspect a separate registry and hosted namespace for partial work; reconcile rather than duplicate. Record returned IDs and original payment idempotency key locally. Stop on unexpected identity, tenant, status, totals, duplicate namespace, uncertain writes, ceiling breach or unrelated affected rows.

| Bound               | Maximum                                                                                                                                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| New student/group   | One each, names prefixed with namespace; at most one subsequent edit each; reuse existing synthetic grade A                                                                                                  |
| Enrollment          | One active membership for that student/group; no other enrollments                                                                                                                                           |
| Trusted setup       | One explicitly scoped session for that group (Cairo time, starts 15 minutes before setup and ends 45 minutes after) and one unmarked attendance row for that student; no schedules or tenant-wide generation |
| Attendance          | One mark, one manual finalization, at most one reasoned correction; at most two change-log rows                                                                                                              |
| Academics           | One exam (score 0) and one assignment (submitted); at most one correction each                                                                                                                               |
| Finance             | One invoice exactly EGP 10.00; one collection exactly EGP 4.00 with one fixed original key; at most one full EGP 4.00 reasoned reversal. No new key/replay on uncertain result before reconciliation         |
| Notifications/audit | At most six automatic notifications and twelve audit events; at most two mark-read actions on new namespace events only. No manual notification/audit insertions                                             |
| Teacher actions     | Refresh/read only; zero note saves, removal requests or cancellations                                                                                                                                        |
| Retention           | Keep every history/receipt/audit row. No voiding, deleting, reactivation or cleanup in this scope                                                                                                            |

Expected finance: invoice original 10.00; after collection ledger 4.00/payable 6.00; after optional full reversal ledger 0.00/payable 10.00. Tenant totals change only by these explicitly recorded amounts (outstanding +10.00 after reversal). Rows remain identifiable and operational at test end; do not claim cleanup. No real names/contacts, outbound calls/messages, production data/resources or publishing.

Approval requested as one package: permit the bounded synthetic creation/setup and owner UI actions above. Until approved, only retained-record read-only testing is ready; this proposal creates nothing and grants no write permission by itself.
