import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/sessions/data/session_detail_repository.dart';
import 'package:centrally/features/sessions/presentation/session_detail_cubit.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/session_detail_fixture.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'paged detail preserves pending, filters and reloads finalized corrections',
    () async {
      final fixture = SessionDetailFixture();
      final client = fixture.client();
      final cubit = SessionDetailCubit(
        SessionDetailRepository(TeacherReadClient(client)),
        'session-a',
      );
      addTearDown(() async {
        await cubit.close();
        await client.dispose();
      });
      await cubit.load();
      expect(cubit.state.rows.single.status, AttendanceStatus.notMarked);
      expect(cubit.state.detail!.session.finalizedAt, isNotNull);
      await cubit.load(more: true);
      expect(cubit.state.rows.length, 2);
      expect(cubit.state.nextCursor, isNull);
      expect(fixture.requests.last['p_cursor'], 'row-a');
      await cubit.load(status: 'absent');
      expect(cubit.state.rows, isEmpty);
      expect(cubit.state.detail!.counts.notMarked, 1);
      fixture.corrected = true;
      fixture.cancelled = true;
      await cubit.load(status: 'excused');
      expect(cubit.state.rows.single.marker, 'Secretary A');
      expect(cubit.state.detail!.counts.notMarked, 0);
      expect(cubit.state.detail!.cancelReason, 'Retained history');
      expect(cubit.state.rows.single.status, AttendanceStatus.excused);
      await cubit.refresh();
      expect(fixture.requests.last['p_cursor'], isNull);
    },
  );
  test('invalid parameters and malformed responses fail safely', () async {
    final client = readFixture(
      (r) async => jsonResponse(r, {'attendance': []}),
    );
    addTearDown(client.dispose);
    final repo = SessionDetailRepository(TeacherReadClient(client));
    await expectLater(
      repo.load('session-a', status: 'unknown'),
      throwsA(isA<BackendFailure>()),
    );
    await expectLater(repo.load('session-a'), throwsA(isA<BackendFailure>()));
  });
}
