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
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
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

  ProductItem _productFromWishlistItem(WishlistItem item) {
    // Wishlist API doesn't return full `ProductItem` fields; we adapt the
    // response so the existing product card can render.
    return ProductItem(
      categoryId: 0,
      categoryName: '',
      productCode: item.productCode,
      productName: item.productName,
      regularPrice: item.sellingPrice,
      memberPrice: item.sellingPrice,
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
      body: Obx(
        () {
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
            return Center(
              child: Text(_wishlistController.errorMessage.value),
            );
          }

          if (_wishlistController.items.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
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
        },
      ),
    );
  }
}
