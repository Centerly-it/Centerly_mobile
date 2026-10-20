import '../../../core/format/cairo_time.dart';
import 'finance_entry.dart';
import 'finance_snapshot_index.dart';

/// Invoice cohorts follow due dates; cash movement reports follow receipt dates.
class FinanceLedger {
  FinanceLedger({
    required List<FinanceInvoice> invoices,
    required List<FinanceMovement> movements,
  }) : invoices = List.unmodifiable(invoices),
       movements = List.unmodifiable(movements),
       _index = FinanceSnapshotIndex(invoices, movements);
  final List<FinanceInvoice> invoices;
  final List<FinanceMovement> movements;
  final FinanceSnapshotIndex _index;
  FinanceInvoice invoice(String id) =>
      _index.byId[id] ?? (throw const FormatException('Unknown invoice'));
  FinanceMovement movement(String id) =>
      _index.byMovement[id] ??
      (throw const FormatException('Unknown movement'));
  FinanceMovement? correctionFor(String id) => _index.reversedBy[id];
  List<FinanceMovement> historyFor(String id) =>
      _index.history[invoice(id).id] ?? const [];
  BigInt paid(FinanceInvoice value) => _index.paid[invoice(value.id).id]!;
  BigInt remaining(FinanceInvoice value) {
    final original = invoice(value.id);
    return original.voided ? BigInt.zero : original.amount - paid(original);
  }

  List<FinanceInvoice> dueIn(DateTime month) =>
      _index.due[financeMonthKey(month)] ?? const [];
  List<FinanceMovement> receivedIn(DateTime month) =>
      _index.received[financeMonthKey(month)] ?? const [];
  BigInt invoiced(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + i.amount);
  BigInt paidAgainst(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + paid(i));
  BigInt outstanding(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + remaining(i));
  BigInt net(DateTime month, {String? actor}) => actor == null
      ? (_index.net[financeMonthKey(month)] ?? BigInt.zero)
      : (_index.actors[(financeMonthKey(month), actor)] ?? BigInt.zero);
  BigInt gross(DateTime month) =>
      _index.gross[financeMonthKey(month)] ?? BigInt.zero;
  BigInt corrections(DateTime month) =>
      _index.corrections[financeMonthKey(month)] ?? BigInt.zero;
  bool overdue(FinanceInvoice invoice, DateTime now) =>
      remaining(invoice) > BigInt.zero &&
      CairoTime.date(
            invoice.dueOn,
          ).compareTo(CairoTime.date(CairoTime.local(now))) <
          0;
  BigInt lateAmount(DateTime month, DateTime now) => dueIn(month)
      .where((i) => overdue(i, now))
      .fold(BigInt.zero, (sum, i) => sum + remaining(i));
}
