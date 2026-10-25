import 'dart:ui' as ui;
import 'package:centrally/features/groups/domain/group_record.dart';
import 'package:centrally/features/groups/presentation/live_group_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/group_read_fixture.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';

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
  ]) {
    testWidgets('refreshed group ${c.$1} ${c.$2} text ${c.$3}', (tester) async {
      tester.view.physicalSize = Size(c.$2, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final data = groupJson('one');
      data['name'] = 'ثالثة ثانوي (ب)';
      data['subject_name'] = 'فيزياء';
      data['students_count'] = 23;
      final base = Map<String, dynamic>.from((data['schedules'] as List).first);
      data['schedules'] = [
        for (final d in [6, 2])
          {
            ...base,
            'weekday': d,
            'local_start_time': '15:00:00',
            'local_end_time': '16:00:00',
          },
      ];
      final group = GroupRecord.fromJson(data), boundary = GlobalKey();
      await tester.runAsync(
        () async => tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            path: 'assets/translations',
            startLocale: Locale(c.$1),
            saveLocale: false,
            child: LocalizedTestApp(
              scale: c.$3,
              home: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                  body: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [LiveGroupCard(group: group, onGrade: () {})],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(group.name), findsOneWidget);
      expect(find.text('group_design_count'.tr(args: ['23'])), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      if (c.$1 == 'ar') {
        expect(
          tester.widget<Icon>(find.byIcon(Icons.chevron_left)).textDirection,
          ui.TextDirection.ltr,
        );
      }
      if (c.$3 == 1) {
        await tester.runAsync(
          () => captureWidget(boundary, 'build/ui-review/group-card-ar.png'),
        );
      }
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
