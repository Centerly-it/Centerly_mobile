import '../api/teacher_read_client.dart';
import '../errors/backend_failure.dart';
import 'read_page.dart';
import 'keyset_page.dart';

class CompletionReads {
  const CompletionReads(this.api);
  final TeacherReadClient api;
  Future<ReadPage<T, S>> page<T, S>(
    TeacherRead endpoint, {
    Map<String, dynamic> params = const {},
    required T Function(Map<String, dynamic>) row,
    required S Function(Map<String, dynamic>) summary,
    String rowsKey = 'rows',
    String countKey = 'total_count',
  }) async {
    final result = await api.read(endpoint, params: params, refresh: true);
    try {
      final data = readMap(result);
      final items = (data[rowsKey] as List)
          .map((r) => row(readMap(r)))
          .toList();
      final cursor = data['next_cursor'] as String?;
      final ids = (data[rowsKey] as List)
          .map((r) => r['id'] as String)
          .toList();
      validateKeysetPage(
        ids,
        limit: params['p_limit'] as int? ?? 30,
        cursor: params['p_cursor'] as String?,
      );
      if (cursor != null && (ids.isEmpty || cursor != ids.last)) {
        throw const FormatException('Invalid next cursor');
      }
      final count = readCount(data[countKey]);
      if (items.length > (params['p_limit'] as int? ?? 30) ||
          items.length > count ||
          (cursor != null && (items.isEmpty || cursor == params['p_cursor']))) {
        throw const FormatException('Invalid page');
      }
      return ReadPage(
        rows: List.unmodifiable(items),
        summary: summary(data),
        total: count,
        cursor: cursor,
        syncedAt: DateTime.parse(data['synced_at'] as String).toUtc(),
      );
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
