import 'package:http/http.dart' as http;

Future<http.StreamedResponse> openUpdateDownload(
  http.Client client,
  Uri initial,
  int offset,
) async {
  var uri = initial;
  for (var redirects = 0; redirects <= 5; redirects++) {
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        (uri.hasPort && uri.port != 443) ||
        !{
          'github.com',
          'release-assets.githubusercontent.com',
          'objects.githubusercontent.com',
        }.contains(uri.host)) {
      throw const FormatException('UPDATE_INVALID');
    }
    final request = http.Request('GET', uri)..followRedirects = false;
    request.headers['Accept-Encoding'] = 'identity';
    if (offset > 0) request.headers['Range'] = 'bytes=$offset-';
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 20));
    if (!{301, 302, 303, 307, 308}.contains(response.statusCode)) {
      return response;
    }
    final location = response.headers['location'];
    await response.stream.drain<void>().timeout(const Duration(seconds: 10));
    if (location == null) throw const FormatException('UPDATE_INVALID');
    uri = uri.resolve(location);
  }
  throw const FormatException('UPDATE_INVALID');
}
