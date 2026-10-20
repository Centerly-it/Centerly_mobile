import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:centrally/core/api/token_manager.dart';
import 'package:centrally/core/common/api_result.dart';
import 'package:centrally/features/auth/domain/entities/logout_entity.dart';
import 'package:centrally/features/auth/domain/usecases/logout_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'logout_state.dart';
part 'logout_cubit.freezed.dart';

@injectable
class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUsecase logoutUsecase;
  final TokenManager _tokenManager;
  LogoutCubit(this.logoutUsecase, this._tokenManager)
    : super(const LogoutState.initial());
  Future<void> logout(String refreshToken) async {
    emit(const LogoutState.loading());
    final result = await logoutUsecase.call(refreshToken);
    switch (result) {
      case Success<LogoutEntity>():
        await _tokenManager.clearAll();
        emit(LogoutState.success(result.data));
        break;
      case Failure<LogoutEntity>():
        await _tokenManager.clearAll();
        log('logout failure', name: 'LogoutCubit');
        emit(LogoutState.failure(result.exception.toString()));
        break;
    }
  }
}
