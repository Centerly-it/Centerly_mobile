import 'dart:developer';
import 'package:centrally/core/api/api_constants.dart';
import 'package:centrally/core/api/token_manager.dart';
import 'package:centrally/features/auth/data/model/login_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class RefreshTokenService {
  RefreshTokenService(this._tokenManager, @Named('plainDio') this._plainDio);

  final TokenManager _tokenManager;
  final Dio _plainDio; // no interceptors

  /// Returns new accessToken on success, null on failure .
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log('no refresh token found', name: 'RefreshTokenService');
        return null;
      }

      final response = await _plainDio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {ApiConstants.refreshTokenKey: refreshToken},
      );

      final model = LoginModel.fromJson(response.data as Map<String, dynamic>);

      final newAccessToken = model.accessToken ?? '';
      if (newAccessToken.isEmpty) {
        log('empty accessToken in response', name: 'RefreshTokenService');
        return null;
      }

      // Save new tokens
      await _tokenManager.saveTokens(
        accessToken: newAccessToken,
        refreshToken: model.refreshToken ?? refreshToken,
        role: model.role ?? '',
        teacherId: model.teacherId ?? '',
      );

      log('token refreshed successfully', name: 'RefreshTokenService');
      return newAccessToken;
    } on DioException catch (e) {
      log(
        'refresh failed status: ${e.response?.statusCode}',
        name: 'RefreshTokenService',
      );
      return null;
    } catch (_) {
      log('unexpected refresh failure', name: 'RefreshTokenService');
      return null;
    }
  }
}
