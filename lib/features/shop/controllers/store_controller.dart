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

  final featuredProducts = <ProductItem>[].obs;
  final featuredLoading = false.obs;
  final featuredError = ''.obs;

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

  /// Fetch featured products from /Products with isFeatured = true.
  Future<void> fetchFeaturedProducts() async {
    featuredLoading.value = true;
    featuredError.value = '';
    final res = await ApiMiddleware.products.getProducts();
    featuredLoading.value = false;
    if (!res.success) {
      featuredError.value = res.message;
      featuredProducts.clear();
      return;
    }
    final list = res.data ?? [];
    featuredProducts.assignAll(
      list.whereType<ProductItem>().where((p) => p.isFeatured),
    );
  }

  bool isLoading(int categoryId) => loadingByCategory[categoryId] ?? false;
  String errorFor(int categoryId) => errorByCategory[categoryId] ?? '';
  List<ProductItem> productsFor(int categoryId) =>
      productsByCategory[categoryId] ?? [];
}
