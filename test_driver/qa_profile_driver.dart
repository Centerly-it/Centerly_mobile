import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async => integrationDriver(
  timeout: const Duration(minutes: 2),
  responseDataCallback: (data) async {
    final folder = Directory('build/qa26')..createSync(recursive: true);
    await File(
      '${folder.path}/native-profile.json',
    ).writeAsString(jsonEncode(data));
  },
);
