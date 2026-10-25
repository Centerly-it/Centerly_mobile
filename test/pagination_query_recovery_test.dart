import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/presentation/paged_read_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'failed retained filter restores the visible query before next/refresh',
    () async {
      final queries = <String>[];
      final cubit = PagedReadCubit<String, int>((f, c) async {
        queries.add(f['status'] as String);
        if (f['status'] == 'bad') throw Exception('offline');
        return ReadPage(
          rows: [c == null ? 'a' : 'b'],
          summary: 0,
          total: 2,
          syncedAt: DateTime.utc(2026),
          cursor: c == null ? 'next' : null,
        );
      }, (r) => r);
      addTearDown(cubit.close);
      await cubit.apply({'status': 'good'});
      await cubit.apply({'status': 'bad'}, retain: true);
      expect(cubit.state.rows, ['a']);
      expect(cubit.filters['status'], 'good');
      await cubit.next();
      expect(cubit.state.rows, ['a', 'b']);
      expect(queries, ['good', 'bad', 'good']);
    },
  );
}
