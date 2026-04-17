import 'package:centrally/core/api/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
@injectable
class ApiManager {
  late Dio _dio;
  ApiManager() {
    _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  }
  // Exception handleDioError(DioException e) {
  //   return ServerError(
  //     e.response?.statusCode,
  //     e.response?.data['message'] ?? 'Unknown Error',
  //   );
  // }
}
