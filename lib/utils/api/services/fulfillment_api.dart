import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class FulfillmentApi {
  FulfillmentApi(this._client);

  final ApiClient _client;

  /// Get available fulfillment types (e.g. Delivery, Pickup)
  Future<ApiResponse<List<FulfillmentTypeItem?>>> getFulfillmentTypes() {
    return _client.get<List<FulfillmentTypeItem?>>(
      ApiEndpoints.fulfillmentTypes,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => FulfillmentTypeItem.fromJson(e)).toList();
      },
    );
  }

  /// Get available branch list for pickup locations
  Future<ApiResponse<List<BranchItem?>>> getBranches() {
    return _client.get<List<BranchItem?>>(
      ApiEndpoints.branches,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => BranchItem.fromJson(e)).toList();
      },
    );
  }
}
