import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/groups/data/group_repository.dart';
import 'package:centrally/features/groups/presentation/live_groups.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/group_read_fixture.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets(
      'live groups search, grade filter and empty state $locale at 200%',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <Map>[];
        final client = (await tester.runAsync(
          () async => readFixture((request) async {
            final params = jsonDecode(request.body) as Map;
            requests.add(params);
            return jsonResponse(
              request,
              params['p_search'] == 'missing' ? [] : [groupJson('one')],
            );
          }),
        ))!;
        getIt.registerSingleton<GroupRepository>(
          GroupRepository(TeacherReadClient(client)),
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
              supportedLocales: const [Locale('ar'), Locale('en')],
              startLocale: Locale(locale),
              saveLocale: false,
              path: 'assets/translations',
              child: const LocalizedTestApp(
                home: Scaffold(body: LiveGroups()),
                scale: 2,
              ),
            ),
          );
        });
        await tester.pumpAndSettle();
        expect(find.text('مجموعة one'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(ActionChip));
        await tester.tap(find.byType(ActionChip));
        await tester.pumpAndSettle();
        expect(requests.last['p_grade_level_id'], 'grade');
        await tester.tap(find.byIcon(Icons.filter_alt_off_outlined));
        await tester.pumpAndSettle();
        expect(requests.last['p_grade_level_id'], isNull);
        await tester.enterText(find.byType(TextField), 'missing');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(find.text('groups_empty_title'.tr()), findsOneWidget);
        expect(requests.last.containsKey('teacher_id'), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
