import 'package:dio/dio.dart';

class ServerError implements Exception {
  String? serverMessage;
  int? statusCode;
  ServerError({required this.statusCode, required this.serverMessage});
}

class DioHttpException implements Exception {
  DioException? exception;

  DioHttpException(this.exception);
}

class NoInternetError implements Exception {}
