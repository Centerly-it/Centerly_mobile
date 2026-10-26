// Native plugins + current connected widgets with explicitly synthetic transport.
// This does not replace password-based hosted owner acceptance.
import 'package:centrally/app/bootstrap_preview.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/finances/presentation/live_finance.dart';
import 'package:centrally/features/finances/presentation/live_finance_dues.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('synthetic Android profile finance navigation and scrolling', (
    tester,
  ) async {
    const storage = FlutterSecureStorage();
    const key = 'centerly_owner_native_smoke_20261022';
    try {
      await storage.write(key: key, value: 'synthetic-smoke-value');
      expect(await storage.read(key: key), 'synthetic-smoke-value');
      await storage.delete(key: key);
      expect(await storage.read(key: key), isNull);
      await canLaunchUrl(Uri(scheme: 'tel', path: '+201000000000'));
      await EasyLocalization.ensureInitialized();
      getIt.registerSingleton<AppConfig>(
        const AppConfig(url: '', publishableKey: ''),
      );
      await bootstrapPreview();
      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            startLocale: const Locale('ar'),
            saveLocale: false,
            path: 'assets/translations',
            child: const _App(),
          ),
        );
      });
      await tester.pumpAndSettle();
      expect(find.text('error_title'.tr()), findsNothing);
      await tester.tap(find.text('finance_tab_dues'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(LiveFinanceDues), findsOneWidget);
      expect(tester.takeException(), isNull);
      await binding.watchPerformance(() async {
        for (var i = 0; i < 5; i++) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -300));
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView).first, const Offset(0, 300));
          await tester.pumpAndSettle();
        }
      }, reportKey: 'synthetic_finance_scroll');
    } finally {
      await storage.delete(key: key);
      await getIt.reset();
    }
  }, timeout: const Timeout(Duration(seconds: 90)));
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const Scaffold(body: SafeArea(child: LiveFinance())),
  );
}
