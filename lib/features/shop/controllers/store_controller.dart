import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  /// Cached products per category. Key = categoryId.
  final productsByCategory = <int, List<ProductItem>>{}.obs;

  /// Loading flag per category.
  final loadingByCategory = <int, bool>{}.obs;

  /// Error message per category.
  final errorByCategory = <int, String>{}.obs;

  /// Featured products (from category 1 by default)
  List<ProductItem> get featuredProducts => productsFor(1).take(2).toList();

  Future<void> fetchProductsByCategory(int categoryId) async {
    print('Fetching products for category $categoryId');
    loadingByCategory[categoryId] = true;
    errorByCategory[categoryId] = '';

    try {
      final res = await ApiMiddleware.products.getProductsByCategory(
        categoryId,
      );
      print('API response status: ${res.status}, success: ${res.success}');
      print('API response data length: ${res.data?.length ?? 0}');

      loadingByCategory[categoryId] = false;
      errorByCategory[categoryId] = res.success ? '' : res.message;
      if (res.success) {
        final list = res.data ?? [];
        productsByCategory[categoryId] = list.whereType<ProductItem>().toList();
        print(
          'Products loaded: ${productsByCategory[categoryId]?.length ?? 0}',
        );
      } else {
        productsByCategory[categoryId] = [];
        print('API error: ${res.message}');
      }
    } catch (e) {
      print('Exception in fetchProductsByCategory: $e');
      loadingByCategory[categoryId] = false;
      errorByCategory[categoryId] = 'Network error: $e';
      productsByCategory[categoryId] = [];
    }
  }

  /// Fetch featured products (first 2 products from category 1)
  Future<void> fetchFeaturedProducts() async {
    await fetchProductsByCategory(1);
  }

  bool isLoading(int categoryId) => loadingByCategory[categoryId] ?? false;
  String errorFor(int categoryId) => errorByCategory[categoryId] ?? '';
  List<ProductItem> productsFor(int categoryId) =>
      productsByCategory[categoryId] ?? [];
}
