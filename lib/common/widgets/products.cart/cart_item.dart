import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/texts/brand_title_text_verifiedicon.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMCartItem extends StatelessWidget {
  const IAMCartItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IAMRoundedImage(
          imageUrl: IAMImages.pibarpow,
          width: 70,
          height: 70,
          padding: EdgeInsets.all(IAMSizes.sm),
          backgroundColor: IAMHelperFunctions.isDarkMode(context)
              ? IAMColors.darkerGrey
              : IAMColors.light,
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IAMBrandTitleWithVerifiedIcon(title: 'AMAZING Organic Barley'),
              Flexible(
                child: Transform.scale(
                  scale: 1.4, // Slightly larger title just in cart items
                  alignment: Alignment.centerLeft,
                  child: IAMProductTitleText(
                    title: 'IAM Barley Capsules',
                    maxLines: 1,
                  ),
                ),
              ),
              /*Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Color ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(
                      text: 'Green ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }
}
