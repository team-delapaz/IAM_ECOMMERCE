import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMVerticalImageText extends StatelessWidget {
  const IAMVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = IAMColors.white,
    this.backgroundColor,
    this.applyIconTint = true,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final bool applyIconTint;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: IAMSizes.spaceBtwItems),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(IAMSizes.sm),
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    (dark ? IAMColors.black : IAMColors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Image(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  color: applyIconTint
                      ? (dark ? IAMColors.light : IAMColors.dark)
                      : null,
                ),
              ),
            ),
            //Text
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            SizedBox(
              width: 90,
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.apply(color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
