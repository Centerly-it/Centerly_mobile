import '../../../core/format/cairo_time.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';

class FinancePreviewFixture {
  static FinanceLedger build(DateTime month, DateTime now) {
    final amounts = [
      3000,
      2500,
      2000,
      3500,
      1800,
      2200,
      1600,
      1400,
      2000,
      1500,
    ];
    final days = [5, 10, 12, 20, 25, 14, 28, 8, 5, 5];
    final invoices = [
      for (var i = 0; i < 10; i++)
        FinanceInvoice(
          id: '${4526 + i}',
          studentKey: 'finance_demo_student_${i + 1}',
          groupKey: 'student_design_group_${i.isEven ? 'a' : 'b'}',
          amount: BigInt.from(amounts[i] * 100),
          createdBy: i.isEven ? 'sara' : 'nour',
          dueOn: DateTime(
            month.year,
            month.month +
                (i == 8
                    ? -1
                    : i == 9
                    ? 1
                    : 0),
            days[i],
          ),
        ),
    ];
    final rows = <FinanceMovement>[];
    void receipt(
      int invoice,
      int amount,
      int day,
      String actor,
      String method, {
      int monthOffset = 0,
      String? reversalOf,
    }) {
      final wall = DateTime.utc(month.year, month.month + monthOffset, day, 12);
      final offset = CairoTime.local(wall).timeZoneOffset;
      final at = wall.subtract(offset);
      if (at.isAfter(now)) return;
      rows.add(
        FinanceMovement(
          id: 'R${1001 + rows.length}',
          invoiceId: invoices[invoice].id,
          amount: BigInt.from(amount * 100),
          actor: actor,
          method: method,
          at: at,
          reversalOf: reversalOf,
          reasonKey: reversalOf == null
              ? null
              : 'finance_demo_correction_reason',
        ),
      );
    }

    receipt(0, 2000, 2, 'sara', 'cash');
    receipt(0, 1000, 6, 'nour', 'transfer');
    receipt(1, 2000, 8, 'sara', 'cash');
    receipt(1, 2000, 9, 'nour', 'cash', reversalOf: 'R1003');
    receipt(1, 1500, 9, 'nour', 'cash');
    receipt(3, 3000, 10, 'sara', 'transfer');
    receipt(3, 3000, 11, 'sara', 'transfer', reversalOf: 'R1006');
    receipt(3, 2500, 11, 'sara', 'transfer');
    receipt(5, 2200, 12, 'nour', 'cash');
    receipt(6, 800, 15, 'sara', 'cash');
    receipt(7, 1400, 16, 'nour', 'transfer');
    receipt(8, 1000, 3, 'sara', 'cash');
    receipt(8, 1000, 28, 'nour', 'cash', monthOffset: -1);
    receipt(9, 500, 19, 'nour', 'other');
    return FinanceLedger(invoices: invoices, movements: rows);
  }
}
