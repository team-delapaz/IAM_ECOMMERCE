import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/styles/shadows.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/product_detail.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMProductCardVertical extends StatelessWidget {
  const IAMProductCardVertical({super.key, this.product});

  final ProductItem? product;

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Obx(() {
      final dark = IAMHelperFunctions.isDarkMode(context);
      final imageUrl = product?.imageUrl ?? IAMImages.pibarcap;
      final isNetwork = product != null;
      final title = product?.productName ?? 'Amazing Organic Barley';
      final brand = product?.shortDesc.isNotEmpty == true
          ? product!.shortDesc
          : 'Amazing Barley';
      final memberPrice = product?.memberPrice ?? 750;
      final regularPrice = product?.regularPrice ?? 1000;
      final showMember = auth.isLoggedIn.value;
      final displayPrice = showMember ? memberPrice : regularPrice;
      final discountPercent = showMember && regularPrice > 0 && memberPrice < regularPrice
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
                        backgroundColor: const Color.fromARGB(255, 24, 24, 24)
                            .withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: IAMSizes.sm,
                          vertical: IAMSizes.xs,
                        ),
                        child: Text(
                          '$discountPercent%',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IAMCircularIcon(
                      icon: Iconsax.heart5,
                      color: Colors.red,
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
                Container(
                  decoration: const BoxDecoration(
                    color: IAMColors.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(IAMSizes.cardRadiusMd),
                      bottomRight: Radius.circular(IAMSizes.productImageRadius),
                    ),
                  ),
                  child: SizedBox(
                    width: IAMSizes.iconLg * 1.2,
                    height: IAMSizes.iconLg * 1.2,
                    child: Center(
                      child: const Icon(Iconsax.add, color: IAMColors.white),
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

  static String _formatPrice(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}
