import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMBottomAddToCart extends StatelessWidget {
  const IAMBottomAddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IAMSizes.defaultSpace,
        vertical: IAMSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? IAMColors.darkerGrey : IAMColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(IAMSizes.cardRadiusLg),
          topRight: Radius.circular(IAMSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IAMCircularIcon(
                icon: Iconsax.minus,
                backgroundColor: IAMColors.darkGrey,
                width: 40,
                height: 40,
                color: IAMColors.white,
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Text('2', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              IAMCircularIcon(
                icon: Iconsax.add,
                backgroundColor: Color(0xFFDBA724),
                width: 40,
                height: 40,
                color: IAMColors.white,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(IAMSizes.md),
              backgroundColor: Color(0xFFDBA724),
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
