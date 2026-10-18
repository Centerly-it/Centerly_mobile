import 'package:centrally/core/theme/theme_manager.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_home_screen.dart';
import 'package:centrally/screens/teacher/teacher_groups_screen.dart';
import 'package:centrally/screens/teacher/teacher_sessions_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:centrally/screens/main_shell_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('teacher navigation works in ${locale.languageCode}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          startLocale: locale,
          saveLocale: false,
          child: const _TestApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TeacherHomeScreen).hitTestable(), findsOneWidget);
      await tester.tap(find.byIcon(Icons.groups_2_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherGroupsScreen).hitTestable(), findsOneWidget);
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherSessionsScreen).hitTestable(), findsOneWidget);
    });
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const MainShellView(role: UserRole.teacher),
  );
}
