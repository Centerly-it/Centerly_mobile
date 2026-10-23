import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/backend_failure.dart';
import '../data/student_repository.dart';
import 'student_browse_state.dart';

class StudentBrowseCubit extends Cubit<StudentBrowseState> {
  StudentBrowseCubit(this.repository, {this.groupId})
    : super(const StudentBrowseState());
  final StudentRepository repository;
  String? groupId;
  bool archived = false;
  Future<void> showArchived(bool value) {
    archived = value;
    groupId = null;
    return refresh();
  }

  Future<void> filterGroup(String? id) {
    groupId = id;
    return search(state.search);
  }

  int _generation = 0;
  Future<void> search(String value, {bool refresh = false}) async {
    final generation = ++_generation;
    emit(StudentBrowseState(search: value.trim(), loading: true));
    await _load(generation, refresh: refresh);
  }

  Future<void> refresh() => search(state.search, refresh: true);
  Future<void> next() async {
    if (state.loading || state.cursor == null) return;
    final before = state;
    emit(
      StudentBrowseState(
        students: before.students,
        search: before.search,
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
        groupId: groupId,
        cursor: cursor,
        refresh: refresh,
        archived: archived,
      );
      if (isClosed || generation != _generation) return;
      final rows = {
        for (final student in [...request.students, ...page.students])
          student.id: student,
      };
      emit(
        StudentBrowseState(
          students: List.unmodifiable(rows.values),
          search: request.search,
          cursor: page.nextCursor,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        StudentBrowseState(
          students: error is BackendFailure && error.deniesAccess
              ? const []
              : request.students,
          search: request.search,
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
