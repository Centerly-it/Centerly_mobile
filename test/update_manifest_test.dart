import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/features/updates/domain/update_manifest.dart';
import 'helpers/update_fixture.dart';

void main() {
  UpdateManifest? parse(Map<String, dynamic> j) => UpdateManifest.parse(
    j,
    environment: 'production',
    packageId: 'com.centerly.teacher',
  );
  test('uses numeric builds for required/optional/current checks', () {
    final m = parse(updateJson())!;
    expect(m.requiredFor(1), isTrue);
    expect(m.availableFor(2), isFalse);
    expect(parse(updateJson(minimum: 1))!.requiredFor(1), isFalse);
    expect(parse({...updateJson(), 'enabled': false}), isNull);
  });
  for (final patch in [
    {'environment': 'development'},
    {'package_id': 'com.centerly.teacher.dev'},
    {'schema': 2},
    {'minimum_build': 3},
    {'latest_build': 0},
    {'minimum_build': -1},
    {'size': 301 * 1024 * 1024},
    {'size': 0},
    {'sha256': 'bad'},
    {'min_sdk': 0},
    {
      'url':
          'http://github.com/Centerly-it/Centerly-releases/releases/download/v1/a.apk',
    },
    {'url': 'https://github.com/another/repo/releases/download/v1/a.apk'},
    {'url': 'https://evil.test/a.apk'},
    {'version': 'private arbitrary message'},
    {
      'url':
          'https://github.com:8443/Centerly-it/Centerly-releases/releases/download/v1/a.apk',
    },
  ]) {
    test(
      'rejects invalid manifest ${patch.keys.first} ${patch.values.first}',
      () {
        expect(() => parse({...updateJson(), ...patch}), throwsFormatException);
      },
    );
  }
}
