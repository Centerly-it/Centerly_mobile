import 'package:centrally/features/finances/preview/finance_preview.dart';
import 'package:centrally/features/finances/preview/finance_calculator.dart';
import 'package:centrally/features/finances/preview/finance_preview_fixture.dart';
import 'package:centrally/features/finances/presentation/design/finance_invoice_card.dart';
import 'package:centrally/features/finances/presentation/design/finance_movement_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 20, 18), month = DateTime(2026, 10);
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  testWidgets('overdue drilldown, invoice and history navigation', (
    tester,
  ) async {
    await pumpSessionDesign(
      tester,
      () => Scaffold(body: FinancePreview(now: now)),
    );
    await tester.tap(find.text('finance_overdue'.tr()));
    await tester.pumpAndSettle();
    expect(find.byType(FinanceInvoiceCard), findsNWidgets(2));
    await tester.tap(find.byType(FinanceInvoiceCard).first);
    await tester.pumpAndSettle();
    expect(find.text('finance_invoice_movements'.tr()), findsOneWidget);
    expect(find.byType(FinanceMovementCard), findsNWidgets(3));
    await tester.tap(find.byType(FinanceMovementCard).first);
    await tester.pumpAndSettle();
    expect(find.text('finance_receipt'.tr()), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'money activity filters corrections and opens original attribution',
    (tester) async {
      await pumpSessionDesign(
        tester,
        () => Scaffold(body: FinancePreview(now: now)),
      );
      await tester.ensureVisible(find.text('finance_tab_movements'.tr()));
      await tester.tap(find.text('finance_tab_movements'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('finance_kind_corrections'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceMovementCard), findsNWidgets(2));
      await tester.tap(find.byType(FinanceMovementCard).first);
      await tester.pumpAndSettle();
      expect(find.text('finance_original_movement'.tr()), findsOneWidget);
      expect(find.text('finance_original_actor'.tr()), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'search missing invoice shows shared empty state without mutations',
    (tester) async {
      await pumpSessionDesign(
        tester,
        () => Scaffold(body: FinancePreview(now: now)),
      );
      await tester.tap(find.text('finance_tab_dues'.tr()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'no such student');
      await tester.pumpAndSettle();
      expect(find.byType(FinanceInvoiceCard), findsNothing);
      expect(find.text('finance_no_dues'.tr()), findsOneWidget);
    },
  );
  testWidgets(
    'target calculator updates independently and validates empty input',
    (tester) async {
      await pumpSessionDesign(
        tester,
        () => FinanceCalculator(
          ledger: FinancePreviewFixture.build(month, now),
          month: month,
          now: now,
        ),
      );
      await tester.enterText(find.byType(TextField), '١٢٠٠٠');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12000',
      );
      expect(find.textContaining('0 جـ'), findsWidgets);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('finance_target_required'.tr()), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final locale in ['ar', 'en']) {
    testWidgets(
      'lower overview and money filters at 320px 200 percent $locale',
      (tester) async {
        final key = await pumpSessionDesign(
          tester,
          () => Scaffold(body: FinancePreview(now: now)),
          locale: locale,
          width: 320,
          scale: 2,
        );
        await tester.drag(find.byType(ListView).first, const Offset(0, -1300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_FINANCE')) {
          await tester.runAsync(
            () => captureWidget(
              key,
              'docs/screenshots/finance/overview-lower-large-$locale.png',
            ),
          );
        }
        await tester.ensureVisible(find.text('finance_tab_movements'.tr()));
        await tester.tap(find.text('finance_tab_movements'.tr()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(DropdownButton<String>).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
