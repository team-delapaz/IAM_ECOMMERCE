import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iam_ecomm/common/styles/shadows.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/product_detail.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/features/shop/controllers/wishlist_controller.dart';

class IAMProductCardVertical extends StatelessWidget {
  const IAMProductCardVertical({super.key, this.product});

  final ProductItem? product;

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final wishlistController = Get.put(WishlistController());

    return Obx(() {
      final dark = IAMHelperFunctions.isDarkMode(context);
      final productCode = product?.productCode;
      final wishlisted = productCode == null
          ? false
          : (wishlistController.wishlistedByCode[productCode] ?? false);
      final toggling = productCode == null
          ? false
          : (wishlistController.togglingByCode[productCode] ?? false);

      final imageUrl = product?.imageUrl ?? IAMImages.pibarcap;
      final isNetwork = product != null;
      final title = product?.productName ?? 'Amazing Organic Barley';
      final brand = product?.shortDesc.isNotEmpty == true
          ? product!.shortDesc
          : 'Amazing Barley';
      final memberPrice = product?.memberPrice ?? 750;
      final regularPrice = product?.regularPrice ?? 1000;
      final showMember = auth.isLoggedIn.value && auth.isMember;
      final displayPrice = showMember ? memberPrice : regularPrice;
      final discountPercent =
          showMember && regularPrice > 0 && memberPrice < regularPrice
          ? ((regularPrice - memberPrice) / regularPrice * 100).round()
          : null;

      return GestureDetector(
        onTap: () => Get.to(
          () => ProductDetailScreen(product: product),
          arguments: product,
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            boxShadow: [IAMShadowStyle.verticalProductShadow],
            borderRadius: BorderRadius.circular(IAMSizes.productImageRadius),
            color: dark ? IAMColors.darkerGrey : IAMColors.white,
          ),
          child: Column(
            children: [
              IAMRoundedContainer(
                height: 180,
                padding: const EdgeInsets.all(IAMSizes.sm),
                backgroundColor: dark ? IAMColors.dark : IAMColors.light,
                child: Stack(
                  children: [
                    IAMRoundedImage(
                      imageUrl: imageUrl,
                      applyImageRadius: true,
                      isNetworkImage: isNetwork,
                    ),
                    if (discountPercent != null)
                      Positioned(
                        top: 7,
                        left: 7,
                        child: IAMRoundedContainer(
                          radius: IAMSizes.sm,
                          backgroundColor: const Color.fromARGB(
                            255,
                            24,
                            24,
                            24,
                          ).withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: IAMSizes.sm,
                            vertical: IAMSizes.xs,
                          ),
                          child: Text(
                            '$discountPercent%',
                            style: Theme.of(context).textTheme.labelLarge!
                                .apply(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IAMCircularIcon(
                        icon: wishlisted ? Iconsax.heart : Iconsax.heart5,
                        color: wishlisted
                            ? Colors.red
                            : (dark
                                ? IAMColors.lightGrey
                                : IAMColors.darkGrey),
                        onPressed: productCode == null || toggling
                            ? null
                            : () {
                                wishlistController
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),
              Padding(
                padding: const EdgeInsets.only(left: IAMSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IAMProductTitleText(title: title, smallSize: true),
                    const SizedBox(height: IAMSizes.spaceBtwItems / 2),
                    IAMBrandTitleWithVerifiedIcon(title: brand),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: IAMSizes.sm),
                    child: IAMProductPriceText(
                      price: _formatPrice(displayPrice),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await _addToCart(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: IAMColors.dark,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                          bottomRight: Radius.circular(
                            IAMSizes.productImageRadius,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: IAMSizes.iconLg * 1.2,
                        height: IAMSizes.iconLg * 1.2,
                        child: const Center(
                          child: Icon(Iconsax.add, color: IAMColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _addToCart(BuildContext context) async {
    final code = product?.productCode;
    if (code == null || code.isEmpty) return;
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    if (!isLoggedIn) {
      final storage = IAMLocalStorage();
      final existing = storage.readData<List>('guest_cart') ?? [];
      final cart = existing
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final index = cart.indexWhere((e) => e['productCode'] == code);
      if (index >= 0) {
        cart[index]['qty'] = (cart[index]['qty'] as int? ?? 0) + 1;
      } else {
        cart.add({'productCode': code, 'qty': 1});
      }
      await storage.saveData('guest_cart', cart);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Item added to cart (guest).',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    final res = await ApiMiddleware.cart.add(productCode: code, qty: 1);
    if (!context.mounted) return;

    final msg = res.success
        ? (res.message.isNotEmpty ? res.message : 'Item added to cart.')
        : (res.message.isNotEmpty
              ? res.message
              : 'Unable to add item to cart.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: res.success ? Colors.green[300] : Colors.red[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static String _formatPrice(num value) {
    return NumberFormat('#,##0.00', 'en_PH').format(value);
  }
}
