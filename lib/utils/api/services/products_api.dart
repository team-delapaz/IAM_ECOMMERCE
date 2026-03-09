import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class ProductsApi {
  ProductsApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<List<ProductItem?>>> getProducts() {
    return _client.get<List<ProductItem?>>(
      ApiEndpoints.products,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => ProductItem.fromJson(e)).toList();
      },
    );
  }

  Future<ApiResponse<ProductItem?>> getProductDetail(String productCode) {
    return _client.get<ProductItem?>(
      ApiEndpoints.productDetail(productCode),
      fromJsonData: ProductItem.fromJson,
    );
  }
}
