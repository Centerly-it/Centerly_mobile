import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:centrally/features/students/presentation/student_directory.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/student_read_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  testWidgets(
    'Arabic group directory is read only at 200% text and searches on server',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final client = (await tester.runAsync(
        () async => readFixture((request) async {
          final params = jsonDecode(request.body) as Map;
          expect(params['p_group_id'], 'group');
          return jsonResponse(
            request,
            params['p_search'] == 'missing' ? [] : [studentJson('one')],
          );
        }),
      ))!;
      getIt.registerSingleton<StudentRepository>(
        StudentRepository(TeacherReadClient(client)),
      );
      addTearDown(
        () => tester.runAsync(() async {
          await getIt.reset();
          await client.dispose();
        }),
      );
      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar')],
            startLocale: const Locale('ar'),
            saveLocale: false,
            path: 'assets/translations',
            child: const LocalizedTestApp(
              home: StudentDirectory(groupId: 'group', groupName: 'مجموعة'),
              scale: 2,
            ),
          ),
        );
      });
      await tester.pumpAndSettle();
      expect(find.text('طالب تجريبي one'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'missing');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('live_no_students'.tr()), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
