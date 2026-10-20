import 'finance_entry.dart';

/// A ledger is a complete snapshot, never one remote pagination page.
void validateFinanceSnapshot(
  List<FinanceMovement> movements, {
  required Map<String, FinanceInvoice> invoices,
  required Map<String, FinanceMovement> byMovement,
  required Map<String, FinanceMovement> reversedBy,
  required Map<String, BigInt> balances,
}) {
  for (final m in movements) {
    if (!{'cash', 'transfer', 'other'}.contains(m.method)) {
      throw const FormatException('Invalid method');
    }
    if (m.reversalOf case final String id) {
      final original = byMovement[id];
      if (original == null ||
          original.reversed ||
          original.invoiceId != m.invoiceId ||
          original.amount != m.amount ||
          original.method != m.method ||
          reversedBy.containsKey(id)) {
        throw const FormatException('Invalid full reversal');
      }
      reversedBy[id] = m;
    }
  }
  for (final invoice in invoices.values) {
    final paid = balances[invoice.id]!;
    if (paid < BigInt.zero || paid > invoice.amount) {
      throw const FormatException('Invalid invoice balance');
    }
  }
}
