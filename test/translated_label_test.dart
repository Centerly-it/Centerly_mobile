import 'package:centrally/core/localization/translated_label.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';

class _StaleLoader extends AssetLoader {
  const _StaleLoader();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
    'live_missing_value': '—',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('missing cached labels use compiled $locale translations', (
      tester,
    ) async {
      await tester.runAsync(
        () async => tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            startLocale: Locale(locale),
            path: 'assets/translations',
            saveLocale: false,
            assetLoader: const _StaleLoader(),
            child: LocalizedTestApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => Column(
                    children: [
                      Text(translatedLabel(context, 'membership_joined_on')),
                      Text(translatedLabel(context, 'ui_recorded_by')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(locale == 'ar' ? 'تاريخ الانضمام' : 'Joined on'),
        findsOneWidget,
      );
      expect(
        find.text(locale == 'ar' ? 'سجّل بواسطة' : 'Recorded by'),
        findsOneWidget,
      );
      expect(find.text('membership_joined_on'), findsNothing);
      expect(find.text('ui_recorded_by'), findsNothing);
    });
  }
}
