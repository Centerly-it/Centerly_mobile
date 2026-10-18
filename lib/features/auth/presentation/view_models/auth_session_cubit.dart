import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repo/teacher_auth_repository.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(this.repository)
    : super(const AuthSessionState(AuthSessionStatus.checking)) {
    _subscription = repository.changes.listen(
      (_) {
        if (!_busy) unawaited(restore());
      },
      onError: (_) {
        if (!_busy) _signedOut('NETWORK_ERROR');
      },
    );
  }
  final TeacherAuthRepository repository;
  late final StreamSubscription<void> _subscription;
  bool _busy = false;
  int _generation = 0;
  Future<void> restore() async {
    if (_busy || isClosed) return;
    _busy = true;
    final generation = ++_generation;
    // Immediately gate cached screens while the live account is being checked.
    emit(const AuthSessionState(AuthSessionStatus.checking));
    try {
      final profile = await repository.restore();
      if (isClosed || generation != _generation) return;
      emit(
        AuthSessionState(
          profile == null
              ? AuthSessionStatus.signedOut
              : AuthSessionStatus.authenticated,
          profile: profile,
        ),
      );
    } catch (error) {
      if (!isClosed && generation == _generation) _signedOut(_code(error));
    } finally {
      _busy = false;
    }
  }

  Future<void> login(String email, String password) async {
    if (_busy) return;
    _busy = true;
    final generation = ++_generation;
    emit(const AuthSessionState(AuthSessionStatus.checking));
    try {
      final profile = await repository.login(email, password);
      if (!isClosed && generation == _generation) {
        emit(
          AuthSessionState(AuthSessionStatus.authenticated, profile: profile),
        );
      }
    } catch (error) {
      if (!isClosed && generation == _generation) _signedOut(_code(error));
    } finally {
      _busy = false;
    }
  }

  Future<void> logout() async {
    ++_generation;
    _busy = true;
    _signedOut(); // Hide protected UI before a possibly offline revocation request.
    try {
      await repository.logout();
    } finally {
      _busy = false;
    }
  }

  void _signedOut([String? code]) =>
      emit(AuthSessionState(AuthSessionStatus.signedOut, errorCode: code));
  String _code(Object error) =>
      error is TeacherAuthFailure ? error.code : 'SERVICE_UNAVAILABLE';
  @override
  Future<void> close() async {
    ++_generation;
    await _subscription.cancel();
    await super.close();
  }
}
