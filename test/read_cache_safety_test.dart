import 'dart:async';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/api/teacher_read_policy.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/core/network/read_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/scoped_read_fixture.dart';

void main() {
  test('volatile data never uses completed TTL cache', () async {
    var calls = 0;
    final client = scopedReadFixture(
      (r) async => jsonResponse(r, {'revision': ++calls}),
    );
    addTearDown(client.dispose);
    await signInReadFixture(client);
    final api = TeacherReadClient(client);
    for (final endpoint in [
      TeacherRead.finance,
      TeacherRead.overview,
      TeacherRead.sessionDetail,
      TeacherRead.studentAttendance,
      TeacherRead.notifications,
      TeacherRead.secretaries,
    ]) {
      final before = calls;
      await api.read(endpoint);
      await api.read(endpoint);
      expect(calls - before, 2);
    }
    expect(api.cache.entryCount, 0);
  });
  test(
    '30 simultaneous reads share one request and independent returned objects',
    () async {
      var calls = 0;
      final started = Completer<void>(), release = Completer<void>();
      final client = scopedReadFixture((r) async {
        calls++;
        started.complete();
        await release.future;
        return jsonResponse(r, {
          'rows': [1, 2],
        });
      });
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final api = TeacherReadClient(client);
      final reads = List.generate(
        30,
        (_) => api.read(TeacherRead.finance, refresh: true),
      );
      await started.future;
      release.complete();
      final values = await Future.wait(reads);
      expect(calls, 1);
      (values.first['rows'] as List).clear();
      expect(values.last['rows'], [1, 2]);
    },
  );
  test(
    'canonical parameter order, mutation isolation and forced refresh',
    () async {
      var calls = 0;
      final client = scopedReadFixture(
        (r) async => jsonResponse(r, {'revision': ++calls}),
      );
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final api = TeacherReadClient(client);
      final first = await api.read(
        TeacherRead.groups,
        params: {'p_limit': 30, 'p_search': 'A'},
      );
      first['revision'] = 999;
      final next = await api.read(
        TeacherRead.groups,
        params: {'p_search': 'A', 'p_limit': 30},
      );
      expect(calls, 1);
      expect(next['revision'], 1);
      await api.read(
        TeacherRead.groups,
        params: {'p_limit': 30, 'p_search': 'A'},
        refresh: true,
      );
      expect(calls, 2);
    },
  );
  test(
    'token rotation discards cached data even for the same teacher',
    () async {
      var calls = 0;
      final client = scopedReadFixture(
        (r) async => jsonResponse(r, {'revision': ++calls}),
      );
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final api = TeacherReadClient(client);
      await api.read(TeacherRead.groups);
      await client.auth.refreshSession();
      expect((await api.read(TeacherRead.groups))['revision'], 2);
    },
  );
  test(
    'explicit invalidation detaches an old flight without losing its replacement',
    () async {
      var calls = 0;
      final started = Completer<void>(), release = Completer<void>();
      final client = scopedReadFixture((r) async {
        final n = ++calls;
        if (n == 1) {
          started.complete();
          await release.future;
        }
        return jsonResponse(r, {'revision': n});
      });
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final api = TeacherReadClient(client);
      final old = api.read(TeacherRead.groups);
      final rejection = expectLater(old, throwsA(isA<BackendFailure>()));
      await started.future;
      api.invalidate();
      expect((await api.read(TeacherRead.groups))['revision'], 2);
      release.complete();
      await rejection;
      expect((await api.read(TeacherRead.groups))['revision'], 2);
      expect(calls, 2);
    },
  );
  test('shared cache cannot leak across two Supabase projects', () async {
    final cache = ReadCache();
    var a = 0, b = 0;
    final first = scopedReadFixture(
      (r) async => jsonResponse(r, {'source': 'a', 'call': ++a}),
    );
    final second = scopedReadFixture(
      (r) async => jsonResponse(r, {'source': 'b', 'call': ++b}),
      project: 'https://other.test',
    );
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await signInReadFixture(first);
    await signInReadFixture(second);
    final apiA = TeacherReadClient(first, cache: cache),
        apiB = TeacherReadClient(second, cache: cache);
    expect((await apiA.read(TeacherRead.groups))['source'], 'a');
    expect((await apiB.read(TeacherRead.groups))['source'], 'b');
    expect((await apiA.read(TeacherRead.groups))['source'], 'a');
    expect(a, 2);
    expect(b, 1);
  });
  test(
    'LRU, byte bounds, oversize entries, replacement and clock rollback',
    () {
      var now = DateTime.utc(2026);
      final cache = ReadCache(
        now: () => now,
        maxEntries: 2,
        maxBytes: 100,
        maxEntryBytes: 60,
      );
      cache.put('a', 1);
      cache.put('b', 2);
      cache.get('a');
      cache.put('c', 3);
      expect(cache.get('b'), isNull);
      cache.put('a', 4);
      expect(cache.get('c'), 3);
      expect(cache.entryCount, 2);
      cache.put('big', List.filled(1000, 'x'));
      expect(cache.get('big'), isNull);
      expect(cache.sizeBytes, lessThanOrEqualTo(100));
      now = now.subtract(const Duration(seconds: 1));
      expect(cache.get('a'), isNull);
      cache.clear();
      expect(cache.sizeBytes, 0);
    },
  );
  test('TTL policy permits only explicitly selected stable endpoints', () {
    for (final endpoint in TeacherRead.values) {
      expect(
        teacherReadTtl(endpoint) > Duration.zero,
        [
          TeacherRead.groups,
          TeacherRead.students,
          TeacherRead.studentProfile,
          TeacherRead.academics,
        ].contains(endpoint),
      );
    }
  });
  test(
    'RPC parameter snapshot cannot be mutated into a different cache entry',
    () async {
      final client = scopedReadFixture((r) async {
        return jsonResponse(r, {'params': r.body});
      });
      addTearDown(client.dispose);
      await signInReadFixture(client);
      final api = TeacherReadClient(client);
      final params = <String, dynamic>{'p_search': 'original'};
      final pending = api.read(TeacherRead.groups, params: params);
      params['p_search'] = 'changed';
      expect((await pending)['params'], contains('original'));
      expect(
        (await api.read(
          TeacherRead.groups,
          params: {'p_search': 'original'},
        ))['params'],
        contains('original'),
      );
    },
  );
  test('byte budget evicts LRU payloads independently of entry count', () {
    final cache = ReadCache(maxEntries: 10, maxBytes: 20, maxEntryBytes: 20);
    cache.put('a', '12345678');
    cache.put('b', '12345678');
    expect(cache.sizeBytes, 20);
    cache.put('b', '123456789012');
    expect(cache.get('a'), isNull);
    expect(cache.entryCount, 1);
    expect(cache.sizeBytes, 14);
  });
}
