import 'package:centrally/features/groups/preview/group_design_detail.dart';
import 'package:centrally/features/groups/preview/group_preview_data.dart';
import 'package:centrally/features/groups/presentation/design/group_section.dart';
import 'package:centrally/features/groups/presentation/design/group_student_rows.dart';
import 'package:centrally/features/groups/presentation/design/group_upcoming_rows.dart';
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
  for (final section in ['upcoming', 'notes', 'students']) {
    testWidgets('group view-all $section opens its complete local list', (
      tester,
    ) async {
      final data = GroupPreviewData.fixtures().first;
      data.notes.addAll([
        GroupPreviewNote('first note', DateTime(2026, 3, 24)),
        GroupPreviewNote('older note', DateTime(2026, 3, 23)),
      ]);
      await pumpSessionDesign(tester, () => GroupDesignDetail(data: data));
      final button = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is GroupSection && w.title == 'group_design_$section',
        ),
        matching: find.byType(TextButton),
      );
      await tester.scrollUntilVisible(button, 200);
      await tester.tap(button);
      await tester.pumpAndSettle();
      switch (section) {
        case 'upcoming':
          expect(
            tester
                .widget<GroupUpcomingRows>(find.byType(GroupUpcomingRows))
                .count,
            6,
          );
        case 'students':
          expect(
            tester
                .widget<GroupStudentRows>(find.byType(GroupStudentRows))
                .count,
            data.students,
          );
        case 'notes':
          expect(find.text('first note'), findsOneWidget);
          expect(find.text('older note'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
