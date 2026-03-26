import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class ProductReviewApi {
  ProductReviewApi(this._client);

  final ApiClient _client;

  /// Add a product review
  Future<ApiResponse<dynamic>> addReview({
    required String productCode,
    required int rating,
    required String reviewComment,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.productReview,
      body: {
        'productCode': productCode,
        'rating': rating,
        'reviewComment': reviewComment,
      },
    );
  }

  /// Get product reviews by product code
  Future<ApiResponse<List<ProductReviewItem?>>> getReviews(String productCode) {
    return _client.get<List<ProductReviewItem?>>(
      ApiEndpoints.productReviewsByCode(productCode),
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => ProductReviewItem.fromJson(e)).toList();
      },
    );
  }
}