import '../format/cairo_time.dart';
import '../format/money_egp.dart';

/// Complete, explicit synthetic dataset only; never used by connected transport.
Map<String, dynamic> previewFinanceMovements(
  Map<String, dynamic> data,
  Map<String, dynamic> filters,
) {
  final invoices = {
    for (final row in data['invoices']['rows'] as List) row['id']: row,
  };
  final search = (filters['p_search'] as String? ?? '').toLowerCase();
  final all =
      (data['payments']['rows'] as List)
          .where((row) {
            final invoice = invoices[row['invoice_id']] as Map;
            final date = CairoTime.date(
              CairoTime.local(DateTime.parse(row['collected_at'] as String)),
            );
            final from = filters['p_from'] as String?,
                to = filters['p_to'] as String?;
            return (from == null || date.compareTo(from) >= 0) &&
                (to == null || date.compareTo(to) <= 0) &&
                (filters['p_method'] == null ||
                    row['method'] == filters['p_method']) &&
                (filters['p_kind'] == null ||
                    (filters['p_kind'] == 'corrections') ==
                        (row['reversal_of'] != null)) &&
                (filters['p_secretary_id'] == null ||
                    row['collected_by'] == filters['p_secretary_id']) &&
                (filters['p_student_id'] == null ||
                    invoice['student_id'] == filters['p_student_id']) &&
                (filters['p_group_id'] == null ||
                    invoice['group_id'] == filters['p_group_id']) &&
                '${row['student_name']} ${row['invoice_number']} ${row['receipt_number']}'
                    .toLowerCase()
                    .contains(search);
          })
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList()
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  var gross = BigInt.zero, corrections = BigInt.zero;
  for (final row in all) {
    final amount = MoneyEgp.parse(row['amount_egp']).minorUnits;
    if (row['reversal_of'] == null) {
      gross += amount;
    } else {
      corrections += amount;
    }
  }
  final cursor = filters['p_cursor'] as String?,
      limit = filters['p_limit'] as int? ?? 30;
  final page = all
      .where((r) => cursor == null || (r['id'] as String).compareTo(cursor) > 0)
      .take(limit + 1)
      .toList();
  final rows = page.take(limit).toList();
  return {
    'rows': rows,
    'total_count': all.length,
    'next_cursor': page.length > limit ? rows.last['id'] : null,
    'synced_at': DateTime.now().toUtc().toIso8601String(),
    'summary': {
      'gross_egp': MoneyEgp.fromMinorUnits(gross).decimal,
      'corrections_egp': MoneyEgp.fromMinorUnits(corrections).decimal,
      'net_egp': MoneyEgp.fromMinorUnits(gross - corrections).decimal,
    },
  };
}
