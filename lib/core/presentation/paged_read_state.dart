import '../errors/backend_failure.dart';
import '../data/read_page.dart';

class PagedReadState<T, S> {
  const PagedReadState({
    this.page,
    this.rows = const [],
    this.loading = false,
    this.error = false,
    this.cursor,
    this.refreshing = false,
    this.loadingMore = false,
    this.errorCode,
    this.retryMore = false,
  });
  factory PagedReadState.failure(
    PagedReadState<T, S> previous,
    Object error, {
    required bool retain,
    required bool more,
  }) {
    final keep = retain && !(error is BackendFailure && error.deniesAccess);
    return PagedReadState(
      page: keep ? previous.page : null,
      rows: keep ? previous.rows : const [],
      cursor: keep ? previous.cursor : null,
      error: true,
      retryMore: more,
      errorCode: error is BackendFailure ? error.code : 'SERVICE_UNAVAILABLE',
    );
  }
  final ReadPage<T, S>? page;
  final List<T> rows;
  final bool loading, error, refreshing, loadingMore, retryMore;
  final String? errorCode;
  bool get initialLoading => loading && page == null;
  final String? cursor;
}
