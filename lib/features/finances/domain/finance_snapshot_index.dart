import '../../../core/format/cairo_time.dart';
import 'finance_entry.dart';
import 'finance_snapshot_validation.dart';

int financeMonthKey(DateTime date) => date.year * 12 + date.month;

/// One O(invoices + movements) pass; no repeated whole-ledger scans per card.
class FinanceSnapshotIndex {
  FinanceSnapshotIndex(
    List<FinanceInvoice> invoices,
    List<FinanceMovement> movements,
  ) {
    for (final invoice in invoices) {
      if (byId.containsKey(invoice.id) ||
          invoice.id.isEmpty ||
          invoice.amount <= BigInt.zero) {
        throw const FormatException('Invalid invoice snapshot');
      }
      byId[invoice.id] = invoice;
      paid[invoice.id] = BigInt.zero;
      if (!invoice.voided) {
        (due[financeMonthKey(invoice.dueOn)] ??= []).add(invoice);
      }
    }
    for (final m in movements) {
      if (byMovement.containsKey(m.id) ||
          m.id.isEmpty ||
          !byId.containsKey(m.invoiceId) ||
          m.amount <= BigInt.zero) {
        throw const FormatException('Invalid movement snapshot');
      }
      byMovement[m.id] = m;
      paid[m.invoiceId] = paid[m.invoiceId]! + m.signedAmount;
      (history[m.invoiceId] ??= []).add(m);
      final key = financeMonthKey(CairoTime.local(m.at));
      (received[key] ??= []).add(m);
      net[key] = (net[key] ?? BigInt.zero) + m.signedAmount;
      final bucket = m.reversed ? corrections : gross;
      bucket[key] = (bucket[key] ?? BigInt.zero) + m.amount;
      actors[(key, m.actor)] =
          (actors[(key, m.actor)] ?? BigInt.zero) + m.signedAmount;
    }
    validateFinanceSnapshot(
      movements,
      invoices: byId,
      byMovement: byMovement,
      reversedBy: reversedBy,
      balances: paid,
    );
    due.updateAll((_, rows) => List.unmodifiable(rows));
    received.updateAll((_, rows) => List.unmodifiable(rows));
    history.updateAll((_, rows) => List.unmodifiable(rows));
  }
  final byId = <String, FinanceInvoice>{},
      byMovement = <String, FinanceMovement>{};
  final paid = <String, BigInt>{};
  final due = <int, List<FinanceInvoice>>{};
  final received = <int, List<FinanceMovement>>{};
  final history = <String, List<FinanceMovement>>{};
  final net = <int, BigInt>{},
      gross = <int, BigInt>{},
      corrections = <int, BigInt>{};
  final actors = <(int, String), BigInt>{};
  final reversedBy = <String, FinanceMovement>{};
}
