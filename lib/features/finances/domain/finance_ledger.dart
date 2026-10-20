import '../../../core/format/cairo_time.dart';
import 'finance_entry.dart';

/// Invoice cohorts follow due dates; cash movement reports follow receipt dates.
class FinanceLedger {
  FinanceLedger({
    required List<FinanceInvoice> invoices,
    required List<FinanceMovement> movements,
  }) : invoices = List.unmodifiable(invoices),
       movements = List.unmodifiable(movements);
  final List<FinanceInvoice> invoices;
  final List<FinanceMovement> movements;
  FinanceInvoice invoice(String id) => invoices.singleWhere((i) => i.id == id);
  BigInt paid(FinanceInvoice invoice) => movements
      .where((m) => m.invoiceId == invoice.id)
      .fold(BigInt.zero, (total, m) => total + m.signedAmount);
  BigInt remaining(FinanceInvoice invoice) =>
      invoice.voided ? BigInt.zero : invoice.amount - paid(invoice);
  List<FinanceInvoice> dueIn(DateTime month) => invoices
      .where(
        (i) =>
            !i.voided &&
            i.dueOn.year == month.year &&
            i.dueOn.month == month.month,
      )
      .toList();
  List<FinanceMovement> receivedIn(DateTime month) => movements.where((m) {
    final local = CairoTime.local(m.at);
    return local.year == month.year && local.month == month.month;
  }).toList();
  BigInt invoiced(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + i.amount);
  BigInt paidAgainst(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + paid(i));
  BigInt outstanding(DateTime month) =>
      dueIn(month).fold(BigInt.zero, (sum, i) => sum + remaining(i));
  BigInt net(DateTime month, {String? actor}) => receivedIn(month)
      .where((m) => actor == null || m.actor == actor)
      .fold(BigInt.zero, (sum, m) => sum + m.signedAmount);
  BigInt gross(DateTime month) => receivedIn(
    month,
  ).where((m) => !m.reversed).fold(BigInt.zero, (sum, m) => sum + m.amount);
  BigInt corrections(DateTime month) => receivedIn(
    month,
  ).where((m) => m.reversed).fold(BigInt.zero, (sum, m) => sum + m.amount);
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
