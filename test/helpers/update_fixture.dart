import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:centrally/features/updates/data/update_platform.dart';
import 'package:centrally/features/updates/domain/update_manifest.dart';

final updateBytes = List<int>.generate(256, (i) => i);
const updatePolicyUrl =
    'https://centerly-secretary.pages.dev/updates/android-prod.json';
Map<String, dynamic> updateJson({int minimum = 2, int latest = 2}) => {
  'schema': 1,
  'enabled': true,
  'environment': 'production',
  'package_id': 'com.centerly.teacher',
  'latest_build': latest,
  'minimum_build': minimum,
  'version': '1.0.1',
  'url':
      'https://github.com/Centerly-it/Centerly-releases/releases/download/v1.0.1/centerly-1.0.1.apk',
  'sha256': sha256.convert(updateBytes).toString(),
  'size': updateBytes.length,
  'min_sdk': 24,
};
UpdateManifest fixtureManifest({int minimum = 2}) => UpdateManifest.parse(
  updateJson(minimum: minimum),
  environment: 'production',
  packageId: 'com.centerly.teacher',
)!;
Future<Directory> updateTemp() =>
    Directory.systemTemp.createTemp('centerly-update-test-');

class FakeUpdatePlatform implements UpdatePlatform {
  bool allowed = true;
  int installed = 1, sdk = 31, space = 100000000, installs = 0, settings = 0;
  String? installedPath;
  @override
  Future<UpdateIdentity> identity() async =>
      UpdateIdentity('com.centerly.teacher', installed, sdk, space);
  @override
  Future<bool> canInstall() async => allowed;
  @override
  Future<void> openSettings() async {
    settings++;
  }

  @override
  Future<void> install(String path, int build, int size, String hash) async {
    installs++;
    installedPath = path;
  }
}
