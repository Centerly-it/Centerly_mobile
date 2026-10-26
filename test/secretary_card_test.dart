import 'package:centrally/features/secretaries/domain/secretary_record.dart';
import 'package:centrally/features/secretaries/presentation/secretary_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('organized secretary contact and missing phone $locale', (
      tester,
    ) async {
      await pumpSessionDesign(
        tester,
        () => const Scaffold(
          body: SingleChildScrollView(
            child: SecretaryCard(
              record: SecretaryRecord(
                id: 's',
                name: 'اسم السكرتير',
                email: 'secretary@example.invalid',
                status: 'active',
              ),
            ),
          ),
        ),
        locale: locale,
        width: 320,
        scale: 2,
      );
      expect(find.text('secretary_phone_missing'.tr()), findsOneWidget);
      expect(find.text('live_missing_value'.tr()), findsNothing);
      expect(find.text('completion_active'.tr()), findsOneWidget);
      expect(find.text('login_email_label'.tr()), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
