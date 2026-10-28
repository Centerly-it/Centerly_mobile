import 'package:centrally/features/groups/domain/group_record.dart';
import 'package:centrally/features/finances/domain/finance_due.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/group_read_fixture.dart';

void main() {
  test('old groups keep monthly behavior without new fields', () {
    final group = GroupRecord.fromJson(groupJson('g'));
    expect(group.billingMode, 'monthly');
    expect(group.billingPrice, isNull);
  });
  test('per-session group retains the exact server tariff', () {
    final group = GroupRecord.fromJson({
      ...groupJson('g'),
      'billing_mode': 'per_session',
      'session_fee_egp': '50.05',
    });
    expect(group.billingMode, 'per_session');
    expect(group.billingPrice, '50.05');
  });
  test('unknown billing modes or missing tariffs fail closed', () {
    expect(
      () =>
          GroupRecord.fromJson({...groupJson('g'), 'billing_mode': 'unknown'}),
      throwsFormatException,
    );
    expect(
      () => GroupRecord.fromJson({
        ...groupJson('g'),
        'billing_mode': 'per_session',
      }),
      throwsFormatException,
    );
  });
  test(
    'manual settlement preserves actual paid money and zero collectible balance',
    () {
      final invoice = FinanceDue({
        'id': 'invoice',
        'invoice_number': 'SESSION',
        'student_name': 'طالب',
        'group_name': 'مجموعة',
        'amount_egp': '20.00',
        'net_paid_egp': '20.00',
        'outstanding_egp': '0.00',
        'due_on': '2026-10-28',
        'status': 'paid',
        'attendance_settlement_required': true,
      });
      expect(invoice.settlementRequired, isTrue);
      expect(invoice.paid, BigInt.from(2000));
      expect(invoice.outstanding, BigInt.zero);
    },
  );
}
