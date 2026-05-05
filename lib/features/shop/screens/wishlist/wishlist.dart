import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/home.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/shop/controllers/wishlist_controller.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  late final WishlistController _wishlistController;

  @override
  void initState() {
    super.initState();
    _wishlistController = Get.put(WishlistController());
    _wishlistController.loadWishlistItems();
  }

  Widget _buildEmptyWishlistContent(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final creamCircle = dark
        ? IAMColors.primary.withValues(alpha: 0.12)
        : const Color(0xFFFFF9E5);

    void browseProducts() {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().navigateToStore(0);
      } else {
        Get.to(const HomeScreen());
      }
      if (Navigator.of(context).canPop()) {
        Get.back();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: IAMSizes.sm),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 288,
                  height: 264,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 8,
                        child: Container(width: 180, height: 32),
                      ),
                      // Ornaments spaced for 200×200 circle (scaled from earlier 140px layout).
                      _emptyCartSparkle(right: 18, top: 26),
                      _emptyCartSparkle(left: 2, top: 76, small: true),
                      _emptyCartSparkle(right: 4, bottom: 86, dot: true),
                      _emptyCartSparkle(left: 26, bottom: 94, dot: true),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: creamCircle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 100,
                          color: IAMColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                Text(
                  'Your wishlist is empty',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: dark ? IAMColors.white : IAMColors.black,
                  ),
                ),
                const SizedBox(height: IAMSizes.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
                  child: Text(
                    'Tap the heart on a product to save it here for later.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark
                          ? IAMColors.white.withValues(alpha: 0.75)
                          : IAMColors.black.withValues(alpha: 0.70),
                    ),
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IAMSizes.defaultSpace,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: browseProducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IAMColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            IAMSizes.cardRadiusLg,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Browse Products'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyCartSparkle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    bool small = false,
    bool dot = false,
  }) {
    final size = small ? 12.0 : 16.0;
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Icon(
        dot ? Icons.circle : Icons.add,
        size: dot ? 6 : size,
        color: IAMColors.primary.withValues(alpha: dot ? 0.45 : 0.55),
      ),
    );
  }

  ProductItem _productFromWishlistItem(WishlistItem item) {
    // Wishlist API doesn't return full `ProductItem` fields; we adapt the
    // response so the existing product card can render.
    return ProductItem(
      categoryId: 0,
      categoryName: '',
      productCode: item.productCode,
      productName: item.productName,
      regularPrice: item.sellingPrice,
      memberPrice: 0,
      sellingPrice: item.sellingPrice,
      shortDesc: item.shortDesc,
      longDesc: item.shortDesc,
      isActive: true,
      isFeatured: false,
      isPopular: false,
      imageUrl: item.imageUrl,
      altText: item.altText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IAMCircularIcon(
            icon: Iconsax.add,
            onPressed: () => Get.to(const HomeScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (_wishlistController.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!AuthController.instance.isLoggedIn.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please login to add products to your wishlist.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.to(const LoginScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_wishlistController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(_wishlistController.errorMessage.value));
        }

        if (_wishlistController.items.isEmpty) {
          return _buildEmptyWishlistContent(context);
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: IAMGridLayout(
              itemCount: _wishlistController.items.length,
              itemBuilder: (_, index) {
                final item = _wishlistController.items[index];
                return IAMProductCardVertical(
                  product: _productFromWishlistItem(item),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
