import 'package:centrally/features/groups/preview/figma_groups_preview.dart';
import 'package:centrally/features/groups/preview/group_design_detail.dart';
import 'package:centrally/features/groups/preview/group_note_editor.dart';
import 'package:centrally/features/groups/preview/group_preview_data.dart';
import 'package:centrally/features/groups/presentation/design/group_design_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';
import 'helpers/verify_group_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    for (final state in ['list', 'empty', 'detail', 'note', 'saved']) {
      testWidgets('group $state $locale design and layout', (tester) async {
        final key = await pumpSessionDesign(
          tester,
          () {
            final data = GroupPreviewData.fixtures().first;
            if (state == 'saved') {
              data.notes.add(
                GroupPreviewNote(
                  'group_design_sample_note'.tr(),
                  DateTime(2026, 3, 24),
                ),
              );
            }
            return switch (state) {
              'list' => const Scaffold(body: FigmaGroupsPreview()),
              'empty' => const Scaffold(body: FigmaGroupsPreview(groups: [])),
              'note' => const GroupNoteEditor(),
              _ => GroupDesignDetail(data: data),
            };
          },
          locale: locale,
          height: 1048,
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/figma/groups/3dd9c.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        verifyGroupAssets(tester);
        if (const bool.fromEnvironment('CAPTURE_GROUP_DESIGN')) {
          await tester.runAsync(
            () => captureWidget(
              key,
              'docs/screenshots/figma-groups/$state-$locale.png',
            ),
          );
        }
        if (state == 'list') {
          await tester.enterText(find.byType(TextField), 'no such group');
          await tester.pumpAndSettle();
          expect(find.byType(GroupDesignCard), findsNothing);
          expect(find.text('group_design_search_empty'.tr()), findsOneWidget);
          await tester.enterText(
            find.byType(TextField),
            'group_design_student'.tr(),
          );
          await tester.pumpAndSettle();
          expect(find.byType(GroupDesignCard), findsWidgets);
          await tester.tap(find.byType(GroupDesignCard).first);
          await tester.pumpAndSettle();
          expect(find.byType(GroupDesignDetail), findsOneWidget);
        }
      });
    }
  }
}
