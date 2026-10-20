import 'package:centrally/features/finances/domain/finance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> summary() => {
    'invoiced_egp': '100.01',
    'paid_against_invoices_egp': '40.01',
    'outstanding_egp': '60.00',
    'period_net_collected_egp': '-20.00',
    'daily_collections': [
      {'date': '2026-10-20', 'net_egp': '-20.00'},
    ],
  };
  test(
    'negative cash period remains valid independently of due-cohort settlements',
    () {
      final data = FinanceSummary.fromJson(summary());
      expect(data.values['period_net_collected_egp']!.decimal, '-20.00');
    },
  );
  test(
    'rejects inconsistent invoice totals and floating point ledger inputs',
    () {
      expect(
        () => FinanceSummary.fromJson(summary()..['outstanding_egp'] = '60.01'),
        throwsFormatException,
      );
      expect(
        () => FinanceSummary.fromJson(summary()..['invoiced_egp'] = 100.01),
        throwsFormatException,
      );
    },
  );
  test('rejects wrong daily sum, duplicate dates and impossible dates', () {
    expect(
      () => FinanceSummary.fromJson(summary()..['daily_collections'] = []),
      throwsFormatException,
    );
    expect(
      () => FinanceSummary.fromJson(
        summary()
          ..['daily_collections'] = [
            {'date': '2026-10-20', 'net_egp': '-10.00'},
            {'date': '2026-10-20', 'net_egp': '-10.00'},
          ],
      ),
      throwsFormatException,
    );
    expect(
      () => FinanceSummary.fromJson(
        summary()
          ..['daily_collections'] = [
            {'date': '2026-02-30', 'net_egp': '-20.00'},
          ],
      ),
      throwsFormatException,
    );
  });
  test(
    'row balances reconcile; void retains paid history without outstanding debt',
    () {
      final row = <String, dynamic>{
        'id': 'invoice',
        'invoice_number': 'INV-1',
        'student_name': 'Synthetic',
        'amount_egp': '100.01',
        'status': 'partially_paid',
        'net_paid_egp': '40.01',
        'outstanding_egp': '60.00',
      };
      expect(FinanceRecord.fromJson(row).paid!.decimal, '40.01');
      expect(
        () => FinanceRecord.fromJson({...row, 'outstanding_egp': '60.01'}),
        throwsFormatException,
      );
      expect(
        FinanceRecord.fromJson({
          ...row,
          'status': 'void',
          'outstanding_egp': '0.00',
        }).paid!.decimal,
        '40.01',
      );
    },
  );
  test('payment sign must match full collection/correction semantics', () {
    final row = <String, dynamic>{
      'id': 'receipt',
      'invoice_number': 'INV-1',
      'student_name': 'Synthetic',
      'amount_egp': '25.01',
      'signed_amount_egp': '25.01',
    };
    expect(FinanceRecord.fromJson(row).signedAmount!.decimal, '25.01');
    expect(
      () => FinanceRecord.fromJson({...row, 'reversal_of': 'original'}),
      throwsFormatException,
    );
    expect(
      FinanceRecord.fromJson({
        ...row,
        'reversal_of': 'original',
        'signed_amount_egp': '-25.01',
      }).signedAmount!.decimal,
      '-25.01',
    );
  });
}
