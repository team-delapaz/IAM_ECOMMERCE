import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';

class CheckoutApi {
  CheckoutApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<dynamic>> checkout({String? notes}) {
    return _client.post<dynamic>(
      ApiEndpoints.checkout,
      body: notes == null ? null : {'notes': notes},
    );
  }
}

