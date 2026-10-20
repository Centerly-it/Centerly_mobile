import 'dart:convert';
import 'dart:io';
import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    test('compiled $locale translations match canonical JSON', () {
      final expected = jsonDecode(
        File('assets/translations/$locale.json').readAsStringSync(),
      );
      expect(CodegenLoader.mapLocales[locale], expected);
    });
  }
}
