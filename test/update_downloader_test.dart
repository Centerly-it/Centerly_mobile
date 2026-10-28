import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:centrally/features/updates/data/update_downloader.dart';
import 'package:centrally/features/updates/data/update_redirects.dart';
import 'helpers/update_fixture.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await updateTemp();
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  test('resumes a partial file using validated byte range', () async {
    final m = fixtureManifest();
    final file = File(
      '${directory.path}/update-${m.latestBuild}-${m.sha256}.apk',
    );
    await file.writeAsBytes(updateBytes.take(10).toList());
    final client = MockClient((r) async {
      expect(r.headers['range'], 'bytes=10-');
      return http.Response.bytes(
        updateBytes.sublist(10),
        206,
        headers: {'content-range': 'bytes 10-255/256'},
      );
    });
    addTearDown(client.close);
    final result = await UpdateDownloader(
      client,
      directory,
    ).download(m, (_, _) {});
    expect(await result.readAsBytes(), updateBytes);
  });
  test('restarts safely when the server ignores Range', () async {
    final m = fixtureManifest();
    await File(
      '${directory.path}/update-${m.latestBuild}-${m.sha256}.apk',
    ).writeAsBytes([1, 2, 3]);
    final client = MockClient(
      (_) async => http.Response.bytes(updateBytes, 200),
    );
    addTearDown(client.close);
    expect(
      await (await UpdateDownloader(
        client,
        directory,
      ).download(m, (_, _) {})).readAsBytes(),
      updateBytes,
    );
  });
  test('rejects corruption and removes the corrupt file', () async {
    final client = MockClient(
      (_) async => http.Response.bytes(List.filled(256, 0), 200),
    );
    addTearDown(client.close);
    await expectLater(
      UpdateDownloader(
        client,
        directory,
      ).download(fixtureManifest(), (_, _) {}),
      throwsFormatException,
    );
    expect(await directory.list().isEmpty, isTrue);
  });
  test('refuses inconsistent range metadata', () async {
    final client = MockClient(
      (_) async => http.Response.bytes(
        updateBytes,
        206,
        headers: {'content-range': 'bytes 10-255/256'},
      ),
    );
    addTearDown(client.close);
    await expectLater(
      UpdateDownloader(
        client,
        directory,
      ).download(fixtureManifest(), (_, _) {}),
      throwsFormatException,
    );
  });
  test('rejects redirects to untrusted hosts or HTTP', () async {
    for (final location in [
      'https://evil.test/file.apk',
      'http://github.com/file.apk',
    ]) {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('', 302, headers: {'location': location});
      });
      addTearDown(client.close);
      await expectLater(
        openUpdateDownload(client, fixtureManifest().url, 0),
        throwsFormatException,
      );
      expect(calls, 1);
    }
  });
  test('reuses an already verified download without another request', () async {
    final m = fixtureManifest();
    await File(
      '${directory.path}/update-${m.latestBuild}-${m.sha256}.apk',
    ).writeAsBytes(updateBytes);
    final client = MockClient(
      (_) async => throw StateError('Must not request again'),
    );
    addTearDown(client.close);
    expect(
      await (await UpdateDownloader(
        client,
        directory,
      ).download(m, (_, _) {})).length(),
      256,
    );
  });
}
