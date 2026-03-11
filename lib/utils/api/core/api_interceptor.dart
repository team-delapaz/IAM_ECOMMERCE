import 'package:dio/dio.dart';

import 'package:iam_ecomm/utils/logging/logger.dart';

class ApiInterceptor extends Interceptor {
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    IAMLogger.warning('API error: ${err.requestOptions.uri} ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
