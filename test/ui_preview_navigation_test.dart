import 'package:centrally/app/bootstrap_preview.dart';
import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:centrally/screens/teacher/workspace_selection.dart';
import 'package:centrally/features/dashboard/presentation/dashboard_unpaid_card.dart';
import 'package:centrally/core/config/preview_mode.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/screens/teacher/widgets/teacher_greeting.dart';
import 'package:centrally/screens/teacher/widgets/workspace_app_bar.dart';
import 'package:centrally/screens/teacher/widgets/workspace_actions.dart';
import 'package:centrally/features/students/presentation/student_directory.dart';
import 'package:centrally/features/students/preview/figma_students_preview.dart';
import 'package:centrally/features/notifications/presentation/teacher_notifications_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:centrally/features/finances/presentation/design/finance_invoice_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(WorkspaceSelection.startAppSession);
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('offline preview main tabs render in $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<AppConfig>(
        const AppConfig(url: '', publishableKey: ''),
      );
      await tester.runAsync(bootstrapPreview);
      addTearDown(() => getIt.reset());
      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            startLocale: Locale(locale),
            saveLocale: false,
            path: 'assets/translations',
            assetLoader: const CodegenLoader(),
            child: const LocalizedTestApp(home: TeacherWorkspace()),
          ),
        );
      });
      await tester.pumpAndSettle();
      expect(find.text('72'), findsOneWidget);
      final headerHeight = tester
          .widget<AppBar>(find.byType(AppBar))
          .toolbarHeight;
      final navigation = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigation.destinations.length, 5);
      expect(navigation.indicatorColor, Colors.transparent);
      final navStyle = NavigationBarTheme.of(
        tester.element(find.byType(NavigationBar)),
      );
      expect(
        navStyle.labelTextStyle!.resolve({WidgetState.selected})!.color,
        ColorManager.primary,
      );
      for (final destination
          in navigation.destinations.cast<NavigationDestination>()) {
        expect((destination.selectedIcon as Icon).color, ColorManager.primary);
      }
      expect(
        find.widgetWithText(NavigationDestination, 'live_students'.tr()),
        findsOneWidget,
      );
      if (PreviewMode.enabled) {
        await tester.scrollUntilVisible(find.textContaining('18,000'), 250);
        expect(find.textContaining('18,000'), findsOneWidget);
        await tester.scrollUntilVisible(find.byType(DashboardUnpaidCard), 400);
        await tester.tap(find.text('home_unpaid_view'.tr()));
        await tester.pumpAndSettle();
        expect(find.byType(FinanceInvoiceCard), findsWidgets);
        Navigator.of(
          tester.element(find.text('home_unpaid_month'.tr()).first),
        ).pop();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      for (final icon in [
        Icons.calendar_month_outlined,
        Icons.groups_2_outlined,
        Icons.account_balance_wallet_outlined,
        Icons.school_outlined,
      ]) {
        await tester.tap(find.byIcon(icon).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('error_title'.tr()), findsNothing);
        expect(find.byType(TeacherGreeting), findsOneWidget);
        expect(find.byType(WorkspaceActions), findsOneWidget);
        expect(
          tester
              .widget<AppBar>(
                find.descendant(
                  of: find.byType(WorkspaceAppBar),
                  matching: find.byType(AppBar),
                ),
              )
              .toolbarHeight,
          headerHeight,
        );
        expect(find.byTooltip('completion_notifications'.tr()), findsOneWidget);
        for (final text in tester.widgetList<Text>(find.byType(Text))) {
          expect(text.data?.startsWith('dashboard_') ?? false, isFalse);
        }
      }
      expect(
        find.byType(
          PreviewMode.enabled ? FigmaStudentsPreview : StudentDirectory,
        ),
        findsOneWidget,
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        3,
      );
      await tester.tap(find.byTooltip('completion_notifications'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherNotificationsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
