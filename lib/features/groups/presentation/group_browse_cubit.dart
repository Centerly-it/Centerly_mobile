import '../../../core/data/read_page.dart';
import '../../../core/presentation/mapped_paged_cubit.dart';
import '../data/group_repository.dart';
import '../domain/group_record.dart';
import 'group_browse_state.dart';

class GroupBrowseCubit
    extends MappedPagedCubit<GroupRecord, NoSummary, GroupBrowseState> {
  GroupBrowseCubit(this.repository) : super(const GroupBrowseState()) {
    configure(
      (f, c) => _page(f, c, false),
      (r) => r.id,
      (s, f) => GroupBrowseState(
        groups: s.rows,
        search: f['search'] as String? ?? '',
        gradeId: f['grade'] as String?,
        cursor: s.cursor,
        loading: s.loading,
        error: s.errorCode,
        retryMore: s.retryMore,
      ),
      freshLoader: _page,
    );
  }
  final GroupRepository repository;
  Future<ReadPage<GroupRecord, NoSummary>> _page(
    Map<String, dynamic> f,
    String? cursor,
    bool refresh,
  ) async {
    final result = await repository.list(
      search: f['search'] as String?,
      gradeId: f['grade'] as String?,
      cursor: cursor,
      refresh: refresh,
    );
    // Directory endpoint has no server total or summary; neither is displayed.
    return ReadPage(
      rows: result.groups,
      summary: const NoSummary(),
      total: 0,
      syncedAt: DateTime.now().toUtc(),
      cursor: result.nextCursor,
    );
  }

  Future<void> search(String value, {String? gradeId, bool refresh = false}) {
    final query = {'search': value.trim(), 'grade': gradeId};
    if (refresh && query.toString() == pages.filters.toString()) {
      return pages.refresh();
    }
    return pages.apply(query);
  }

  Future<void> refresh() => pages.refresh();
  Future<void> next() => pages.next();
}
