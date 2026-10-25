import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/backend_failure.dart';
import '../data/session_detail_repository.dart';
import 'session_detail_state.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit(this.repository, this.id)
    : super(const SessionDetailState());
  final SessionDetailRepository repository;
  final String id;
  int _request = 0;
  Future<void> load({String? status, bool more = false}) async {
    if (more && (state.loading || state.nextCursor == null)) return;
    final previous = state;
    final ticket = ++_request;
    final filter = more ? previous.status : status;
    emit(
      SessionDetailState(
        // Keep the current page mounted while refreshing or changing filters.
        // Replacing it with a full-screen loader resets the scroll position.
        detail: previous.detail,
        rows: previous.rows,
        status: filter,
        loading: true,
        nextCursor: previous.nextCursor,
      ),
    );
    try {
      final detail = await repository.load(
        id,
        status: filter,
        cursor: more ? previous.nextCursor : null,
        refresh: true,
      );
      if (isClosed || ticket != _request) return;
      final rows = [if (more) ...previous.rows, ...detail.rows];
      if (rows.map((r) => r.id).toSet().length != rows.length) {
        throw const BackendFailure('SERVICE_UNAVAILABLE');
      }
      emit(
        SessionDetailState(
          detail: detail,
          rows: List.unmodifiable(rows),
          status: filter,
          nextCursor: detail.nextCursor,
        ),
      );
    } catch (_) {
      if (isClosed || ticket != _request) return;
      emit(
        SessionDetailState(
          detail: previous.detail,
          rows: previous.rows,
          status: previous.status,
          error: true,
          nextCursor: previous.nextCursor,
        ),
      );
    }
  }

  Future<void> refresh() => load(status: state.status);
}
