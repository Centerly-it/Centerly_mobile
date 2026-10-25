import '../../../core/data/read_page.dart';
import '../../../core/presentation/mapped_paged_cubit.dart';
import '../data/student_repository.dart';
import '../domain/student_record.dart';
import 'student_browse_state.dart';

class StudentBrowseCubit
    extends MappedPagedCubit<StudentRecord, NoSummary, StudentBrowseState> {
  StudentBrowseCubit(this.repository, {this.groupId})
    : super(const StudentBrowseState()) {
    configure(
      (f, c) => _page(f, c, false),
      (r) => r.id,
      (s, f) => StudentBrowseState(
        students: s.rows,
        search: f['search'] as String? ?? '',
        cursor: s.cursor,
        loading: s.loading,
        error: s.errorCode,
        retryMore: s.retryMore,
      ),
      freshLoader: _page,
    );
  }
  final StudentRepository repository;
  String? groupId;
  bool archived = false;
  Future<ReadPage<StudentRecord, NoSummary>> _page(
    Map<String, dynamic> f,
    String? cursor,
    bool refresh,
  ) async {
    final result = await repository.list(
      search: f['search'] as String?,
      groupId: f['group'] as String?,
      cursor: cursor,
      refresh: refresh,
      archived: f['archived'] == true,
    );
    return ReadPage(
      rows: result.students,
      summary: const NoSummary(),
      total: 0,
      syncedAt: DateTime.now().toUtc(),
      cursor: result.nextCursor,
    );
  }

  Future<void> showArchived(bool value) {
    archived = value;
    groupId = null;
    return search(state.search);
  }

  Future<void> filterGroup(String? id) {
    archived = false;
    groupId = id;
    return search(state.search);
  }

  Future<void> search(String value, {bool refresh = false}) {
    final query = {
      'search': value.trim(),
      'group': groupId,
      'archived': archived,
    };
    if (refresh && query.toString() == pages.filters.toString()) {
      return pages.refresh();
    }
    return pages.apply(query);
  }

  Future<void> refresh() => pages.refresh();
  Future<void> next() => pages.next();
}
