import 'package:centrally/core/api/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ApiManager {
  final Dio _dio;

  ApiManager() : _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Dio get dio => _dio;
}
