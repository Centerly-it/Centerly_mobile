import 'dart:convert';
import 'package:http/http.dart' as http;
import 'preview_responses.dart';

/// Terminal in-memory transport: deliberately has no delegate/network client.
class PreviewTransport extends http.BaseClient {
  PreviewTransport(Map<String, dynamic> data)
    : responses = PreviewResponses(data);
  final PreviewResponses responses;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().bytesToString();
    final params = (body.isEmpty || body == 'null')
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(body) as Map);
    final name = request.url.pathSegments.last;
    dynamic value;
    try {
      value = responses.call(name, params);
    } catch (e) {
      throw StateError('Preview $name failed: $e');
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(value))),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
      request: request,
    );
  }
}
