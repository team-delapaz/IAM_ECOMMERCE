import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/enums.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';

class IAMProductMetaData extends StatelessWidget {
  const IAMProductMetaData({super.key, this.product});

  final ProductItem? product;

  static String _formatPrice(num value) {
    return IAMFormatter.formatCurrency(value.toDouble()).replaceFirst('₱', '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final title = product?.productName ?? 'IAM Pure Organic Barley Powder';
    final brand = product?.shortDesc.isNotEmpty == true
        ? product!.shortDesc.toUpperCase()
        : 'AMAZING BARLEY';

    return Obx(() {
      final showMember = auth.isLoggedIn.value && auth.isMember;
      final regularPrice = product?.regularPrice ?? 1000.0;
      final memberPrice = product?.memberPrice ?? 500.0;
      final discountPercent =
          showMember && regularPrice > 0 && memberPrice < regularPrice
          ? ((regularPrice - memberPrice) / regularPrice * 100).round()
          : null;
      final displayPrice = showMember ? memberPrice : regularPrice;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (discountPercent != null)
                IAMRoundedContainer(
                  radius: IAMSizes.sm,
                  backgroundColor: IAMColors.primary.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(
                    horizontal: IAMSizes.sm,
                    vertical: IAMSizes.xs,
                  ),
                  child: Text(
                    '$discountPercent%',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.apply(color: IAMColors.black),
                  ),
                ),
              if (discountPercent != null)
                const SizedBox(width: IAMSizes.spaceBtwItems),
              if (showMember && memberPrice < regularPrice)
                Text(
                  '₱${_formatPrice(regularPrice)}',
                  style: Theme.of(context).textTheme.titleSmall!.apply(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (showMember && memberPrice < regularPrice)
                const SizedBox(width: IAMSizes.spaceBtwItems),
              IAMProductPriceText(
                price: _formatPrice(displayPrice),
                isLarge: true,
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),
          IAMProductTitleText(title: title),
          const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),
          Row(
            children: [
              const IAMProductTitleText(title: 'Status'),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Text(
                product?.isActive == true ? 'In Stock' : 'Out of Stock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),
          Row(
            children: [
              IAMBrandTitleWithVerifiedIcon(
                title: brand,
                brandTextSize: TextSizes.medium,
              ),
            ],
          ),
        ],
      );
    });
  }
}
