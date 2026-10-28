import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:centrally/features/updates/data/update_repository.dart';
import 'package:centrally/features/updates/data/update_downloader.dart';
import 'package:centrally/features/updates/presentation/update_controller.dart';
import 'helpers/update_fixture.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await updateTemp();
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  UpdateController create(FakeUpdatePlatform platform, http.Client client) =>
      UpdateController(
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
  http.Client online({int minimum = 2}) => MockClient(
    (r) async => r.url.path.endsWith('.json')
        ? http.Response(jsonEncode(updateJson(minimum: minimum)), 200)
        : http.Response.bytes(updateBytes, 200),
  );
  test(
    'known required policy stays blocking offline; unknown outage does not lock out',
    () async {
      await File(
        '${directory.path}/policy.json',
      ).writeAsString(jsonEncode(updateJson()));
      final c = create(
        FakeUpdatePlatform(),
        MockClient((_) async => throw http.ClientException('offline')),
      );
      addTearDown(c.dispose);
      await c.check();
      expect(c.visible, isTrue);
      expect(c.mandatory, isTrue);
      c.dismiss();
      expect(c.visible, isTrue);
      await File('${directory.path}/policy.json').delete();
      final fresh = create(
        FakeUpdatePlatform(),
        MockClient((_) async => throw http.ClientException('offline')),
      );
      addTearDown(fresh.dispose);
      await fresh.check();
      expect(fresh.visible, isFalse);
    },
  );
  test(
    'optional offer can be dismissed without reappearing on resume',
    () async {
      final c = create(FakeUpdatePlatform(), online(minimum: 1));
      addTearDown(c.dispose);
      await c.check();
      expect(c.visible, isTrue);
      expect(c.mandatory, isFalse);
      c.dismiss();
      await c.resumed();
      expect(c.visible, isFalse);
    },
  );
  test(
    'permission required, returning from settings, installer cancellation and retry',
    () async {
      final p = FakeUpdatePlatform()..allowed = false;
      final c = create(p, online());
      addTearDown(c.dispose);
      await c.check();
      await c.action();
      expect(c.phase, UpdatePhase.permission);
      expect(p.installs, 0);
      await c.action();
      expect(p.settings, 1);
      p.allowed = true;
      await c.resumed();
      expect(c.phase, UpdatePhase.ready);
      await c.action();
      expect(p.installs, 1);
      expect(c.visible, isTrue);
      await c.action();
      expect(p.installs, 2); // User explicitly retries a cancelled installer.
    },
  );
  test('space and incompatible SDK stop before installation', () async {
    final p = FakeUpdatePlatform()..space = 0;
    final c = create(p, online());
    addTearDown(c.dispose);
    await c.check();
    await c.action();
    expect(c.error, 'UPDATE_SPACE');
    expect(p.installs, 0);
    p.space = 100000000;
    p.sdk = 23;
    await c.check(force: true);
    expect(c.phase, UpdatePhase.incompatible);
    await c.action();
    expect(p.installs, 0);
  });
  test('withdrawn requirement unblocks a cached mandatory update', () async {
    await File(
      '${directory.path}/policy.json',
    ).writeAsString(jsonEncode(updateJson()));
    final c = create(
      FakeUpdatePlatform(),
      MockClient(
        (_) async =>
            http.Response(jsonEncode({...updateJson(), 'enabled': false}), 200),
      ),
    );
    addTearDown(c.dispose);
    await c.check();
    expect(c.visible, isFalse);
    expect(c.mandatory, isFalse);
  });
}
