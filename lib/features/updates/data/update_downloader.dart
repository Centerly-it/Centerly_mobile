import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../domain/update_manifest.dart';
import 'update_redirects.dart';

class UpdateDownloader {
  UpdateDownloader(this.client, this.directory);
  final http.Client client;
  final Directory directory;
  File _file(UpdateManifest m) =>
      File('${directory.path}/update-${m.latestBuild}-${m.sha256}.apk');
  Future<int> remaining(UpdateManifest m) async {
    await _clean(m);
    final file = _file(m);
    final size = await file.exists() ? await file.length() : 0;
    return size <= m.size ? m.size - size : m.size;
  }

  Future<File> download(
    UpdateManifest m,
    void Function(int, int) progress,
  ) async {
    await _clean(m);
    final file = _file(m);
    var offset = await file.exists() ? await file.length() : 0;
    if (offset > m.size) {
      await file.delete();
      offset = 0;
    }
    if (offset == m.size) {
      return _verify(file, m);
    }
    final response = await openUpdateDownload(client, m.url, offset);
    return _receive(response, file, m, offset, progress);
  }

  Future<void> _clean(UpdateManifest m) async {
    await directory.create(recursive: true);
    final file = _file(m);
    for (final old in await directory.list().toList()) {
      if (old is File &&
          old.uri != file.uri &&
          RegExp(
            r'update-\d+-[a-f0-9]{64}\.apk$',
          ).hasMatch(old.uri.pathSegments.last)) {
        await old.delete();
      }
    }
  }

  Future<File> _receive(
    http.StreamedResponse response,
    File file,
    UpdateManifest m,
    int offset,
    void Function(int, int) progress,
  ) async {
    if (response.statusCode != 200 && response.statusCode != 206) {
      await response.stream.drain<void>();
      throw const HttpException('UPDATE_NETWORK');
    }
    if (response.statusCode == 200) offset = 0;
    if (response.statusCode == 206 &&
        response.headers['content-range'] !=
            'bytes $offset-${m.size - 1}/${m.size}') {
      await response.stream.drain<void>();
      throw const FormatException('UPDATE_INVALID');
    }
    if (response.contentLength != null &&
        response.contentLength != m.size - offset) {
      await response.stream.drain<void>();
      throw const FormatException('UPDATE_INVALID');
    }
    final sink = await file.open(
      mode: offset == 0 ? FileMode.write : FileMode.append,
    );
    var received = offset;
    try {
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 30),
      )) {
        received += chunk.length;
        if (received > m.size) throw const FormatException('UPDATE_INVALID');
        await sink.writeFrom(chunk);
        progress(received, m.size);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    return _verify(file, m);
  }

  Future<File> _verify(File file, UpdateManifest m) async {
    if (await file.length() != m.size) {
      throw const HttpException('UPDATE_NETWORK');
    }
    final digest = await file.openRead().transform(sha256).first;
    if (digest.toString() != m.sha256) {
      await file.delete();
      throw const FormatException('UPDATE_CHECKSUM');
    }
    return file;
  }
}
