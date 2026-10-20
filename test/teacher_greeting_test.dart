import 'package:centrally/core/widgets/app_header.dart';
import 'package:centrally/core/config/preview_mode.dart';
import 'package:centrally/screens/teacher/widgets/teacher_greeting.dart';
import 'package:centrally/screens/teacher/widgets/workspace_actions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    for (final morning in [true, false]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '$locale greeting noon boundary at scale $scale morning=$morning',
          (tester) async {
            final key = await pumpSessionDesign(
              tester,
              () => Scaffold(
                appBar: AppHeader(
                  title: '',
                  toolbarHeight: 80 + 32 * (scale - 1),
                  avatar: const CircleAvatar(radius: 24),
                  titleContent: TeacherGreeting(
                    now: DateTime.utc(
                      2026,
                      10,
                      20,
                      morning ? 8 : 9,
                      morning ? 59 : 0,
                    ),
                  ),
                  actions: const [WorkspaceActions()],
                ),
              ),
              locale: locale,
              scale: scale,
              width: scale == 1 ? 390 : 320,
            );
            final name =
                (PreviewMode.enabled
                        ? 'home_preview_teacher_name'
                        : 'home_teacher_name_fallback')
                    .tr();
            expect(
              find.text(
                (morning ? 'home_greeting_morning' : 'home_greeting_evening')
                    .tr(args: [name]),
              ),
              findsOneWidget,
            );
            expect(
              find.byTooltip('completion_notifications'.tr()),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
            if (locale == 'ar' && morning && scale == 1) {
              await captureSessionDesign(tester, key, 'home-greeting');
            }
          },
        );
      }
    }
  }
}
