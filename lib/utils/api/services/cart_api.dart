import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class CartApi {
  CartApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<CartPayload?>> add({
    required String productCode,
    required int qty,
    String sourceApp = 'M',
  }) {
    return _client.post<CartPayload?>(
      ApiEndpoints.cartAdd,
      body: {
        'productCode': productCode,
        'qty': qty,
        'sourceApp': sourceApp,
      },
      fromJsonData: CartPayload.fromJson,
    );
  }

  Future<ApiResponse<CartPayload?>> getCart() {
    return _client.get<CartPayload?>(
      ApiEndpoints.cart,
      fromJsonData: CartPayload.fromJson,
    );
  }

  Future<ApiResponse<CartPayload?>> updateQty(String productCode, int qty) {
    return _client.put<CartPayload?>(
      ApiEndpoints.cartQty,
      body: {'productCode': productCode, 'qty': qty},
      fromJsonData: CartPayload.fromJson,
    );
  }

  Future<ApiResponse<CartPayload?>> deleteItem(String productCode) {
    return _client.delete<CartPayload?>(
      ApiEndpoints.cartItem(productCode),
      fromJsonData: CartPayload.fromJson,
    );
  }
}
