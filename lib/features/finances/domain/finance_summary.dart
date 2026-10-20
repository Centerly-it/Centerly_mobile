import '../../../core/format/money_egp.dart';
import '../../../core/format/cairo_time.dart';

class FinanceSummary {
  const FinanceSummary(this.values, this.daily);
  final Map<String, MoneyEgp> values, daily;
  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    final values = {
      for (final key in [
        'invoiced_egp',
        'paid_against_invoices_egp',
        'outstanding_egp',
        'period_net_collected_egp',
      ])
        key: MoneyEgp.parse(json[key]),
    };
    final total = values['invoiced_egp']!.minorUnits,
        paid = values['paid_against_invoices_egp']!.minorUnits,
        left = values['outstanding_egp']!.minorUnits;
    if (total < BigInt.zero ||
        paid < BigInt.zero ||
        left < BigInt.zero ||
        total != paid + left) {
      throw const FormatException('Unreconciled invoice totals');
    }
    final daily = <String, MoneyEgp>{};
    for (final row in json['daily_collections'] as List) {
      final date = row['date'] as String;
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
          CairoTime.date(DateTime.parse(date)) != date ||
          daily.containsKey(date)) {
        throw const FormatException('Invalid daily collection');
      }
      daily[date] = MoneyEgp.parse(row['net_egp']);
    }
    if (daily.values.fold(BigInt.zero, (sum, v) => sum + v.minorUnits) !=
        values['period_net_collected_egp']!.minorUnits) {
      throw const FormatException('Unreconciled cash totals');
    }
    return FinanceSummary(Map.unmodifiable(values), Map.unmodifiable(daily));
  }
}
