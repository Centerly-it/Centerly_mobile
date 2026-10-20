import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:centrally/core/common/api_result.dart';
import 'package:centrally/core/common/custom_exception.dart';
import 'package:dio/dio.dart';

Future<Result<T>> executeApi<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return Success(result);
  } on TimeoutException catch (_) {
    return const Failure(NoInternetException());
  } on DioException catch (ex) {
    final message = _extractMessage(ex);
    log(
      'DioException status: ${ex.response?.statusCode}',
      name: 'ApiExtension',
    );

    if (ex.response != null) {
      return Failure(
        ServerError(statusCode: ex.response?.statusCode, message: message),
      );
    }
    return Failure(DioHttpException(ex));
  } on IOException catch (_) {
    return const Failure(NoInternetException());
  } on Exception catch (ex) {
    return Failure(ex);
  }
}

// String _extractMessage(DioException ex) {
//   try {
//     final data = ex.response?.data;
//     if (data is Map<String, dynamic>) {
//       return (data['message'] as String?) ?? 'The server returned an error';
//     }
//     return 'The server returned an error';
//   } catch (_) {
//     return 'The server returned an error';
//   }
// }
String _extractMessage(DioException ex) {
  try {
    final data = ex.response?.data;
    if (data is Map<String, dynamic>) {
      final message =
          (data['message'] as String?) ??
          (data['error'] as String?) ??
          (data['title'] as String?);
      if (message != null && message.isNotEmpty) return message;
    }
    if (data is String && data.isNotEmpty) return data;
    return 'Unexpected server error (${ex.response?.statusCode})';
  } catch (_) {
    return 'Unexpected error occurred';
  }
}
