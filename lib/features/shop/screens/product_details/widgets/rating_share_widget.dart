import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class IAMRatingAndShare extends StatelessWidget {
  const IAMRatingAndShare({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // -- RATING
        Row(
          children: [
            Icon(Iconsax.star5, color: Color(0xFFDBA724), size: 24),
            SizedBox(width: IAMSizes.spaceBtwItems / 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '5.0',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const TextSpan(text: '(299)'),
                ],
              ),
            ),
          ],
        ),

        // -- SHARE BUTTON
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share, size: IAMSizes.iconMd),
        ),
      ],
    );
  }
}
