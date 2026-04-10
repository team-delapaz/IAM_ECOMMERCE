import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class WishlistToggleResult {
  final bool wishlisted;
  final String message;

  const WishlistToggleResult({
    required this.wishlisted,
    required this.message,
  });
}

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find<WishlistController>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Server wishlist items.
  final RxList<WishlistItem> items = <WishlistItem>[].obs;

  /// Cached "is wishlisted?" state per product code.
  final RxMap<String, bool> wishlistedByCode = <String, bool>{}.obs;

  /// Prevent concurrent toggles per product code.
  final RxMap<String, bool> togglingByCode = <String, bool>{}.obs;

  bool isWishlisted(String productCode) =>
      wishlistedByCode[productCode] ?? false;

  bool isToggling(String productCode) =>
      togglingByCode[productCode] ?? false;

  Future<void> loadWishlistItems() async {
    // Optional: clear UI when user is logged out.
    if (!AuthController.instance.isLoggedIn.value) {
      items.clear();
      wishlistedByCode.clear();
      togglingByCode.clear();
      errorMessage.value = '';
      return;
    }

    loading.value = true;
    errorMessage.value = '';

    final res = await ApiMiddleware.wishlist.getWishlist();
    loading.value = false;

    if (!res.success) {
      errorMessage.value = res.message;
      items.clear();
      wishlistedByCode.clear();
      return;
    }

    final list = res.data ?? const <WishlistItem?>[];
    items.assignAll(list.whereType<WishlistItem>());

    final map = <String, bool>{};
    for (final item in items) {
      map[item.productCode] = true;
    }
    wishlistedByCode.value = map;
  }

  Future<bool?> _fetchIsWishlisted(String productCode) async {
    final res = await ApiMiddleware.wishlist.checkWishlist(productCode);
    if (!res.success) return null;
    return res.data?.isWishlisted;
  }

  Future<WishlistToggleResult> toggleWishlist(String productCode) async {
    if (!AuthController.instance.isLoggedIn.value) {
      return const WishlistToggleResult(
        wishlisted: false,
        message: 'Please login to use wishlist.',
      );
    }

    if (isToggling(productCode)) {
      return WishlistToggleResult(
        wishlisted: isWishlisted(productCode),
        message: '',
      );
    }

    togglingByCode[productCode] = true;
    togglingByCode.refresh();

    try {
      final hasCached = wishlistedByCode.containsKey(productCode);
      final isWishlisted = hasCached
          ? wishlistedByCode[productCode] ?? false
          : (await _fetchIsWishlisted(productCode) ?? false);

      if (isWishlisted) {
        final res = await ApiMiddleware.wishlist.removeWishlist(productCode);
        if (res.success) {
          // Keep UI snappy on remove.
          wishlistedByCode[productCode] = false;
          wishlistedByCode.refresh();
          items.removeWhere((e) => e.productCode == productCode);

          return WishlistToggleResult(
            wishlisted: false,
            message: 'Removed from wishlist.',
          );
        }

        return WishlistToggleResult(
          wishlisted: true,
          message: res.message.isNotEmpty
              ? res.message
              : 'Unable to remove from wishlist.',
        );
      } else {
        final res = await ApiMiddleware.wishlist.addWishlist(productCode);
        if (res.success) {
          // Reload to get full server item data.
          await loadWishlistItems();
          return const WishlistToggleResult(
            wishlisted: true,
            message: 'Added to wishlist.',
          );
        }

        return WishlistToggleResult(
          wishlisted: false,
          message: res.message.isNotEmpty
              ? res.message
              : 'Unable to add to wishlist.',
        );
      }
    } catch (_) {
      return WishlistToggleResult(
        wishlisted: isWishlistedFromCacheOrFalse(productCode),
        message: 'Something went wrong.',
      );
    } finally {
      togglingByCode[productCode] = false;
      togglingByCode.refresh();
    }
  }

  bool isWishlistedFromCacheOrFalse(String productCode) =>
      wishlistedByCode[productCode] ?? false;
}

