import 'package:get/get.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final carouselContextIndex = 0.obs;
  final products = <ProductItem>[].obs;
  final productsLoading = false.obs;
  final productsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    productsLoading.value = true;
    productsError.value = '';
    final res = await ApiMiddleware.products.getProducts();
    productsLoading.value = false;
    if (!res.success) {
      productsError.value = res.message;
      products.clear();
      return;
    }
    final list = res.data ?? [];
    products.assignAll(list.whereType<ProductItem>());
  }

  void updatePageIndicator(index) {
    carouselContextIndex.value = index;
  }
}
