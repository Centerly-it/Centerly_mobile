import 'dart:async';
import 'package:centrally/features/auth/data/repo_impl/supabase_teacher_auth.dart';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/scoped_read_fixture.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  for (final rotate in [false, true]) {
    test(
      'late profile ${rotate ? 'revalidates rotated token once' : 'rejects SDK signout'}',
      () async {
        final started = Completer<void>(), release = Completer<void>();
        var calls = 0;
        final client = scopedReadFixture((r) async {
          calls++;
          if (!started.isCompleted) started.complete();
          await release.future;
          return jsonResponse(r, {
            'id': testTeacherId,
            'teacher_id': testTeacherId,
            'role': 'teacher',
          });
        });
        addTearDown(client.dispose);
        await signInReadFixture(client);
        final repository = SupabaseTeacherAuth(client, () async {});
        final restore = repository.restore();
        final rejected = rotate
            ? null
            : expectLater(
                restore,
                throwsA(
                  isA<TeacherAuthFailure>().having(
                    (e) => e.code,
                    'code',
                    'AUTH_REQUIRED',
                  ),
                ),
              );
        await started.future;
        if (rotate) {
          await client.auth.refreshSession();
        } else {
          await client.auth.signOut();
        }
        release.complete();
        if (rotate) {
          expect((await restore)?.id, testTeacherId);
          expect(calls, 2);
        } else {
          await rejected;
        }
      },
    );
  }
}
