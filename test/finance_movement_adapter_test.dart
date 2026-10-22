import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/finances/data/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'movement adapter retains full totals and server filter arguments',
    () async {
      const advanced = FinanceRepository.movementFilters;
      final client = readFixture((request) async {
        expect(
          request.url.path,
          endsWith(
            advanced ? 'list_teacher_finance_movements' : 'get_teacher_finance',
          ),
        );
        final params = jsonDecode(request.body) as Map;
        expect(params['p_cursor'], 'a');
        expect(params['p_secretary_id'], 'collector');
        expect(params['p_group_id'], 'group');
        expect(params['p_kind'], advanced ? 'corrections' : 'payments');
        if (advanced) {
          expect(params['p_search'], 'invoice');
          expect(params['p_method'], 'cash');
        }
        return jsonResponse(request, {
          'total_count': 33,
          'next_cursor': null,
          'synced_at': '2026-10-22T12:00:00Z',
          'rows': [
            {
              'id': 'b',
              'invoice_id': 'invoice',
              'receipt_number': 'receipt',
              'method': 'cash',
              'collected_at': '2026-10-22T12:00:00Z',
              'amount_egp': '25.01',
              'signed_amount_egp': '-25.01',
              'reversal_of': 'original',
              'collected_by_name': 'Corrector',
            },
          ],
          'summary': advanced
              ? {
                  'net_egp': '-1000.01',
                  'gross_egp': '0.00',
                  'corrections_egp': '1000.01',
                }
              : {'period_net_collected_egp': '-1000.01'},
        });
      });
      addTearDown(client.dispose);
      final page = await FinanceRepository(TeacherReadClient(client)).movements(
        {
          'p_from': '2026-10-01',
          'p_to': '2026-10-31',
          'p_secretary_id': 'collector',
          'p_group_id': 'group',
          if (advanced) ...{
            'p_search': 'invoice',
            'p_method': 'cash',
            'p_kind': 'corrections',
          },
        },
        'a',
      );
      expect(page.total, 33);
      expect(page.rows.length, 1);
      expect(page.summary.net, BigInt.from(-100001));
    },
  );
}
