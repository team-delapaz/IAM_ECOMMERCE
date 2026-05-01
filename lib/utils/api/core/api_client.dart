import 'package:dio/dio.dart';

import 'api_interceptor.dart';
import 'api_response.dart';
import '../endpoints/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final ApiInterceptor _interceptor = ApiInterceptor();

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(_interceptor);
  }

  void setAuthToken(String? token) => _interceptor.setToken(token);
  bool get hasAuthToken => (_interceptor.token ?? '').isNotEmpty;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJsonData,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters);
      return _parseResponse(res, fromJsonData);
    } on DioException catch (e) {
      return _errorResponse<T>(e, fromJsonData);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJsonData,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _parseResponse(res, fromJsonData);
    } on DioException catch (e) {
      return _errorResponse<T>(e, fromJsonData);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJsonData,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _parseResponse(res, fromJsonData);
    } on DioException catch (e) {
      return _errorResponse<T>(e, fromJsonData);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJsonData,
  }) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _parseResponse(res, fromJsonData);
    } on DioException catch (e) {
      return _errorResponse<T>(e, fromJsonData);
    }
  }

  ApiResponse<T> _errorResponse<T>(DioException e, T? Function(dynamic)? fromJsonData) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, fromJsonData);
    }

    return ApiResponse<T>(
      status: e.response?.statusCode ?? 0,
      success: false,
      message: _friendlyErrorMessage(e),
      data: null,
    );
  }

  String _friendlyErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Oops, the page was unresponsive. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect right now. Please check your internet and try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      case DioExceptionType.badCertificate:
        return 'A secure connection could not be established. Please try again later.';
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        return e.response?.data?['message'] as String? ??
            e.message ??
            'Something went wrong. Please try again.';
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response<Map<String, dynamic>?> res,
    T? Function(dynamic)? fromJsonData,
  ) {
    final map = res.data;
    if (map == null) {
      return ApiResponse(status: res.statusCode ?? 0, success: false, message: 'No body', data: null);
    }
    return ApiResponse.fromJson(map, fromJsonData);
  }

  Future<ApiResponse<T>> request<T>(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJsonData,
  }) async {
    Response<Map<String, dynamic>?> res;
    switch (method.toUpperCase()) {
      case 'GET':
        res = await _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters);
        break;
      case 'POST':
        res = await _dio.post<Map<String, dynamic>>(path, data: body, queryParameters: queryParameters);
        break;
      case 'PUT':
        res = await _dio.put<Map<String, dynamic>>(path, data: body, queryParameters: queryParameters);
        break;
      case 'DELETE':
        res = await _dio.delete<Map<String, dynamic>>(path, data: body, queryParameters: queryParameters);
        break;
      default:
        throw UnsupportedError('Method $method not supported');
    }
    return _parseResponse(res, fromJsonData);
  }
}
