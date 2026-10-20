import '../../../core/format/cairo_time.dart';
import '../../../core/format/money_egp.dart';
import 'finance_preview_fixture.dart';

/// Shared only by the offline preview transport and finance preview.
Map<String, dynamic> financePreviewSummary({DateTime? instant}) {
  final now = instant ?? DateTime.now();
  final local = CairoTime.local(now);
  final month = DateTime(local.year, local.month);
  final ledger = FinancePreviewFixture.build(month, now);
  String decimal(BigInt value) => MoneyEgp.fromMinorUnits(value).decimal;
  final daily = <String, BigInt>{};
  for (final row in ledger.receivedIn(month)) {
    final key = CairoTime.date(CairoTime.local(row.at));
    daily[key] = (daily[key] ?? BigInt.zero) + row.signedAmount;
  }
  final days = daily.keys.toList()..sort();
  return {
    'invoiced_egp': decimal(ledger.invoiced(month)),
    'paid_against_invoices_egp': decimal(ledger.paidAgainst(month)),
    'outstanding_egp': decimal(ledger.outstanding(month)),
    'period_net_collected_egp': decimal(ledger.net(month)),
    'daily_collections': [
      for (final day in days) {'date': day, 'net_egp': decimal(daily[day]!)},
    ],
  };
}
