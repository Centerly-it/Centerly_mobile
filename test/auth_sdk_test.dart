import 'package:centrally/features/auth/data/repo_impl/supabase_teacher_auth.dart';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  for (final role in ['teacher', 'secretary']) {
    test('real Supabase SDK validates $role with server profile', () async {
      var cleared = false;
      final requests = <String>[];
      final client = authFixture(role: role, requests: requests);
      final repo = SupabaseTeacherAuth(client, () async {
        cleared = true;
      });
      if (role == 'teacher') {
        final result = await repo.login(
          ' teacher@example.test ',
          'preserved password',
        );
        expect(result.id, testTeacherId);
        expect(client.auth.currentSession, isNotNull);
        expect((await repo.restore())?.teacherId, testTeacherId);
        await repo.logout();
        expect(client.auth.currentSession, isNull);
        expect(cleared, isTrue);
      } else {
        await expectLater(
          repo.login('secretary@example.test', 'password'),
          throwsA(
            isA<TeacherAuthFailure>().having(
              (e) => e.code,
              'code',
              'FORBIDDEN_ROLE',
            ),
          ),
        );
        expect(client.auth.currentSession, isNull);
        expect(cleared, isTrue);
      }
      expect(requests, contains('/rest/v1/rpc/get_current_profile'));
      await client.dispose();
    });
  }
  test(
    'real SDK maps invalid credentials and clears local persistence',
    () async {
      var cleared = false;
      final client = authFixture(invalid: true, requests: []);
      final repo = SupabaseTeacherAuth(client, () async {
        cleared = true;
      });
      await expectLater(
        repo.login('x@example.test', 'wrong'),
        throwsA(
          isA<TeacherAuthFailure>().having(
            (e) => e.code,
            'code',
            'INVALID_CREDENTIALS',
          ),
        ),
      );
      expect(cleared, isTrue);
      expect(client.auth.currentSession, isNull);
      await client.dispose();
    },
  );
}
