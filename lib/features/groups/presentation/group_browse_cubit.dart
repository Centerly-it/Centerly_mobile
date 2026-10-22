import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/backend_failure.dart';
import '../data/group_repository.dart';
import 'group_browse_state.dart';

class GroupBrowseCubit extends Cubit<GroupBrowseState> {
  GroupBrowseCubit(this.repository) : super(const GroupBrowseState());
  final GroupRepository repository;
  int _generation = 0;
  Future<void> search(
    String value, {
    String? gradeId,
    bool refresh = false,
  }) async {
    final generation = ++_generation;
    emit(
      GroupBrowseState(search: value.trim(), gradeId: gradeId, loading: true),
    );
    await _load(generation, refresh: refresh);
  }

  Future<void> refresh() =>
      search(state.search, gradeId: state.gradeId, refresh: true);
  Future<void> next() async {
    if (state.loading || state.cursor == null) return;
    final before = state;
    emit(
      GroupBrowseState(
        groups: before.groups,
        search: before.search,
        gradeId: before.gradeId,
        cursor: before.cursor,
        loading: true,
      ),
    );
    await _load(_generation, cursor: before.cursor);
  }

  Future<void> _load(
    int generation, {
    String? cursor,
    bool refresh = false,
  }) async {
    final request = state;
    try {
      final page = await repository.list(
        search: request.search,
        gradeId: request.gradeId,
        cursor: cursor,
        refresh: refresh,
      );
      if (isClosed || generation != _generation) return;
      final groups = {
        for (final group in [...request.groups, ...page.groups])
          group.id: group,
      };
      emit(
        GroupBrowseState(
          groups: List.unmodifiable(groups.values),
          search: request.search,
          gradeId: request.gradeId,
          cursor: page.nextCursor,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        GroupBrowseState(
          groups: error is BackendFailure && error.deniesAccess
              ? const []
              : request.groups,
          search: request.search,
          gradeId: request.gradeId,
          cursor: error is BackendFailure && error.deniesAccess
              ? null
              : request.cursor,
          error: error is BackendFailure ? error.code : 'SERVICE_UNAVAILABLE',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
