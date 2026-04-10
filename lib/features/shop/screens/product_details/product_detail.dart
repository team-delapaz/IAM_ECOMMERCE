import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/controllers/wishlist_controller.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:readmore/readmore.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, this.product});

  final ProductItem? product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final AuthController _auth = AuthController.instance;
  final WishlistController _wishlistController = Get.put(WishlistController());

  @override
  void initState() {
    super.initState();

    // Keep cache warm so the icon reflects server state when possible.
    if (_auth.isLoggedIn.value) {
      _wishlistController.loadWishlistItems();
    }
  }

  Future<void> _checkoutProduct(BuildContext context) async {
    final code = widget.product?.productCode;
    if (code == null || code.isEmpty) return;

    const qty = 1;
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    if (!isLoggedIn) {
      ////TEmporary section while waiting for guest session api
      final storage = IAMLocalStorage();
      final existing = storage.readData<List>('guest_cart') ?? [];
      final cart = existing
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final index = cart.indexWhere((e) => e['productCode'] == code);
      if (index >= 0) {
        final current = cart[index]['qty'] as int? ?? 0;
        cart[index]['qty'] = current + qty;
      } else {
        cart.add({'productCode': code, 'qty': qty});
      }
      await storage.saveData('guest_cart', cart);
      if (!context.mounted) return;
      Get.to(() => const CheckoutScreen());
      return;
    }

    final res = await ApiMiddleware.cart.add(productCode: code, qty: qty);
    if (!context.mounted) return;
    if (!res.success) {
      final msg = res.message.isNotEmpty
          ? res.message
          : 'Unable to add item to cart.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout failed: $msg',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }
    Get.to(() => const CartScreen());
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    if (product == null) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                IAMSkeleton(height: 280, radius: IAMSizes.cardRadiusLg),
                SizedBox(height: IAMSizes.spaceBtwSections),
                IAMSkeleton(height: 18, width: 180),
                SizedBox(height: IAMSizes.spaceBtwItems),
                IAMSkeleton(height: 14, width: 120),
                SizedBox(height: IAMSizes.spaceBtwSections),
                IAMSkeleton(height: 46, radius: IAMSizes.cardRadiusMd),
                SizedBox(height: IAMSizes.spaceBtwSections),
                IAMSkeleton(height: 16, width: 130),
                SizedBox(height: IAMSizes.spaceBtwItems),
                IAMSkeleton(height: 80, radius: IAMSizes.cardRadiusMd),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: IAMAppBar(
        showBackArrow: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final productCode = product.productCode;
            final isLoggedIn = _auth.isLoggedIn.value;
            final wishlisted = (!isLoggedIn || productCode.isEmpty)
                ? false
                : (_wishlistController.wishlistedByCode[productCode] ?? false);
            final toggling = (!isLoggedIn || productCode.isEmpty)
                ? false
                : (_wishlistController.togglingByCode[productCode] ?? false);

            return IAMCircularIcon(
              icon: wishlisted ? Iconsax.heart : Iconsax.heart5,
              color: !isLoggedIn ? Colors.grey : (wishlisted ? Colors.red : null),
              onPressed: (!isLoggedIn || productCode.isEmpty || toggling)
                  ? null
                  : () {
                      _wishlistController
                          .toggleWishlist(productCode)
                          .then((result) {
                        if (!context.mounted) return;
                        if (result.message.isEmpty) return;

                        final backgroundColor = result.wishlisted
                            ? Colors.green[300]
                            : Colors.red[300];

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: backgroundColor,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      });
                    },
            );
          }),
          IAMCircularIcon(
            icon: Iconsax.shopping_bag,
            onPressed: () => Get.to(() => const CartScreen())),
        ],
      ),
      bottomNavigationBar: IAMBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMProductImageSlider(product: product),
            Padding(
              padding: EdgeInsets.only(
                right: IAMSizes.defaultSpace,
                left: IAMSizes.defaultSpace,
                bottom: IAMSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  IAMRatingAndShare(),
                  IAMProductMetaData(product: product),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                  // -- ATTRIBUTES
                  /*IAMProductAttributes(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),*/
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _checkoutProduct(context),
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  const IAMSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  ReadMoreText(
                    product.longDesc.isNotEmpty
                        ? product.longDesc
                        : 'No description available.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const IAMSectionHeading(
                        title: 'Review(19)',
                        showActionButton: false,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.arrow_right_3, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
