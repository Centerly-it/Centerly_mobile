import 'dart:async';
import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/sessions/data/session_detail_repository.dart';
import 'package:centrally/features/sessions/presentation/session_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/session_detail_fixture.dart';

void main() {
  test('late filter result cannot replace a newer selection', () async {
    final gate = Completer<void>();
    final fixture = SessionDetailFixture();
    final client = readFixture((r) async {
      final p = jsonDecode(r.body) as Map;
      if (p['p_status'] == null) await gate.future;
      return jsonResponse(
        r,
        fixture.response(status: p['p_status'] as String?),
      );
    });
    final cubit = SessionDetailCubit(
      SessionDetailRepository(TeacherReadClient(client)),
      'session-a',
    );
    addTearDown(() async {
      await cubit.close();
      await client.dispose();
    });
    final first = cubit.load();
    await Future<void>.delayed(Duration.zero);
    await cubit.load(status: 'absent');
    gate.complete();
    await first;
    expect(cubit.state.status, 'absent');
    expect(cubit.state.rows, isEmpty);
  });
  test(
    'duplicate page fails safely and refresh replaces accumulated rows',
    () async {
      final fixture = SessionDetailFixture();
      final client = readFixture(
        (r) async => jsonResponse(r, fixture.response()),
      );
      final cubit = SessionDetailCubit(
        SessionDetailRepository(TeacherReadClient(client)),
        'session-a',
      );
      addTearDown(() async {
        await cubit.close();
        await client.dispose();
      });
      await cubit.load();
      await cubit.load(more: true);
      expect(cubit.state.error, isTrue);
      expect(cubit.state.rows.length, 1);
      await cubit.refresh();
      expect(cubit.state.error, isFalse);
      expect(cubit.state.rows.length, 1);
    },
  );
  test(
    'access denial invalidates cached reads and triggers revalidation',
    () async {
      var denied = false;
      final client = readFixture(
        (r) async => jsonResponse(r, {
          'code': 'P0001',
          'message': 'ACCOUNT_INACTIVE',
        }, status: 400),
      );
      final api = TeacherReadClient(
        client,
        onAccessDenied: () async {
          denied = true;
        },
      );
      final cubit = SessionDetailCubit(
        SessionDetailRepository(api),
        'session-a',
      );
      addTearDown(() async {
        await cubit.close();
        await client.dispose();
      });
      await cubit.load();
      expect(cubit.state.error, isTrue);
      expect(cubit.state.rows, isEmpty);
      expect(denied, isTrue);
      expect(api.cache.generation, greaterThan(0));
    },
  );
}
