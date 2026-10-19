import '../../../core/format/money_egp.dart';

class FinanceRecord {
  const FinanceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.student,
    required this.amount,
    this.status,
    this.outstanding,
    this.paid,
    this.dueOn,
    this.signedAmount,
    this.receipt,
    this.collectedAt,
    this.collector,
    this.method,
    this.reversalOf,
    this.reason,
  });
  final String id, invoiceNumber, student;
  final MoneyEgp amount;
  final String? status, dueOn, receipt, collector, method, reversalOf, reason;
  final MoneyEgp? outstanding, paid, signedAmount;
  final DateTime? collectedAt;
  factory FinanceRecord.fromJson(Map<String, dynamic> j) => FinanceRecord(
    id: j['id'] as String,
    invoiceNumber: j['invoice_number'] as String,
    student: j['student_name'] as String,
    amount: MoneyEgp.parse(j['amount_egp']),
    status: j['status'] as String?,
    dueOn: j['due_on'] as String?,
    outstanding: j['outstanding_egp'] == null
        ? null
        : MoneyEgp.parse(j['outstanding_egp']),
    paid: j['net_paid_egp'] == null ? null : MoneyEgp.parse(j['net_paid_egp']),
    signedAmount: j['signed_amount_egp'] == null
        ? null
        : MoneyEgp.parse(j['signed_amount_egp']),
    receipt: j['receipt_number'] as String?,
    collectedAt: j['collected_at'] == null
        ? null
        : DateTime.parse(j['collected_at'] as String),
    collector: j['collected_by_name'] as String?,
    method: j['method'] as String?,
    reversalOf: j['reversal_of'] as String?,
    reason: (j['reason'] ?? j['void_reason']) as String?,
  );
}

class FinanceSummary {
  const FinanceSummary(this.values, this.daily);
  final Map<String, MoneyEgp> values, daily;
  factory FinanceSummary.fromJson(Map<String, dynamic> j) => FinanceSummary(
    Map.unmodifiable({
      for (final k in [
        'invoiced_egp',
        'paid_against_invoices_egp',
        'outstanding_egp',
        'period_net_collected_egp',
      ])
        k: MoneyEgp.parse(j[k]),
    }),
    Map.unmodifiable({
      for (final row in j['daily_collections'] as List)
        row['date'] as String: MoneyEgp.parse(row['net_egp']),
    }),
  );
}
