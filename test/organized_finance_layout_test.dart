import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:centrally/features/finances/presentation/live_invoice_summary.dart';
import 'package:centrally/features/finances/presentation/live_receipt_card.dart';
import 'package:centrally/features/finances/presentation/finance_amount_summary.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';
import 'helpers/receipt_alignment.dart';
import 'helpers/finance_review_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final c in [
    ('ar', 390.0, 1.0),
    ('ar', 320.0, 2.0),
    ('en', 320.0, 2.0),
    ('en', 800.0, 1.0),
  ]) {
    testWidgets('organized invoice ${c.$1} ${c.$2} at ${c.$3} scale', (
      tester,
    ) async {
      tester.view.physicalSize = Size(c.$2, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final invoice = financeReviewInvoice();
      final receipt = financeReviewReceipt(invoice);
      final boundary = GlobalKey();
      await tester.runAsync(
        () async => tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            path: 'assets/translations',
            assetLoader: const CodegenLoader(),
            startLocale: Locale(c.$1),
            saveLocale: false,
            child: LocalizedTestApp(
              scale: c.$3,
              home: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        LiveInvoiceSummary(invoice: invoice),
                        const SizedBox(height: 16),
                        LiveReceiptCard(row: receipt),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expectReceiptAlignment(tester, c.$1);
      final summary = tester.widget<FinanceAmountSummary>(
        find.byType(FinanceAmountSummary),
      );
      expect(summary.amount, BigInt.from(70050));
      expect(summary.paid, BigInt.from(30025));
      expect(summary.outstanding, BigInt.from(40025));
      expect(find.text('ui_due_date'), findsNothing);
      if (c.$1 == 'ar' && c.$3 == 1) {
        await tester.runAsync(
          () => captureWidget(boundary, 'build/ui-review/invoice-ar.png'),
        );
      }
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('سكرتير التحصيل الأصلي'), findsOneWidget);
      expect(find.text('سكرتير التصحيح'), findsOneWidget);
    });
  }
}
