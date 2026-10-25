import 'dart:async';
import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/presentation/paged_read_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

ReadPage<String, int> batch(List<String> rows, [String? next]) => ReadPage(
  rows: rows,
  summary: 42,
  total: 100,
  syncedAt: DateTime.utc(2026),
  cursor: next,
);
void main() {
  test(
    'refresh retains content, bypasses cache and retries the first page',
    () async {
      var fail = false;
      final gate = Completer<void>();
      final modes = <bool>[];
      final cubit = PagedReadCubit<String, int>(
        (_, c) async => batch(['a'], 'next'),
        (r) => r,
        freshLoader: (_, c, fresh) async {
          modes.add(fresh);
          if (fail) {
            await gate.future;
            throw Exception('offline');
          }
          return batch(['a'], 'next');
        },
      );
      addTearDown(cubit.close);
      await cubit.apply({});
      fail = true;
      final work = cubit.refresh();
      expect(cubit.state.refreshing, isTrue);
      expect(cubit.state.rows, ['a']);
      gate.complete();
      await work;
      expect(cubit.state.rows, ['a']);
      expect(cubit.state.retryMore, isFalse);
      expect(cubit.state.error, isTrue);
      fail = false;
      await cubit.refresh();
      expect(modes, [false, true, true]);
      expect(cubit.state.page!.total, 100);
    },
  );
  test(
    'rejects looping cursor without losing prior pages; next retries safely',
    () async {
      var invalid = true;
      final cubit = PagedReadCubit<String, int>(
        (_, c) async => c == null
            ? batch(['a'], 'opaque')
            : invalid
            ? batch(['b'], 'opaque')
            : batch(['b']),
        (r) => r,
      );
      addTearDown(cubit.close);
      await cubit.refresh();
      await cubit.next();
      expect(cubit.state.retryMore, isTrue);
      expect(cubit.state.rows, ['a']);
      invalid = false;
      await cubit.next();
      expect(cubit.state.rows, ['a', 'b']);
      expect(cubit.state.cursor, isNull);
    },
  );
  test('disposal invalidates late responses and makes next inert', () async {
    final gate = Completer<ReadPage<String, int>>();
    final cubit = PagedReadCubit<String, int>((_, c) => gate.future, (r) => r);
    final work = cubit.refresh();
    await cubit.close();
    gate.complete(batch(['late']));
    await work;
    await cubit.next();
    expect(cubit.state.rows, isEmpty);
  });
}
