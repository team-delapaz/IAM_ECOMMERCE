import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:share_plus/share_plus.dart';

class IAMRatingAndShare extends StatelessWidget {
  const IAMRatingAndShare({super.key, required this.productCode});

  final String productCode;

  //domain maybe kapag up nalang tsaka update to
  String _buildDynamicLink() {
    return 'https://yourapp.page.link/product?code=$productCode';
  }

  void _shareProduct() {
    final link = _buildDynamicLink();

    Share.share('Check out this product:\n$link');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiMiddleware.productReview.getReviews(productCode),
      builder: (context, snapshot) {
        double average = 0;
        int count = 0;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.success) {
          final reviews = snapshot.data!.data ?? [];
          final validReviews = reviews.where((r) => r != null).toList();

          count = validReviews.length;

          if (count > 0) {
            final total = validReviews.fold<int>(
              0,
              (sum, r) => sum + (r!.rating ?? 0),
            );
            average = total / count;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Iconsax.star5, color: Color(0xFFDBA724), size: 24),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: average.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(text: '($count)'),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _shareProduct,
              icon: const Icon(Icons.share, size: IAMSizes.iconMd),
            ),
          ],
        );
      },
    );
  }
}
