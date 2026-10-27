import 'dart:convert';
import 'package:centrally/core/diagnostics/app_diagnostics.dart';
import 'package:centrally/core/diagnostics/diagnostic_http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'logs endpoint/status/code without credentials, query values or response records',
    () async {
      final lines = <String>[];
      final previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        lines.add(message ?? '');
      };
      addTearDown(() => debugPrint = previous);
      final diagnostics = AppDiagnostics(
        environment: 'development',
        console: true,
      );
      var calls = 0;
      final client = DiagnosticHttpClient(
        MockClient((request) async {
          calls++;
          expect(request.headers['authorization'], 'Bearer private-token');
          expect(request.body, contains('private-note'));
          return http.Response(
            jsonEncode({
              'code': 'P0001',
              'message': 'SUBSCRIPTION_INACTIVE',
              'details': 'student-private-name',
              'hint': 'private-password',
            }),
            400,
          );
        }),
        diagnostics: diagnostics,
      );
      addTearDown(client.close);
      final response = await client.post(
        Uri.parse(
          'https://private-host/rest/v1/rpc/get_current_profile?student=private-id',
        ),
        headers: {'authorization': 'Bearer private-token'},
        body: 'private-note',
      );
      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['details'], 'student-private-name');
      expect(calls, 1);
      final event = diagnostics.recent.last;
      expect(event.operation, 'POST /rest/v1/rpc/get_current_profile');
      expect(event.code, 'SUBSCRIPTION_INACTIVE');
      expect(event.elapsedMs, isNonNegative);
      final log = lines.join();
      for (final secret in [
        'private-token',
        'private-note',
        'private-host',
        'private-id',
        'private-password',
        'student-private-name',
      ]) {
        expect(log, isNot(contains(secret)));
      }
    },
  );

  test(
    'unknown endpoint segments are redacted and transport errors are not retried',
    () async {
      var calls = 0;
      final diagnostics = AppDiagnostics(
        environment: 'development',
        console: false,
      );
      final client = DiagnosticHttpClient(
        MockClient((_) async {
          calls++;
          throw http.ClientException('secret error message');
        }),
        diagnostics: diagnostics,
      );
      addTearDown(client.close);
      await expectLater(
        client.get(Uri.parse('https://host/private-email/private-token')),
        throwsA(isA<http.ClientException>()),
      );
      expect(calls, 1);
      expect(diagnostics.recent.single.operation, 'GET /redacted-endpoint');
      expect(diagnostics.recent.single.code, 'TRANSPORT_ERROR');
      expect(
        jsonEncode(diagnostics.recent.single.toJson()),
        isNot(contains('secret')),
      );
    },
  );

  test(
    'large bodies pass through unchanged with bounded metadata sampling',
    () async {
      final body = List.filled(20000, 'private-value').join();
      final diagnostics = AppDiagnostics(
        environment: 'development',
        console: true,
      );
      final client = DiagnosticHttpClient(
        MockClient((_) async => http.Response(body, 200)),
        diagnostics: diagnostics,
      );
      addTearDown(client.close);
      expect(
        (await client.get(Uri.parse('https://host/rest/v1/students'))).body,
        body,
      );
      expect(diagnostics.recent.last.shape, 'body_over_preview_limit');
      expect(diagnostics.recent.last.bytes, utf8.encode(body).length);
    },
  );

  test(
    'production has no console output and retains only bounded failure metadata',
    () {
      final lines = <String>[];
      final previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        lines.add(message ?? '');
      };
      addTearDown(() => debugPrint = previous);
      final diagnostics = AppDiagnostics(
        environment: 'production',
        console: true,
      );
      diagnostics.record(
        const DiagnosticRecord(operation: 'app.config', outcome: 'completed'),
      );
      for (var i = 0; i < 75; i++) {
        diagnostics.failure('app.config', 'CONFIG_INVALID');
      }
      expect(lines, isEmpty);
      expect(diagnostics.recent.length, 50);
    },
  );
}
