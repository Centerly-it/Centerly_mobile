import 'package:centrally/core/api/api_constants.dart';
import 'package:centrally/core/api/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio providerDio() {
    final Dio dio = Dio();
    return dio;
  }

  // ── Plain Dio: no interceptor ─────────────
  @Named('plainDio')
  @singleton
  Dio providePlainDio() => Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // ── Main Dio: AuthInterceptor + logger ───────────────────
  @Named('mainDio')
  @singleton
  Dio provideMainDio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.add(authInterceptor);
    DioRetryClient.instance = dio;
    return dio;
  }
}
