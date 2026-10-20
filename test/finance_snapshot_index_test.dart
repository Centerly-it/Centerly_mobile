import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/features/finances/domain/finance_entry.dart';
import 'package:centrally/features/finances/domain/finance_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FinanceInvoice invoice(String id, {bool voided = false}) => FinanceInvoice(
    id: id,
    studentKey: 'student-$id',
    groupKey: 'group',
    amount: BigInt.from(10000),
    dueOn: DateTime(2026, 10),
    voided: voided,
  );
  FinanceMovement movement(
    String id,
    String invoice, {
    String? reversal,
    int amount = 101,
    String method = 'cash',
  }) => FinanceMovement(
    id: id,
    invoiceId: invoice,
    amount: BigInt.from(amount),
    actor: 'actor',
    at: DateTime.utc(2026, 10, 1),
    method: method,
    reversalOf: reversal,
  );
  test(
    'indexed results equal independent reference sums with voids, months and full reversals',
    () {
      final invoices = [
        for (var n = 0; n < 200; n++) invoice('$n', voided: n % 17 == 0),
      ];
      final rows = <FinanceMovement>[];
      for (var n = 0; n < 200; n++) {
        for (var p = 0; p < 5; p++) {
          rows.add(movement('$n-$p', '$n'));
        }
        if (n % 3 == 0) rows.add(movement('$n-r', '$n', reversal: '$n-0'));
      }
      final ledger = FinanceLedger(
        invoices: invoices,
        movements: rows.reversed.toList(),
      );
      BigInt paid(FinanceInvoice i) => rows
          .where((r) => r.invoiceId == i.id)
          .fold(BigInt.zero, (sum, r) => sum + r.signedAmount);
      for (final i in invoices) {
        expect(ledger.paid(i), paid(i));
        expect(
          ledger.remaining(i),
          i.voided ? BigInt.zero : i.amount - paid(i),
        );
        expect(
          ledger.historyFor(i.id).length,
          rows.where((r) => r.invoiceId == i.id).length,
        );
      }
      final month = DateTime(2026, 10);
      expect(
        ledger.outstanding(month),
        invoices
            .where((i) => !i.voided)
            .fold(BigInt.zero, (sum, i) => sum + i.amount - paid(i)),
      );
      expect(
        ledger.net(month),
        rows.fold(BigInt.zero, (sum, r) => sum + r.signedAmount),
      );
      expect(ledger.net(month, actor: 'missing'), BigInt.zero);
      expect(ledger.receivedIn(DateTime(2026, 9)), isEmpty);
      expect(
        ledger.invoiced(month),
        ledger.paidAgainst(month) + ledger.outstanding(month),
      );
      expect(() => ledger.receivedIn(month).clear(), throwsUnsupportedError);
      expect(CairoTime.date(ledger.invoice('1').dueOn), '2026-10-01');
    },
  );
  test(
    'duplicate, missing, partial/double reversal and overpayment snapshots are rejected',
    () {
      void bad(List<FinanceInvoice> invoices, List<FinanceMovement> rows) =>
          expect(
            () => FinanceLedger(invoices: invoices, movements: rows),
            throwsFormatException,
          );
      final i = invoice('a'), p = movement('p', 'a');
      bad([i, i], []);
      bad([i], [p, p]);
      bad([i], [movement('p', 'missing')]);
      bad([i], [movement('r', 'a', reversal: 'missing')]);
      bad([i], [p, movement('r', 'a', reversal: 'p', amount: 1)]);
      bad(
        [i],
        [
          p,
          movement('r', 'a', reversal: 'p'),
          movement('r2', 'a', reversal: 'p'),
        ],
      );
      bad([i], [movement('p', 'a', amount: 10001)]);
      bad([i, invoice('b')], [p, movement('r', 'b', reversal: 'p')]);
      bad([i], [p, movement('r', 'a', reversal: 'p', method: 'transfer')]);
    },
  );
}
