import 'package:flutter_bloc/flutter_bloc.dart';
import 'paged_read_state.dart';
import 'page_loader.dart';
export 'page_loader.dart';
import 'validate_cursor_batch.dart';

class PagedReadCubit<T, S> extends Cubit<PagedReadState<T, S>> {
  PagedReadCubit(
    this.loader,
    this.identity, {
    Map<String, dynamic> filters = const {},
    this.freshLoader,
    this.onState,
  }) : filters = Map.unmodifiable(filters),
       super(const PagedReadState());
  final void Function(PagedReadState<T, S>)? onState;
  @override
  void emit(PagedReadState<T, S> state) {
    super.emit(state);
    onState?.call(state);
  }

  final PageLoader<T, S> loader;
  final FreshPageLoader<T, S>? freshLoader;
  final String Function(T) identity;
  Map<String, dynamic> filters;
  int _generation = 0;
  Map<String, dynamic> _displayedFilters = const {};
  final _seenCursors = <String>{};
  final _loadedIds = <String>{};
  Future<void> apply(Map<String, dynamic> value, {bool retain = false}) {
    filters = Map.unmodifiable(value);
    return _load(false, retain: retain);
  }

  Future<void> refresh() => _load(false, retain: true, fresh: true);
  Future<void> next() => _load(true, retain: true);
  Future<void> _load(
    bool more, {
    bool retain = false,
    bool fresh = false,
  }) async {
    if (isClosed || (more && (state.loading || state.cursor == null))) return;
    final previous = state;
    final ticket = ++_generation;
    final query = filters;
    emit(
      PagedReadState(
        page: retain ? previous.page : null,
        rows: retain ? previous.rows : const [],
        loading: true,
        refreshing: !more && retain && previous.page != null,
        loadingMore: more,
        cursor: retain ? previous.cursor : null,
      ),
    );
    try {
      final cursor = more ? previous.cursor : null;
      final page =
          await (freshLoader?.call(query, cursor, fresh) ??
              loader(query, cursor));
      if (isClosed || ticket != _generation) return;
      final rows = [if (more) ...previous.rows, ...page.rows];
      final incoming = validateCursorBatch(
        page.rows.map(identity),
        page.rows.length,
        page.cursor,
        requested: cursor,
        seen: more ? _seenCursors : const {},
        loaded: more ? _loadedIds : const {},
      );
      if (!more) {
        _seenCursors.clear();
        _loadedIds.clear();
      }
      _displayedFilters = query;
      _loadedIds.addAll(incoming);
      if (page.cursor != null) _seenCursors.add(page.cursor!);
      emit(
        PagedReadState(
          page: page,
          rows: List.unmodifiable(rows),
          cursor: page.cursor,
        ),
      );
    } catch (error) {
      if (isClosed || ticket != _generation) return;
      if (retain && previous.page != null) filters = _displayedFilters;
      emit(PagedReadState.failure(previous, error, retain: retain, more: more));
    }
  }

  @override
  Future<void> close() {
    ++_generation;
    return super.close();
  }
}
