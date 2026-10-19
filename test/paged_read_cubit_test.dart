import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/presentation/paged_read_cubit.dart';
import 'package:centrally/core/errors/backend_failure.dart';

ReadPage<String, int> page(List<String> rows, {String? cursor}) => ReadPage(
  rows: rows,
  summary: 0,
  total: 3,
  syncedAt: DateTime.utc(2026),
  cursor: cursor,
);
void main() {
  test('late filters, duplicate pages and refresh are guarded', () async {
    final delayed = Completer<ReadPage<String, int>>();
    final cubit = PagedReadCubit<String, int>((filters, cursor) async {
      if (filters['slow'] == true) return delayed.future;
      return page(['current'], cursor: 'current');
    }, (r) => r);
    addTearDown(cubit.close);
    final slow = cubit.apply({'slow': true});
    await cubit.apply({'slow': false});
    delayed.complete(page(['stale']));
    await slow;
    expect(cubit.state.rows, ['current']);
    await cubit.next();
    expect(cubit.state.error, isTrue);
    expect(cubit.state.rows, ['current']);
    await cubit.refresh();
    expect(cubit.state.error, isFalse);
    expect(cubit.state.rows, ['current']);
  });
  test(
    'duplicate taps make one page request; access denial clears sensitive rows',
    () async {
      final delayed = Completer<ReadPage<String, int>>();
      var count = 0;
      final cubit = PagedReadCubit<String, int>((filters, cursor) async {
        count++;
        if (cursor == null) return page(['private'], cursor: 'next');
        await delayed.future;
        throw const BackendFailure('ACCOUNT_INACTIVE');
      }, (r) => r);
      addTearDown(cubit.close);
      await cubit.refresh();
      final pending = cubit.next();
      await cubit.next();
      expect(count, 2);
      delayed.complete(page([]));
      await pending;
      expect(cubit.state.rows, isEmpty);
      expect(cubit.state.error, isTrue);
    },
  );
}
