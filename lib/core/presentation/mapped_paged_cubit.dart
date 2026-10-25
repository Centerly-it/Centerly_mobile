import 'package:flutter_bloc/flutter_bloc.dart';
import 'paged_read_cubit.dart';
import 'paged_read_state.dart';

/// Feature state adapters share one request/pagination implementation.
abstract class MappedPagedCubit<T, S, V> extends Cubit<V> {
  MappedPagedCubit(super.initialState);
  late final PagedReadCubit<T, S> pages;
  void configure(
    PageLoader<T, S> loader,
    String Function(T) identity,
    V Function(PagedReadState<T, S>, Map<String, dynamic>) map, {
    FreshPageLoader<T, S>? freshLoader,
  }) {
    pages = PagedReadCubit(
      loader,
      identity,
      freshLoader: freshLoader,
      onState: (state) {
        if (!isClosed) emit(map(state, pages.filters));
      },
    );
  }

  @override
  Future<void> close() async {
    await pages.close();
    return super.close();
  }
}
