import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class IAMProductCardHorizontal extends StatelessWidget {
  const IAMProductCardHorizontal({super.key, this.product});

  final ProductItem? product;

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
        const SnackBar(content: Text('Item added to cart (guest).')),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String _formatPrice(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Obx(() {
      final dark = IAMHelperFunctions.isDarkMode(context);
      final imageUrl = product?.imageUrl ?? IAMImages.pibarcap;
      final isNetwork = product != null;
      final title = product?.productName ?? 'Amazing Pure Organic Barley Drink';
      final brand = product?.shortDesc.isNotEmpty == true
          ? product!.shortDesc
          : 'Amazing Barley';
      final memberPrice = product?.memberPrice ?? 1750;
      final regularPrice = product?.regularPrice ?? 2000;
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
          width: 310,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IAMSizes.productImageRadius),
            color: dark ? IAMColors.darkerGrey : IAMColors.softGrey,
          ),
          child: Row(
            children: [
              IAMRoundedContainer(
                height: 120,
                padding: const EdgeInsets.all(IAMSizes.sm),
                backgroundColor: dark ? IAMColors.dark : IAMColors.light,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: IAMRoundedImage(
                        imageUrl: imageUrl,
                        applyImageRadius: true,
                        isNetworkImage: isNetwork,
                      ),
                    ),
                    if (discountPercent != null)
                      Positioned(
                        top: 7,
                        left: 7,
                        child: IAMRoundedContainer(
                          radius: IAMSizes.sm,
                          backgroundColor: IAMColors.secondary.withOpacity(0.8),
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
                                    252,
                                    252,
                                    252,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: IAMCircularIcon(
                        icon: Iconsax.heart5,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 172,
                child: Padding(
                  padding: EdgeInsets.only(top: IAMSizes.sm, left: 0),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IAMProductTitleText(title: title, smallSize: true),
                          SizedBox(height: IAMSizes.spaceBtwItems / 2),
                          IAMBrandTitleWithVerifiedIcon(title: brand),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
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
                                  topLeft: Radius.circular(
                                    IAMSizes.cardRadiusMd,
                                  ),
                                  bottomRight: Radius.circular(
                                    IAMSizes.productImageRadius,
                                  ),
                                ),
                              ),
                              child: const SizedBox(
                                width: IAMSizes.iconLg * 1.2,
                                height: IAMSizes.iconLg * 1.2,
                                child: Center(
                                  child: Icon(
                                    Iconsax.add,
                                    color: IAMColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
