/// Wraps backend JSON: status, success, message, data.
class ApiResponse<T> {
  final int status;
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.status,
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromJsonData,
  ) {
    return ApiResponse<T>(
      status: json['status'] as int? ?? 0,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : fromJsonData != null
              ? fromJsonData(json['data'])
              : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T?)? toJsonData) {
    return {
      'status': status,
      'success': success,
      'message': message,
      'data': data == null ? null : (toJsonData != null ? toJsonData(data) : data),
    };
  }
}
