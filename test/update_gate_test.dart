import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:centrally/features/updates/data/update_repository.dart';
import 'package:centrally/features/updates/data/update_downloader.dart';
import 'package:centrally/features/updates/presentation/update_controller.dart';
import 'package:centrally/features/updates/presentation/update_gate.dart';
import 'helpers/update_fixture.dart';
import 'helpers/localized_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final language in ['ar', 'en']) {
    testWidgets(
      'mandatory update blocks back/outside taps and requires an explicit action $language',
      (tester) async {
        final directory = Directory.systemTemp.createTempSync(
          'centerly-update-widget-',
        );
        final platform = FakeUpdatePlatform();
        final client = MockClient(
          (r) async => r.url.path.endsWith('.json')
              ? http.Response(jsonEncode(updateJson()), 200)
              : http.Response.bytes(updateBytes, 200),
        );
        final c = UpdateController(
          repository: UpdateRepository(
            client,
            directory,
            environment: 'production',
            packageId: 'com.centerly.teacher',
          ),
          downloader: UpdateDownloader(client, directory),
          platform: platform,
          manifestUri: Uri.parse(updatePolicyUrl),
        );
        addTearDown(() async {
          c.dispose();
          directory.deleteSync(recursive: true);
        });
        await tester.runAsync(c.check);
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            path: 'assets/translations',
            assetLoader: const CodegenLoader(),
            startLocale: Locale(language),
            saveLocale: false,
            child: LocalizedTestApp(
              home: UpdateGate(
                controller: c,
                child: const Scaffold(body: Text('Protected')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(platform.installs, 0);
        expect(find.text(language == 'ar' ? 'لاحقًا' : 'Later'), findsNothing);
        await tester.tapAt(const Offset(1, 1));
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
