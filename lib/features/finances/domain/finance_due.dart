import '../../../core/data/read_page.dart';
import '../../../core/format/money_egp.dart';
import 'finance_entry.dart';

class FinanceDue {
  FinanceDue(Map<String, dynamic> j)
    : id = j['id'] as String,
      number = j['invoice_number'] as String,
      student = j['student_name'] as String,
      group = j['group_name'] as String? ?? '',
      amount = MoneyEgp.parse(j['amount_egp']).minorUnits,
      paid = MoneyEgp.parse(j['net_paid_egp']).minorUnits,
      outstanding = MoneyEgp.parse(j['outstanding_egp']).minorUnits,
      due = DateTime.parse(j['due_on'] as String),
      creator = j['created_by_name'] as String?,
      settlementRequired = j['attendance_settlement_required'] == true,
      status = j['status'] as String? {
    if (amount < BigInt.zero ||
        paid < BigInt.zero ||
        paid > amount ||
        outstanding < BigInt.zero ||
        (status == 'void'
            ? outstanding != BigInt.zero
            : paid + outstanding != amount)) {
      throw const FormatException('Invalid invoice');
    }
  }
  final String id, number, student, group;
  final String? creator, status;
  final bool settlementRequired;
  final BigInt amount, paid, outstanding;
  final DateTime due;
  FinanceInvoice get design => FinanceInvoice(
    id: number,
    studentKey: student,
    groupKey: group,
    amount: amount,
    dueOn: due,
    createdBy: creator,
    voided: status == 'void',
    localized: false,
  );
}

class FinanceDuesSummary {
  FinanceDuesSummary(Map<String, dynamic> j)
    : asOf = DateTime.parse(j['as_of_date'] as String),
      values = readMap(j['summary']) {
    if (amount('invoiced_egp') !=
        amount('net_paid_egp') + amount('outstanding_egp')) {
      throw const FormatException('Unreconciled dues');
    }
  }
  final DateTime asOf;
  final Map<String, dynamic> values;
  BigInt amount(String key) => MoneyEgp.parse(values[key]).minorUnits;
}
