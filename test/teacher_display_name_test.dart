import 'package:centrally/features/auth/data/repo_impl/supabase_teacher_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/scoped_read_fixture.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  for (final unavailable in [false, true]) {
    test('trusted tenant display name, unavailable=$unavailable', () async {
      final client = scopedReadFixture((request) async {
        if (request.url.path.endsWith('/teachers')) {
          expect(request.url.queryParameters['select'], 'name');
          expect(request.url.queryParameters['id'], 'eq.$testTeacherId');
          return jsonResponse(
            request,
            unavailable
                ? {'message': 'unavailable'}
                : {'name': 'Trusted teacher'},
            status: unavailable ? 503 : 200,
          );
        }
        return jsonResponse(request, {
          'id': testTeacherId,
          'teacher_id': testTeacherId,
          'role': 'teacher',
          'display_name': 'Untrusted RPC extension',
        });
      });
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final profile = await SupabaseTeacherAuth(client, () async {}).restore();
      expect(profile?.displayName, unavailable ? null : 'Trusted teacher');
      expect(profile?.teacherId, testTeacherId);
    });
  }
}
