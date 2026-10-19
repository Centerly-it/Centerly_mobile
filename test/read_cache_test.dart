import 'dart:async';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/core/network/read_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  test(
    'cache expires, isolates returned objects, bounds memory and clears',
    () {
      var now = DateTime.utc(2026);
      final cache = ReadCache(now: () => now);
      cache.put('a', {'value': 1});
      (cache.get('a')! as Map)['value'] = 2;
      expect((cache.get('a')! as Map)['value'], 1);
      now = now.add(const Duration(seconds: 30));
      expect(cache.get('a'), isNull);
      for (var i = 0; i < 65; i++) {
        cache.put('$i', i);
      }
      expect(cache.get('0'), isNull);
      expect(cache.get('64'), 64);
      cache.clear();
      expect(cache.get('64'), isNull);
    },
  );

  test(
    'authenticated reads cache; refresh and logout cannot reuse data',
    () async {
      final requests = <String>[];
      final client = authFixture(requests: requests);
      await client.auth.signInWithPassword(
        email: 'x@test.com',
        password: 'test',
      );
      final api = TeacherReadClient(client);
      await api.read(TeacherRead.dashboard);
      await api.read(TeacherRead.dashboard);
      expect(
        requests.where((p) => p.endsWith('get_teacher_dashboard')).length,
        1,
      );
      await api.read(TeacherRead.dashboard, refresh: true);
      expect(
        requests.where((p) => p.endsWith('get_teacher_dashboard')).length,
        2,
      );
      await client.auth.signOut();
      await api.read(TeacherRead.dashboard);
      expect(
        requests.where((p) => p.endsWith('get_teacher_dashboard')).length,
        3,
      );
      await client.dispose();
    },
  );

  test('late response after session invalidation is rejected', () async {
    final started = Completer<void>(), release = Completer<void>();
    final client = readFixture((request) async {
      started.complete();
      await release.future;
      return jsonResponse(request, []);
    });
    final api = TeacherReadClient(client);
    final pending = api.read(TeacherRead.students);
    final expectation = expectLater(
      pending,
      throwsA(
        isA<BackendFailure>().having((e) => e.code, 'code', 'AUTH_REQUIRED'),
      ),
    );
    await started.future;
    api.invalidate();
    release.complete();
    await expectation;
    await client.dispose();
  });
}
