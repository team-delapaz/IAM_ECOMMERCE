import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMSkeleton extends StatelessWidget {
  const IAMSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class IAMProductGridSkeleton extends StatelessWidget {
  const IAMProductGridSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 290,
        crossAxisSpacing: IAMSizes.gridViewSpacing,
        mainAxisSpacing: IAMSizes.gridViewSpacing,
      ),
      itemBuilder: (_, __) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IAMSkeleton(height: 180, radius: 14),
          SizedBox(height: 10),
          IAMSkeleton(height: 14, width: 130),
          SizedBox(height: 8),
          IAMSkeleton(height: 12, width: 100),
          Spacer(),
          IAMSkeleton(height: 20, width: 90),
        ],
      ),
    );
  }
}
