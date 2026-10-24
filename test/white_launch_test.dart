import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'day and night native launch/normal themes stay light on pre/post Android 12',
    () {
      for (final folder in [
        'values',
        'values-night',
        'values-v31',
        'values-night-v31',
      ]) {
        final xml = File(
          'android/app/src/main/res/$folder/styles.xml',
        ).readAsStringSync();
        expect(xml, contains('Theme.Light.NoTitleBar'));
        expect(xml, isNot(contains('Theme.Black')));
        expect(
          xml,
          contains('<item name="android:windowBackground">#ffffff</item>'),
        );
        expect('android:forceDarkAllowed'.allMatches(xml).length, 2);
        if (folder.endsWith('v31')) {
          expect(
            xml,
            contains(
              '<item name="android:windowSplashScreenBackground">#ffffff</item>',
            ),
          );
        }
      }
    },
  );
}
