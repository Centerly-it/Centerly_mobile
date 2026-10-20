import 'package:centrally/core/format/money_egp.dart';
import 'package:centrally/features/finances/domain/finance_plan.dart';
import 'package:centrally/features/finances/preview/finance_preview_fixture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final month = DateTime(2026, 10), now = DateTime.utc(2026, 10, 20, 18);
  final ledger = FinancePreviewFixture.build(month, now);
  BigInt cents(int pounds) => BigInt.from(pounds * 100);
  test('invoice cohort reconciles independently of receipt month', () {
    expect(ledger.invoiced(month), cents(18000));
    expect(ledger.paidAgainst(month), cents(11400));
    expect(ledger.outstanding(month), cents(6600));
    expect(
      ledger.invoiced(month),
      ledger.paidAgainst(month) + ledger.outstanding(month),
    );
    expect(ledger.gross(month), cents(17900));
    expect(ledger.corrections(month), cents(5000));
    expect(ledger.net(month), cents(12900));
    expect(ledger.gross(month) - ledger.corrections(month), ledger.net(month));
  });
  test('correction actor differs from original collector, sums reconcile', () {
    final correction = ledger.movements.singleWhere((m) => m.id == 'R1004');
    final original = ledger.movements.singleWhere(
      (m) => m.id == correction.reversalOf,
    );
    expect(correction.actor, 'nour');
    expect(original.actor, 'sara');
    expect(correction.amount, original.amount);
    expect(ledger.net(month, actor: 'sara'), cents(8300));
    expect(ledger.net(month, actor: 'nour'), cents(4600));
    expect(
      ledger.net(month, actor: 'sara') + ledger.net(month, actor: 'nour'),
      ledger.net(month),
    );
    expect(ledger.invoice('4527').createdBy, 'nour');
  });
  test('due today is not overdue, later dues remain visible', () {
    expect(ledger.lateAmount(month, now), cents(3000));
    expect(ledger.overdue(ledger.invoice('4529'), now), false);
    expect(ledger.remaining(ledger.invoice('4529')), cents(1000));
  });
  test(
    'all preview dates keep reversal references valid and balances exact',
    () {
      for (var day = 1; day <= 31; day++) {
        final instant = DateTime.utc(2026, 10, day, 18);
        final snapshot = FinancePreviewFixture.build(month, instant);
        expect(snapshot.movements.every((m) => !m.at.isAfter(instant)), true);
        for (final m in snapshot.movements.where((m) => m.reversed)) {
          final original = snapshot.movements.singleWhere(
            (o) => o.id == m.reversalOf,
          );
          expect(m.invoiceId, original.invoiceId);
          expect(m.amount, original.amount);
        }
        for (final invoice in snapshot.invoices) {
          expect(snapshot.remaining(invoice) >= BigInt.zero, true);
        }
      }
    },
  );
  test('planning is exact, rounded up daily, bounded and period aware', () {
    FinancePlan plan(DateTime date, {int percent = 50, int target = 20000}) =>
        FinancePlan(
          month: date,
          now: now,
          net: cents(12900),
          remaining: cents(6600),
          target: cents(target),
          percent: percent,
        );
    expect(plan(month).possibleAddition, cents(3300));
    expect(plan(month).gap, cents(7100));
    expect(plan(month).beyondCurrentDues, cents(500));
    expect(plan(month).days, 12);
    expect(plan(month).perDay, cents(592));
    expect(plan(DateTime(2026, 9)).perDay, isNull);
    expect(plan(DateTime(2026, 11)).days, 30);
    expect(plan(month, target: 12000).gap, BigInt.zero);
    expect(plan(month, percent: 200).possibleAddition, cents(6600));
  });
  test(
    'minor-unit formatting round trips negative, cents and large amounts',
    () {
      for (final value in [
        BigInt.zero,
        BigInt.one,
        BigInt.from(-1),
        BigInt.from(99999),
        BigInt.parse('99999999999999'),
      ]) {
        expect(
          MoneyEgp.parse(MoneyEgp.fromMinorUnits(value).decimal).minorUnits,
          value,
        );
      }
    },
  );
}
