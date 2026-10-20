import 'package:centrally/features/groups/preview/group_design_detail.dart';
import 'package:centrally/features/groups/preview/group_preview_data.dart';
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
  testWidgets(
    'group note validates and stays on its own group after navigation',
    (tester) async {
      final groups = GroupPreviewData.fixtures();
      await pumpSessionDesign(
        tester,
        () => GroupDesignDetail(data: groups.first),
      );
      await tester.tap(find.text('group_design_add_note'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('group_design_save_note'.tr()));
      await tester.pumpAndSettle();
      expect(find.text('group_design_note_required'.tr()), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  local note  ');
      await tester.tap(find.text('group_design_save_note'.tr()));
      await tester.pumpAndSettle();
      expect(groups.first.notes.single.text, 'local note');
      expect(groups[1].notes, isEmpty);
      expect(find.text('local note'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
