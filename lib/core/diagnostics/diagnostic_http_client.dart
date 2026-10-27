import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'app_diagnostics.dart';
import 'diagnostic_response.dart';
import 'diagnostic_endpoint.dart';
import 'diagnostic_error_type.dart';
export 'diagnostic_endpoint.dart';

class DiagnosticHttpClient extends http.BaseClient {
  DiagnosticHttpClient(this.inner, {AppDiagnostics? diagnostics})
    : diagnostics = diagnostics ?? AppDiagnostics.current;
  final http.Client inner;
  final AppDiagnostics diagnostics;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final id = diagnostics.nextRequestId();
    final method =
        {
          'GET',
          'POST',
          'PUT',
          'PATCH',
          'DELETE',
          'HEAD',
        }.contains(request.method)
        ? request.method
        : 'OTHER';
    final operation = '$method ${diagnosticEndpoint(request.url)}';
    final watch = Stopwatch()..start();
    diagnostics.record(
      DiagnosticRecord(operation: operation, outcome: 'started', requestId: id),
    );
    var finished = false;
    void finish(
      int? status,
      int bytes,
      List<int> prefix, {
      bool failed = false,
      Object? error,
    }) {
      if (finished) return;
      finished = true;
      final body = diagnosticResponse(prefix, bytes);
      diagnostics.record(
        DiagnosticRecord(
          operation: operation,
          outcome: failed || (status ?? 0) >= 400 ? 'failed' : 'completed',
          requestId: id,
          status: status,
          elapsedMs: watch.elapsedMilliseconds,
          bytes: bytes,
          shape: body.shape,
          code: body.code ?? (failed ? 'TRANSPORT_ERROR' : null),
          errorType: diagnosticErrorType(error),
        ),
      );
    }

    try {
      final response = await inner.send(request);
      var bytes = 0;
      final prefix = <int>[];
      final stream = response.stream.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (chunk, sink) {
            bytes += chunk.length;
            if (prefix.length < 4096) {
              prefix.addAll(
                chunk.take(min(chunk.length, 4096 - prefix.length)),
              );
            }
            sink.add(chunk);
          },
          handleError: (Object e, StackTrace stack, sink) {
            finish(response.statusCode, bytes, prefix, failed: true, error: e);
            sink.addError(e, stack);
          },
          handleDone: (sink) {
            finish(response.statusCode, bytes, prefix);
            sink.close();
          },
        ),
      );
      return http.StreamedResponse(
        stream,
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      finish(null, 0, [], failed: true, error: error);
      rethrow;
    }
  }

  @override
  void close() => inner.close();
}
