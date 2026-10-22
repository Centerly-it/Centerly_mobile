import 'package:centrally/core/widgets/app_empty_state.dart';
import 'package:centrally/features/finances/presentation/live_movement_filter_chips.dart';
import 'package:centrally/core/widgets/app_error_state.dart';
import 'package:centrally/app/bootstrap_preview.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:centrally/features/groups/presentation/live_group_detail.dart';
import 'package:centrally/features/groups/presentation/live_group_card.dart';
import 'package:centrally/features/finances/presentation/design/finance_invoice_card.dart';
import 'package:centrally/features/finances/presentation/live_invoice_detail.dart';
import 'package:centrally/features/finances/presentation/live_finance_dues.dart';
import 'package:centrally/features/finances/presentation/live_finance_movements.dart';
import 'package:centrally/features/students/presentation/design/student_directory_row.dart';
import 'package:centrally/features/students/presentation/student_profile_page.dart';
import 'package:centrally/features/students/presentation/design/student_profile_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';

// Connected widgets with an explicit synthetic transport; not hosted evidence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('connected design routes $locale at narrow 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<AppConfig>(
        const AppConfig(url: '', publishableKey: ''),
      );
      await tester.runAsync(bootstrapPreview);
      addTearDown(() => getIt.reset());
      final boundary = GlobalKey();
      await tester.runAsync(
        () async => tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            path: 'assets/translations',
            startLocale: Locale(locale),
            saveLocale: false,
            child: LocalizedTestApp(
              scale: 2,
              home: RepaintBoundary(
                key: boundary,
                child: const TeacherWorkspace(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(find.text('error_title'.tr()), findsNothing);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_CONNECTED')) {
        await tester.runAsync(
          () => captureWidget(boundary, 'build/connected-finance-$locale.png'),
        );
      }
      await tester.tap(find.text('finance_tab_dues'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(LiveFinanceDues), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(FinanceInvoiceCard),
        180,
        scrollable: find
            .descendant(
              of: find.byType(LiveFinanceDues),
              matching: find.byType(Scrollable),
            )
            .last,
      );
      final invoiceTitle = find
          .descendant(
            of: find.byType(FinanceInvoiceCard),
            matching: find.byType(Text),
          )
          .first;
      final element = tester.element(invoiceTitle);
      await Scrollable.of(
        element,
      ).position.ensureVisible(element.findRenderObject()!, alignment: .3);
      await tester.pumpAndSettle();
      await tester.tap(invoiceTitle);
      await tester.pumpAndSettle();
      expect(find.byType(LiveInvoiceDetail), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byTooltip(
          MaterialLocalizations.of(
            tester.element(find.byType(AppBar).first),
          ).backButtonTooltip,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('finance_tab_movements'.tr()));
      await tester.tap(find.text('finance_tab_movements'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(LiveFinanceMovements), findsOneWidget);
      expect(find.byType(AppErrorState), findsNothing);
      tester
          .widget<LiveMovementFilterChips>(find.byType(LiveMovementFilterChips))
          .onKind('corrections');
      await tester.pumpAndSettle();
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.byType(AppErrorState), findsNothing);
      tester
          .widget<LiveMovementFilterChips>(find.byType(LiveMovementFilterChips))
          .onKind(null);
      await tester.pumpAndSettle();
      expect(find.byType(AppEmptyState), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.groups_2_outlined));
      await tester.pumpAndSettle();
      final card = tester.widget<LiveGroupCard>(
        find.byType(LiveGroupCard).first,
      );
      await tester.tap(find.text(card.group.name).first);
      await tester.pumpAndSettle();
      expect(find.byType(LiveGroupDetail), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byTooltip(
          MaterialLocalizations.of(
            tester.element(find.byType(AppBar).first),
          ).backButtonTooltip,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(StudentDirectoryRow).first);
      await tester.pumpAndSettle();
      expect(find.byType(StudentProfilePage), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final tab in [1, 2, 3, 0]) {
        tester
            .widget<StudentProfileTabs>(find.byType(StudentProfileTabs))
            .onChanged(tab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
