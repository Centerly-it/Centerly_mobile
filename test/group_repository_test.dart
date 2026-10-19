import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/groups/data/group_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'prepared group contract bounds pages, preserves preview flags and scopes args',
    () async {
      var calls = 0;
      final client = readFixture((request) async {
        calls++;
        expect(request.url.path, '/rest/v1/rpc/list_teacher_groups');
        expect(jsonDecode(request.body), {
          'p_search': 'Math',
          'p_grade_level_id': 'grade',
          'p_cursor': 'before',
          'p_limit': 1,
        });
        return jsonResponse(request, [
          {
            'id': 'group',
            'name': 'أولى ثانوي',
            'subject_name': 'Math',
            'grade_level_id': 'grade',
            'grade_name': 'Grade 1',
            'capacity': 30,
            'students_count': 12,
            'schedules_truncated': true,
            'roster_preview': [
              {'id': 'student', 'full_name': 'أحمد'},
            ],
            'schedules': [
              {
                'weekday': 0,
                'local_start_time': '23:00:00',
                'local_end_time': '01:00:00',
                'effective_from': '2026-01-01',
                'effective_to': null,
              },
            ],
          },
        ]);
      });
      final repo = GroupRepository(TeacherReadClient(client));
      final page = await repo.list(
        search: ' Math ',
        gradeId: 'grade',
        cursor: 'before',
        limit: 1,
      );
      expect(page.nextCursor, 'group');
      expect(page.groups.single.students, 12);
      expect(page.groups.single.schedulesTruncated, isTrue);
      expect(page.groups.single.roster.single.name, 'أحمد');
      await expectLater(repo.list(limit: 101), throwsA(isA<BackendFailure>()));
      expect(calls, 1);
      await client.dispose();
    },
  );
}
