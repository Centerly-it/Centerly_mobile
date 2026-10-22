import '../../../core/data/read_page.dart';
import '../../../core/format/money_egp.dart';
import 'finance_summary.dart';

/// Complete server aggregates, never a ledger reconstructed from loaded pages.
class FinanceOverviewData {
  FinanceOverviewData(Map<String, dynamic> json)
    : summary = FinanceSummary.fromJson(json),
      invoiceCount = readCount(json['invoice_count']),
      gross = money(json['gross_collected_egp']),
      corrections = money(json['corrections_egp']),
      overdue = money(json['overdue_egp']),
      dueToday = money(json['due_today_egp']),
      futureDue = money(json['future_due_egp']),
      asOf = DateTime.parse(json['as_of_date'] as String),
      syncedAt = DateTime.parse(json['synced_at'] as String),
      actors = List.unmodifiable(
        (json['actors'] as List).map((r) => FinanceActor(readMap(r))),
      ),
      methods = Map.unmodifiable({
        for (final r in json['methods'] as List)
          r['method'] as String: money(r['net_egp']),
      }) {
    if (gross < BigInt.zero ||
        corrections < BigInt.zero ||
        gross - corrections != net ||
        overdue < BigInt.zero ||
        dueToday < BigInt.zero ||
        futureDue < BigInt.zero ||
        overdue + dueToday + futureDue != outstanding ||
        actors.fold(BigInt.zero, (s, a) => s + a.net) != net ||
        methods.values.fold(BigInt.zero, (s, v) => s + v) != net) {
      throw const FormatException('Unreconciled overview');
    }
  }
  final FinanceSummary summary;
  final int invoiceCount;
  final BigInt gross, corrections, overdue, dueToday, futureDue;
  final DateTime asOf, syncedAt;
  final List<FinanceActor> actors;
  final Map<String, BigInt> methods;
  BigInt get net => summary.values['period_net_collected_egp']!.minorUnits;
  BigInt get invoiced => summary.values['invoiced_egp']!.minorUnits;
  BigInt get paid => summary.values['paid_against_invoices_egp']!.minorUnits;
  BigInt get outstanding => summary.values['outstanding_egp']!.minorUnits;
  static BigInt money(dynamic value) => MoneyEgp.parse(value).minorUnits;
}

class FinanceActor {
  FinanceActor(Map<String, dynamic> j)
    : id = j['actor_id'] as String,
      name = j['actor_name'] as String?,
      collections = readCount(j['collection_count']),
      corrections = readCount(j['correction_count']),
      net = FinanceOverviewData.money(j['net_egp']);
  final String id;
  final String? name;
  final int collections, corrections;
  final BigInt net;
}
