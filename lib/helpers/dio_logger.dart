import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_logger.dart';

class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      ApiLogger.logRequest(
        method: options.method,
        url: options.uri.toString(),
        headers: options.headers.cast<String, String>(),
        body: options.data,
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      ApiLogger.logResponse(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode ?? 0,
        body: response.data?.toString() ?? '',
        duration: null, // Dio doesn't provide this easily
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      ApiLogger.logError(
        method: err.requestOptions.method,
        url: err.requestOptions.uri.toString(),
        error: err.toString(),
      );
    }
    super.onError(err, handler);
  }
}