import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/finances/data/finance_repository.dart';
import 'package:centrally/features/finances/domain/finance_overview_data.dart';
import 'package:centrally/features/finances/domain/finance_receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

Map<String, dynamic> overview() => {
  'invoiced_egp': '1000.01',
  'paid_against_invoices_egp': '25.01',
  'outstanding_egp': '975.00',
  'period_net_collected_egp': '-25.01',
  'daily_collections': [
    {'date': '2026-10-22', 'net_egp': '-25.01'},
  ],
  'invoice_count': 40,
  'gross_collected_egp': '0.00',
  'corrections_egp': '25.01',
  'overdue_egp': '100.00',
  'due_today_egp': '75.00',
  'future_due_egp': '800.00',
  'actors': [
    {
      'actor_id': 'secretary',
      'actor_name': 'Historical collector',
      'collection_count': 0,
      'correction_count': 1,
      'net_egp': '-25.01',
    },
  ],
  'methods': [
    {'method': 'cash', 'net_egp': '-25.01'},
  ],
  'as_of_date': '2026-10-22',
  'synced_at': '2026-10-22T12:00:00Z',
};
Map<String, dynamic> due(String id) => {
  'id': id,
  'invoice_number': 'INV-$id',
  'student_name': 'Student',
  'group_name': 'Group',
  'amount_egp': '100.01',
  'net_paid_egp': '25.01',
  'outstanding_egp': '75.00',
  'due_on': '2026-10-20',
};
void main() {
  test('overview preserves exact server totals and negative period cash', () {
    final value = FinanceOverviewData(overview());
    expect(value.invoiced, BigInt.from(100001));
    expect(value.net, BigInt.from(-2501));
    expect(value.invoiceCount, 40);
    expect(value.actors.single.name, 'Historical collector');
    expect(
      () => FinanceOverviewData({...overview(), 'future_due_egp': '801.00'}),
      throwsFormatException,
    );
    expect(
      () => FinanceOverviewData({...overview(), 'gross_collected_egp': 0}),
      throwsFormatException,
    );
  });
  test(
    'dues sends filters before paging and uses totals for all 40 invoices',
    () async {
      final requests = <Map<String, dynamic>>[];
      final client = readFixture((r) async {
        expect(r.url.path, endsWith('list_teacher_finance_dues'));
        final params = Map<String, dynamic>.from(jsonDecode(r.body) as Map);
        requests.add(params);
        final id = params['p_cursor'] == null ? 'a' : 'b';
        return jsonResponse(r, {
          'rows': [due(id)],
          'total_count': 40,
          'next_cursor': id == 'a' ? id : null,
          'summary': {
            'invoiced_egp': '1000.01',
            'net_paid_egp': '25.01',
            'outstanding_egp': '975.00',
          },
          'as_of_date': '2026-10-22',
          'synced_at': '2026-10-22T12:00:00Z',
        });
      });
      addTearDown(client.dispose);
      final repo = FinanceRepository(TeacherReadClient(client));
      final filters = {
        'p_from': '2026-10-01',
        'p_to': '2026-10-31',
        'p_status': 'partial',
        'p_search': 'Student',
        'p_group_id': 'group',
      };
      final first = await repo.dues(filters, null),
          next = await repo.dues(filters, 'a');
      expect(first.total, 40);
      expect(first.rows.single.outstanding, BigInt.from(7500));
      expect(first.summary.amount('outstanding_egp'), BigInt.from(97500));
      expect(next.summary.amount('outstanding_egp'), BigInt.from(97500));
      expect(requests.last, {...filters, 'p_cursor': 'a', 'p_limit': 30});
    },
  );
  test(
    'dues rejects non-advancing pages and inconsistent monetary values',
    () async {
      final client = readFixture(
        (r) async => jsonResponse(r, {
          'rows': [due('a')],
          'total_count': 1,
          'next_cursor': null,
          'summary': {
            'invoiced_egp': '100.01',
            'net_paid_egp': '25.01',
            'outstanding_egp': '75.00',
          },
          'as_of_date': '2026-10-22',
          'synced_at': '2026-10-22T12:00:00Z',
        }),
      );
      addTearDown(client.dispose);
      await expectLater(
        FinanceRepository(TeacherReadClient(client)).dues({}, 'a'),
        throwsA(isA<BackendFailure>()),
      );
    },
  );
  test(
    'receipts validate signed exact money and preserve original attribution',
    () {
      final r = {
        'id': 'r',
        'invoice_id': 'i',
        'receipt_number': 'receipt',
        'method': 'cash',
        'collected_at': '2026-10-22T12:00:00Z',
        'amount_egp': '25.01',
        'signed_amount_egp': '-25.01',
        'reversal_of': 'original',
        'original_collected_by_name': 'Original',
        'collected_by_name': 'Corrector',
      };
      expect(validatedReceipt(r)['original_collected_by_name'], 'Original');
      expect(
        () => validatedReceipt({...r, 'signed_amount_egp': '25.01'}),
        throwsFormatException,
      );
      expect(
        () => validatedReceipt({...r, 'amount_egp': 25.01}),
        throwsFormatException,
      );
    },
  );
}
