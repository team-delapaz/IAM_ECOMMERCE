import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class PointsApi {
  PointsApi(this._client);

  final ApiClient _client;

  ApiResponse<T> _unauthorized<T>() {
    return ApiResponse<T>(
      status: 401,
      success: false,
      message: 'Authorization required. Please login again.',
      data: null,
    );
  }

  Future<ApiResponse<List<dynamic>?>> getPoints() {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<List<dynamic>?>());
    return _client.get<List<dynamic>?>(
      ApiEndpoints.points,
      fromJsonData: (dynamic v) => v is List ? v : <dynamic>[],
    );
  }

  Future<ApiResponse<PointsBalanceData?>> getBalance() {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<PointsBalanceData?>());
    return _client.get<PointsBalanceData?>(
      ApiEndpoints.pointsBalance,
      fromJsonData: PointsBalanceData.fromJson,
    );
  }
}
