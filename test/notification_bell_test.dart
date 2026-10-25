import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/features/notifications/presentation/notification_bell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final initial in [0, 5, 120]) {
    testWidgets(
      'bell shows server unread count $initial and refreshes to zero',
      (tester) async {
        var count = initial;
        final client = (await tester.runAsync(
          () async => readFixture(
            (request) async => jsonResponse(request, {'unread_count': count}),
          ),
        ))!;
        getIt.registerSingleton<TeacherReadClient>(TeacherReadClient(client));
        addTearDown(
          () => tester.runAsync(() async {
            await getIt.reset();
            await client.dispose();
          }),
        );
        await tester.runAsync(
          () async => tester.pumpWidget(
            EasyLocalization(
              supportedLocales: const [Locale('ar'), Locale('en')],
              startLocale: const Locale('ar'),
              path: 'assets/translations',
              saveLocale: false,
              child: const LocalizedTestApp(
                home: Scaffold(body: NotificationBell()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.isLabelVisible, initial > 0);
        expect(badge.backgroundColor, ColorManager.error);
        if (initial > 0) {
          expect(find.text(initial > 99 ? '99+' : '$initial'), findsOneWidget);
        }
        count = 0;
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
        badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.isLabelVisible, false);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
