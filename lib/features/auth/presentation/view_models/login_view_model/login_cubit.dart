import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:centrally/core/api/token_manager.dart';
import 'package:centrally/core/common/api_result.dart';
import 'package:centrally/features/auth/domain/entities/login_entity.dart';
import 'package:centrally/features/auth/domain/usecases/login_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final TokenManager _tokenManager;

  LoginCubit(this._loginUseCase, this._tokenManager)
    : super(const LoginState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    final result = await _loginUseCase.call(email, password);
    switch (result) {
      case Success<LoginEntity>():
        await _tokenManager.saveTokens(
          accessToken: result.data.accessToken,
          refreshToken: result.data.refreshToken,
          role: result.data.role,
          teacherId: result.data.teacherId,
        );

        log('login success | role: ${result.data.role}', name: 'LoginCubit');
        emit(LoginState.success(result.data));

        break;
      case Failure<LoginEntity>():
        emit(LoginState.failure(result.exception.toString()));
        log('login failure', name: 'LoginCubit');
        break;
    }
  }
}
