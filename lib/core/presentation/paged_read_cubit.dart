import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/read_page.dart';
import '../errors/backend_failure.dart';
import 'paged_read_state.dart';

typedef PageLoader<T, S> =
    Future<ReadPage<T, S>> Function(
      Map<String, dynamic> filters,
      String? cursor,
    );

class PagedReadCubit<T, S> extends Cubit<PagedReadState<T, S>> {
  PagedReadCubit(
    this.loader,
    this.identity, {
    Map<String, dynamic> filters = const {},
  }) : filters = Map.unmodifiable(filters),
       super(const PagedReadState());
  final PageLoader<T, S> loader;
  final String Function(T) identity;
  Map<String, dynamic> filters;
  int _generation = 0;
  Future<void> apply(Map<String, dynamic> value) {
    filters = Map.unmodifiable(value);
    return refresh();
  }

  Future<void> refresh() => _load(false);
  Future<void> next() => _load(true);
  Future<void> _load(bool more) async {
    if (more && (state.loading || state.cursor == null)) return;
    final previous = state;
    final ticket = ++_generation;
    emit(
      PagedReadState(
        page: more ? previous.page : null,
        rows: more ? previous.rows : const [],
        loading: true,
        cursor: more ? previous.cursor : null,
      ),
    );
    try {
      final page = await loader(filters, more ? previous.cursor : null);
      if (isClosed || ticket != _generation) return;
      final rows = [if (more) ...previous.rows, ...page.rows];
      if (rows.map(identity).toSet().length != rows.length) {
        throw const BackendFailure('SERVICE_UNAVAILABLE');
      }
      emit(
        PagedReadState(
          page: page,
          rows: List.unmodifiable(rows),
          cursor: page.cursor,
        ),
      );
    } catch (error) {
      if (isClosed || ticket != _generation) return;
      final retain = more && !(error is BackendFailure && error.deniesAccess);
      emit(
        PagedReadState(
          page: retain ? previous.page : null,
          rows: retain ? previous.rows : const [],
          cursor: retain ? previous.cursor : null,
          error: true,
        ),
      );
    }
  }
}
