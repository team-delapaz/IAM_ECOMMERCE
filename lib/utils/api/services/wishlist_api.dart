import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class WishlistApi {
  WishlistApi(this._client);

  final ApiClient _client;

  /// Add product to wishlist
  Future<ApiResponse<dynamic>> addWishlist(String productCode) {
    return _client.post<dynamic>(
      ApiEndpoints.wishlist,
      body: {'productCode': productCode},
    );
  }

  /// Get all wishlist items
  Future<ApiResponse<List<WishlistItem?>>> getWishlist() {
    return _client.get<List<WishlistItem?>>(
      ApiEndpoints.wishlist,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => WishlistItem.fromJson(e)).toList();
      },
    );
  }

  /// Remove product from wishlist
  Future<ApiResponse<dynamic>> removeWishlist(String productCode) {
    return _client.delete<dynamic>(
      ApiEndpoints.wishlistByProductCode(productCode),
    );
  }

  /// Check if product is in wishlist
  Future<ApiResponse<WishlistCheckItem?>> checkWishlist(String productCode) {
    return _client.get<WishlistCheckItem?>(
      ApiEndpoints.wishlistCheck(productCode),
      fromJsonData: WishlistCheckItem.fromJson,
    );
  }
}