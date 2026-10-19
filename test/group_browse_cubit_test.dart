import 'dart:async';
import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/groups/data/group_repository.dart';
import 'package:centrally/features/groups/presentation/group_browse_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/group_read_fixture.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test('late search cannot overwrite a newer query', () async {
    final started = Completer<void>(), release = Completer<void>();
    final client = readFixture((request) async {
      final search = (jsonDecode(request.body) as Map)['p_search'];
      if (search == 'old') {
        started.complete();
        await release.future;
      }
      return jsonResponse(request, [groupJson(search as String)]);
    });
    final cubit = GroupBrowseCubit(GroupRepository(TeacherReadClient(client)));
    final old = cubit.search('old');
    await started.future;
    await cubit.search('new');
    release.complete();
    await old;
    expect(cubit.state.groups.single.id, 'new');
    await cubit.close();
    await client.dispose();
  });
  test(
    'pagination prevents duplicate taps and preserves a failed page for retry',
    () async {
      var calls = 0, fail = true;
      final client = readFixture((request) async {
        calls++;
        final cursor = (jsonDecode(request.body) as Map)['p_cursor'];
        if (cursor == null) {
          return jsonResponse(request, [
            for (var i = 0; i < 30; i++) groupJson('$i'),
          ]);
        }
        if (fail) {
          return jsonResponse(request, {'message': 'unavailable'}, status: 500);
        }
        return jsonResponse(request, [groupJson('30')]);
      });
      final cubit = GroupBrowseCubit(
        GroupRepository(TeacherReadClient(client)),
      );
      await cubit.search('');
      await Future.wait([cubit.next(), cubit.next()]);
      expect(calls, 2);
      expect(cubit.state.groups.length, 30);
      expect(cubit.state.error, 'SERVICE_UNAVAILABLE');
      fail = false;
      await cubit.next();
      expect(cubit.state.groups.length, 31);
      expect(cubit.state.cursor, isNull);
      await cubit.close();
      await client.dispose();
    },
  );
}
