import '../data/read_page.dart';

class PagedReadState<T, S> {
  const PagedReadState({
    this.page,
    this.rows = const [],
    this.loading = false,
    this.error = false,
    this.cursor,
  });
  final ReadPage<T, S>? page;
  final List<T> rows;
  final bool loading, error;
  final String? cursor;
}
