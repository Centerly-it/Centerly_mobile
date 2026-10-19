import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/sessions/data/session_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'cancellation validates reason, maps conflict and never retries a write',
    () async {
      var calls = 0;
      final client = readFixture((request) async {
        calls++;
        if (calls == 1) throw http.ClientException('synthetic disconnect');
        return jsonResponse(request, {
          'message': 'ALREADY_CANCELLED',
          'code': 'P0001',
        }, status: 400);
      });
      final api = TeacherReadClient(client);
      final actions = SessionActions(api);
      await expectLater(
        actions.cancel('id', ' '),
        throwsA(isA<BackendFailure>()),
      );
      expect(calls, 0);
      await expectLater(
        actions.cancel('id', 'reason'),
        throwsA(
          isA<BackendFailure>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
        ),
      );
      expect(calls, 1);
      await expectLater(
        actions.cancel('id', 'reason'),
        throwsA(
          isA<BackendFailure>().having(
            (e) => e.code,
            'code',
            'ALREADY_CANCELLED',
          ),
        ),
      );
      expect(calls, 2);
      expect(api.cache.generation, 2);
      await client.dispose();
    },
  );
}
