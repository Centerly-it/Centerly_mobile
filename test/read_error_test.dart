import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'read retries transient transport failure and returns server data',
    () async {
      var calls = 0;
      final client = readFixture((request) async {
        calls++;
        if (calls == 1) throw http.ClientException('synthetic offline');
        return jsonResponse(request, []);
      });
      final api = TeacherReadClient(client);
      expect(await api.read(TeacherRead.students), isEmpty);
      expect(calls, 2);
      await client.dispose();
    },
  );
  test(
    'inactive access is not retried and invalidates the live account gate',
    () async {
      var calls = 0, invalidated = 0;
      final client = readFixture((request) async {
        calls++;
        return jsonResponse(request, {
          'message': 'ACCOUNT_INACTIVE',
          'code': 'P0001',
        }, status: 400);
      });
      final api = TeacherReadClient(
        client,
        onAccessDenied: () async {
          invalidated++;
        },
      );
      await expectLater(
        api.read(TeacherRead.dashboard),
        throwsA(
          isA<BackendFailure>().having(
            (e) => e.code,
            'code',
            'ACCOUNT_INACTIVE',
          ),
        ),
      );
      expect(calls, 1);
      expect(invalidated, 1);
      await client.dispose();
    },
  );
  test('unexpected SQL failures are sanitized', () {
    expect(
      mapBackendFailure(const FormatException('private response')).code,
      'SERVICE_UNAVAILABLE',
    );
  });
}
