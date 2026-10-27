import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final folder in [
    'values',
    'values-night',
    'values-v31',
    'values-night-v31',
  ]) {
    test('$folder keeps launch and normal windows light', () {
      final xml = File(
        'android/app/src/main/res/$folder/styles.xml',
      ).readAsStringSync();
      for (final theme in ['LaunchTheme', 'NormalTheme']) {
        final style = RegExp(
          '<style name="$theme"[^>]*>([\\s\\S]*?)</style>',
        ).firstMatch(xml)!.group(1)!;
        expect(xml, contains('parent="@android:style/Theme.Light.NoTitleBar"'));
        expect(style, contains('name="android:forceDarkAllowed">false</item>'));
        expect(
          style,
          contains('name="android:colorBackground">#ffffff</item>'),
        );
      }
      if (folder.contains('v31')) {
        expect(
          xml,
          contains(
            'name="android:windowSplashScreenBackground">#ffffff</item>',
          ),
        );
        expect(
          xml,
          contains(
            'name="android:windowSplashScreenIconBackgroundColor">#ffffff</item>',
          ),
        );
      }
    });
  }
  for (final folder in ['drawable', 'drawable-v21']) {
    test('$folder launch background uses explicit white, not system theme', () {
      final xml = File(
        'android/app/src/main/res/$folder/launch_background.xml',
      ).readAsStringSync();
      expect(xml, contains('android:drawable="@android:color/white"'));
      expect(xml, isNot(contains('@drawable/background')));
    });
  }
}
