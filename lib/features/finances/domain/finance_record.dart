export 'finance_summary.dart';
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
    this.invoiceId,
    this.group,
  });
  final String id, invoiceNumber, student;
  final String? invoiceId, group;
  final MoneyEgp amount;
  final String? status, dueOn, receipt, collector, method, reversalOf, reason;
  final MoneyEgp? outstanding, paid, signedAmount;
  final DateTime? collectedAt;
  factory FinanceRecord.fromJson(Map<String, dynamic> j) {
    final value = FinanceRecord(
      id: j['id'] as String,
      invoiceId: j['invoice_id'] as String?,
      group: j['group_name'] as String?,
      invoiceNumber: j['invoice_number'] as String,
      student: j['student_name'] as String,
      amount: MoneyEgp.parse(j['amount_egp']),
      status: j['status'] as String?,
      dueOn: j['due_on'] as String?,
      outstanding: j['outstanding_egp'] == null
          ? null
          : MoneyEgp.parse(j['outstanding_egp']),
      paid: j['net_paid_egp'] == null
          ? null
          : MoneyEgp.parse(j['net_paid_egp']),
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
    final amount = value.amount.minorUnits,
        paid = value.paid?.minorUnits,
        left = value.outstanding?.minorUnits;
    if (amount < BigInt.zero ||
        (value.status == null && amount == BigInt.zero)) {
      throw const FormatException('Invalid amount');
    }
    if (value.status != null) {
      if (!{'due', 'partially_paid', 'paid', 'void'}.contains(value.status) ||
          paid == null ||
          left == null ||
          paid < BigInt.zero ||
          paid > amount ||
          left < BigInt.zero) {
        throw const FormatException('Invalid invoice amounts');
      }
      if (value.status == 'void'
          ? left != BigInt.zero
          : amount != paid + left) {
        throw const FormatException('Unreconciled invoice');
      }
    } else {
      if (value.signedAmount?.minorUnits !=
          (value.reversalOf == null ? amount : -amount)) {
        throw const FormatException('Invalid movement sign');
      }
    }
    return value;
  }
}
