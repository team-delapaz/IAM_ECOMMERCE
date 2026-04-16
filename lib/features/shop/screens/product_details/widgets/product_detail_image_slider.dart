import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMProductImageSlider extends StatelessWidget {
  const IAMProductImageSlider({super.key, this.product});

  final ProductItem? product;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final imageUrl = product?.imageUrl ?? IAMImages.pibarpow;
    final isNetwork = product != null;

    return IAMCurvedEdgeWidget(
      child: Container(
        color: dark ? IAMColors.darkerGrey : IAMColors.light,
        child: Stack(
          children: [
            SizedBox(
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(IAMSizes.productImageRadius * 2),
                child: Center(
                  child: isNetwork
                      ? IAMRoundedImage(
                          imageUrl: imageUrl,
                          isNetworkImage: true,
                          fit: BoxFit.contain,
                        )
                      : Image(image: AssetImage(imageUrl)),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 30,
              left: IAMSizes.defaultSpace,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: IAMSizes.spaceBtwItems),
                  itemCount: 1,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (_, index) => IAMRoundedImage(
                    width: 80,
                    backgroundColor: dark ? IAMColors.dark : IAMColors.white,
                    border: Border.all(color: IAMColors.primary),
                    padding: const EdgeInsets.all(IAMSizes.sm),
                    imageUrl: imageUrl,
                    isNetworkImage: isNetwork,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
