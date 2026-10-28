import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../domain/update_manifest.dart';

class UpdateRepository {
  UpdateRepository(
    this.client,
    this.directory, {
    required this.environment,
    required this.packageId,
  });
  final http.Client client;
  final Directory directory;
  final String environment, packageId;
  File get _cache => File('${directory.path}/policy.json');
  UpdateManifest? _parse(String body) => UpdateManifest.parse(
    Map<String, dynamic>.from(jsonDecode(body) as Map),
    environment: environment,
    packageId: packageId,
  );
  Future<UpdateManifest?> cached() async {
    try {
      return _parse(await _cache.readAsString());
    } catch (_) {
      return null;
    }
  }

  Future<UpdateManifest?> fetch(Uri uri) async {
    if (uri.scheme != 'https' ||
        uri.host != 'centerly-secretary.pages.dev' ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.hasPort && uri.port != 443) ||
        uri.path !=
            '/updates/android-${environment == 'production' ? 'prod' : 'dev'}.json') {
      throw const FormatException('UPDATE_INVALID');
    }
    final request = http.Request('GET', uri)..followRedirects = false;
    request.headers['Cache-Control'] = 'no-cache';
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw const HttpException('UPDATE_NETWORK');
    final bytes = <int>[];
    await for (final part in response.stream.timeout(
      const Duration(seconds: 10),
    )) {
      bytes.addAll(part);
      if (bytes.length > 16384) throw const FormatException('UPDATE_INVALID');
    }
    final body = utf8.decode(bytes);
    final manifest = _parse(body);
    await directory.create(recursive: true);
    final temporary = File('${_cache.path}.tmp');
    await temporary.writeAsString(body, flush: true);
    await temporary.rename(_cache.path);
    return manifest;
  }
}
