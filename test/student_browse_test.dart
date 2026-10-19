import 'dart:async';
import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:centrally/features/students/presentation/student_browse_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/student_read_fixture.dart';

void main() {
  test(
    'group roster keeps its scope across search and rejects stale results',
    () async {
      final started = Completer<void>(), release = Completer<void>();
      final client = readFixture((request) async {
        final body = jsonDecode(request.body) as Map;
        expect(body['p_group_id'], 'group');
        expect(body['p_limit'], 30);
        expect(body.containsKey('teacher_id'), isFalse);
        if (body['p_search'] == 'old') {
          started.complete();
          await release.future;
        }
        return jsonResponse(request, [studentJson(body['p_search'] as String)]);
      });
      final cubit = StudentBrowseCubit(
        StudentRepository(TeacherReadClient(client)),
        groupId: 'group',
      );
      final old = cubit.search('old');
      await started.future;
      await cubit.search('new');
      release.complete();
      await old;
      expect(cubit.state.students.single.id, 'new');
      await cubit.close();
      await client.dispose();
    },
  );
  test(
    'student pages deduplicate records and stop at the final cursor',
    () async {
      var calls = 0;
      final client = readFixture((request) async {
        calls++;
        final body = jsonDecode(request.body) as Map;
        return jsonResponse(
          request,
          body['p_cursor'] == null
              ? [for (var i = 0; i < 30; i++) studentJson('$i')]
              : [studentJson('29'), studentJson('30')],
        );
      });
      final cubit = StudentBrowseCubit(
        StudentRepository(TeacherReadClient(client)),
      );
      await cubit.search('');
      await Future.wait([cubit.next(), cubit.next()]);
      expect(calls, 2);
      expect(cubit.state.students.length, 31);
      expect(cubit.state.cursor, isNull);
      await cubit.close();
      await client.dispose();
    },
  );
}
