import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';

class CartApi {
  CartApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<dynamic>> add({
    required String productCode,
    required int qty,
    String sourceApp = 'M',
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.cartAdd,
      body: {
        'productCode': productCode,
        'qty': qty,
        'sourceApp': sourceApp,
      },
    );
  }

  Future<ApiResponse<dynamic>> getCart() {
    return _client.get<dynamic>(ApiEndpoints.cart);
  }

  Future<ApiResponse<dynamic>> updateQty(String productCode, int qty) {
    return _client.put<dynamic>(
      ApiEndpoints.cartQty(productCode),
      body: {'productCode': productCode, 'qty': qty},
    );
  }

  Future<ApiResponse<dynamic>> deleteItem(String productCode) {
    return _client.delete<dynamic>(ApiEndpoints.cartItem(productCode));
  }
}
