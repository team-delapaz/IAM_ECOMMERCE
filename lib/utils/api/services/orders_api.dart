import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class OrdersApi {
  OrdersApi(this._client);

  final ApiClient _client;

  /// Get all orders
  Future<ApiResponse<List<OrderItem?>>> getOrders() {
    return _client.get<List<OrderItem?>>(
      ApiEndpoints.orders,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => OrderItem.fromJson(e)).toList();
      },
    );
  }

  /// Get order details by reference number
  Future<ApiResponse<OrderDetailItem?>> getOrderDetail(String refNo) {
    return _client.get<OrderDetailItem?>(
      ApiEndpoints.orderByRefNo(refNo),
      fromJsonData: OrderDetailItem.fromJson,
    );
  }
}
