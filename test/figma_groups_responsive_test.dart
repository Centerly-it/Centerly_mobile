import 'package:centrally/features/groups/preview/figma_groups_preview.dart';
import 'package:centrally/features/groups/preview/group_design_detail.dart';
import 'package:centrally/features/groups/preview/group_note_editor.dart';
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
  for (final locale in ['ar', 'en']) {
    for (final page in ['list', 'detail', 'note']) {
      testWidgets('groups $page $locale at 320px and 200% text', (
        tester,
      ) async {
        await pumpSessionDesign(
          tester,
          () => switch (page) {
            'list' => const Scaffold(body: FigmaGroupsPreview()),
            'detail' => GroupDesignDetail(
              data: GroupPreviewData.fixtures().first,
            ),
            _ => const GroupNoteEditor(),
          },
          locale: locale,
          width: 320,
          scale: 2,
        );
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
