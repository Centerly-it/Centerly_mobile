import 'package:centrally/features/finances/presentation/live_movement_filter_chips.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('movement menu selects and clears method in $locale', (
      tester,
    ) async {
      String? method;
      final key = await pumpSessionDesign(
        tester,
        () => Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => Padding(
              padding: const EdgeInsets.all(16),
              child: LiveMovementFilterChips(
                method: method,
                onMethod: (value) => update(() => method = value),
              ),
            ),
          ),
        ),
        locale: locale,
        width: 320,
        height: 700,
        scale: 1.5,
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('completion_method_cash'.tr()));
      await tester.pumpAndSettle();
      expect(method, 'cash');
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => captureWidget(key, 'build/ui-review/movement-menu-$locale.png'),
      );
      await tester.tap(find.text('detail_all'.tr()));
      await tester.pumpAndSettle();
      expect(method, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}
