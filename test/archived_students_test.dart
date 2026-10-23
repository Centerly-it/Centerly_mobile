import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/scoped_read_fixture.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/sdk_auth_fixture.dart';

void main() {
  test(
    'archived directory pages forward with explicit owner and archive scope',
    () async {
      const first = '30000000-0000-0000-0000-000000000001';
      const second = '30000000-0000-0000-0000-000000000002';
      final client = scopedReadFixture((request) async {
        final query = request.url.queryParameters;
        expect(query['teacher_id'], 'eq.$testTeacherId');
        expect(query['archived_at'], 'not.is.null');
        expect(query['select'], isNot(contains('qr_code_value')));
        final ids = query['order']?.split('.')[1] == 'asc'
            ? [first, second]
            : [second, first];
        final cursor = query['id']?.replaceFirst('gt.', '');
        return jsonResponse(
          request,
          ids
              .where((id) => cursor == null || id.compareTo(cursor) > 0)
              .take(1)
              .map(
                (id) => {
                  'id': id,
                  'full_name': 'Synthetic archived student',
                  'created_at': '2026-10-01T00:00:00Z',
                  'archived_at': '2026-10-22T00:00:00Z',
                },
              )
              .toList(),
        );
      });
      try {
        await signInReadFixture(client);
        final repository = StudentRepository(TeacherReadClient(client));
        final page = await repository.list(archived: true, limit: 1);
        expect(page.students.single.id, first);
        expect(page.students.single.archivedAt, isNotNull);
        expect(page.nextCursor, first);
        final next = await repository.list(
          archived: true,
          limit: 1,
          cursor: page.nextCursor,
        );
        expect(next.students.single.id, second);
        final end = await repository.list(
          archived: true,
          limit: 1,
          cursor: next.nextCursor,
        );
        expect(end.students, isEmpty);
        expect(end.nextCursor, isNull);
      } finally {
        await client.dispose();
      }
    },
  );
}
