import '../../../core/data/read_page.dart';
import '../../../core/presentation/mapped_paged_cubit.dart';
import '../data/session_detail_repository.dart';
import '../domain/attendance_record.dart';
import '../domain/session_detail.dart';
import 'session_detail_state.dart';

class SessionDetailCubit
    extends
        MappedPagedCubit<AttendanceRecord, SessionDetail, SessionDetailState> {
  SessionDetailCubit(this.repository, this.id)
    : super(const SessionDetailState()) {
    configure(
      (f, c) async {
        final detail = await repository.load(
          id,
          status: f['status'] as String?,
          cursor: c,
          refresh: true,
        );
        return ReadPage(
          rows: detail.rows,
          summary: detail,
          total: detail.filteredCount,
          syncedAt: detail.syncedAt,
          cursor: detail.nextCursor,
        );
      },
      (r) => r.id,
      (s, f) => SessionDetailState(
        detail: s.page?.summary,
        rows: s.rows,
        status: f['status'] as String?,
        loading: s.loading,
        error: s.error,
        retryMore: s.retryMore,
        nextCursor: s.cursor,
      ),
    );
  }
  final SessionDetailRepository repository;
  final String id;
  Future<void> load({String? status, bool more = false}) =>
      more ? pages.next() : pages.apply({'status': status}, retain: true);
  Future<void> refresh() => pages.refresh();
}
