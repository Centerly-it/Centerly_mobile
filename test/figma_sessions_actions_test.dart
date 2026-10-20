import 'package:centrally/features/sessions/preview/session_design_detail.dart';
import 'package:centrally/features/sessions/preview/session_design_fixture.dart';
import 'package:centrally/features/sessions/presentation/design/session_cancel_reason.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  testWidgets(
    'local cancellation requires reason and preserves attendance history',
    (tester) async {
      final fixture = SessionDesignFixture();
      await pumpSessionDesign(
        tester,
        () => SessionDesignDetail(
          data: fixture.day(DateTime(2026, 10, 20)).first,
        ),
      );
      final data = fixture.day(DateTime(2026, 10, 20)).first;
      await tester.scrollUntilVisible(
        find.text('session_cancel_button'.tr()),
        250,
      );
      await tester.tap(find.text('session_cancel_button'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'cancel_submit'.tr()));
      await tester.pumpAndSettle();
      expect(data.cancellationReason, isNull);
      expect(find.text('live_error_VALIDATION_ERROR'.tr()), findsOneWidget);
      await tester.tap(find.byType(SessionCancelReason).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'cancel_submit'.tr()));
      await tester.pumpAndSettle();
      expect(data.cancellationReason, 'design_low_students'.tr());
      expect(data.students.length, 25);
      expect(find.text('session_cancel_button'.tr()), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
