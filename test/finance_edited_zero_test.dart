import 'package:centrally/features/finances/domain/finance_due.dart';
import 'package:centrally/features/finances/domain/finance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final invoice = <String, dynamic>{
    'id': 'invoice',
    'invoice_number': 'internal',
    'student_name': 'أحمد',
    'group_name': 'فيزياء',
    'amount_egp': '0.00',
    'original_amount_egp': '1000.00',
    'net_paid_egp': '0.00',
    'outstanding_egp': '0.00',
    'status': 'paid',
    'due_on': '2026-10-23',
  };
  test('edited zero dues reconcile in Teacher list and detail', () {
    expect(FinanceRecord.fromJson(invoice).amount.minorUnits, BigInt.zero);
    expect(FinanceDue(invoice).outstanding, BigInt.zero);
    expect(FinanceDue({...invoice}..remove('status')).amount, BigInt.zero);
  });
  test('negative invoices and zero cash movements remain invalid', () {
    expect(
      () => FinanceDue({...invoice, 'amount_egp': '-1.00'}),
      throwsFormatException,
    );
    expect(
      () => FinanceRecord.fromJson({...invoice}..remove('status')),
      throwsFormatException,
    );
    expect(
      () => FinanceRecord.fromJson({...invoice, 'outstanding_egp': '1.00'}),
      throwsFormatException,
    );
  });
}
