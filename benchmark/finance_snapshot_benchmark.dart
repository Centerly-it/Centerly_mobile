import 'dart:io';
import 'dart:convert';
import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/features/finances/domain/finance_entry.dart';
import 'package:centrally/features/finances/domain/finance_ledger.dart';

void main() {
  CairoTime.local(DateTime.utc(2026));
  final invoices = [
    for (var n = 0; n < 1000; n++)
      FinanceInvoice(
        id: '$n',
        studentKey: 'student',
        groupKey: 'group',
        amount: BigInt.from(100000),
        dueOn: DateTime(2026, 10),
      ),
  ];
  final rows = [
    for (var n = 0; n < 1000; n++)
      for (var p = 0; p < 20; p++)
        FinanceMovement(
          id: '$n-$p',
          invoiceId: '$n',
          amount: BigInt.from(101),
          actor: 'actor',
          at: DateTime.utc(2026, 10, 10),
          method: 'cash',
        ),
  ];
  BigInt reference() => invoices.fold(
    BigInt.zero,
    (sum, i) =>
        sum +
        i.amount -
        rows
            .where((r) => r.invoiceId == i.id)
            .fold(BigInt.zero, (paid, r) => paid + r.signedAmount),
  );
  final before = <int>[], after = <int>[];
  BigInt? expected;
  for (var n = 0; n < 3; n++) {
    final watch = Stopwatch()..start();
    expected = reference();
    before.add(watch.elapsedMicroseconds);
    watch.reset();
    final ledger = FinanceLedger(invoices: invoices, movements: rows);
    final actual = ledger.outstanding(DateTime(2026, 10));
    after.add(watch.elapsedMicroseconds);
    if (actual != expected) throw StateError('Financial checksum mismatch');
    watch.stop();
  }
  before.sort();
  after.sort();
  stdout.writeln(
    jsonEncode({
      'invoices': invoices.length,
      'movements': rows.length,
      'naive_median_us': before[1],
      'indexed_build_and_sum_median_us': after[1],
      'exact_outstanding_minor_units': expected.toString(),
      'scope':
          'local Dart JIT; hardware-specific timing, no device performance claim',
    }),
  );
}
