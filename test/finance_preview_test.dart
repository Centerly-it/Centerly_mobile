import 'package:centrally/features/finances/preview/finance_preview.dart';
import 'package:centrally/features/finances/preview/finance_dues_list.dart';
import 'package:centrally/features/finances/preview/finance_movements_list.dart';
import 'package:centrally/features/finances/preview/finance_invoice_detail.dart';
import 'package:centrally/features/finances/preview/finance_movement_detail.dart';
import 'package:centrally/features/finances/preview/finance_calculator.dart';
import 'package:centrally/features/finances/preview/finance_preview_fixture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 20, 18), month = DateTime(2026, 10);
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    for (final screen in [
      'overview',
      'dues',
      'invoice',
      'correction',
      'movements',
      'calculator',
    ]) {
      testWidgets('finance $screen $locale renders with complete local data', (
        tester,
      ) async {
        final ledger = FinancePreviewFixture.build(month, now);
        final key = await pumpSessionDesign(
          tester,
          () => switch (screen) {
            'dues' => Scaffold(
              body: FinanceDuesList(
                ledger: ledger,
                month: month,
                now: now,
                initialStatus: 'all',
                onInvoice: (_) {},
              ),
            ),
            'invoice' => FinanceInvoiceDetail(
              ledger: ledger,
              invoice: ledger.invoice('4527'),
            ),
            'correction' => Scaffold(
              body: FinanceMovementDetail(
                ledger: ledger,
                movement: ledger.movements.singleWhere((m) => m.id == 'R1004'),
              ),
            ),
            'movements' => Scaffold(
              body: FinanceMovementsList(
                ledger: ledger,
                month: month,
                onMovement: (_) {},
              ),
            ),
            'calculator' => FinanceCalculator(
              ledger: ledger,
              month: month,
              now: now,
            ),
            _ => Scaffold(body: FinancePreview(now: now)),
          },
          locale: locale,
        );
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_FINANCE')) {
          await tester.runAsync(
            () => captureWidget(
              key,
              'docs/screenshots/finance/$screen-$locale.png',
            ),
          );
        }
      });
    }
    testWidgets('finance narrow large text $locale overview and filters', (
      tester,
    ) async {
      await pumpSessionDesign(
        tester,
        () => Scaffold(body: FinancePreview(now: now)),
        locale: locale,
        width: 320,
        scale: 2,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(locale == 'ar' ? 'المستحقات' : 'Dues'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
