import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:iam_ecomm/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:readmore/readmore.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product});

  final ProductItem? product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: IAMBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IAMProductImageSlider(product: product),
            Padding(
              padding: EdgeInsets.only(
                right: IAMSizes.defaultSpace,
                left: IAMSizes.defaultSpace,
                bottom: IAMSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  IAMRatingAndShare(),
                  IAMProductMetaData(product: product),
                  const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                  // -- ATTRIBUTES
                  /*IAMProductAttributes(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),*/

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Checkout'),
                    ),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  const IAMSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  ReadMoreText(
                    product?.longDesc.isNotEmpty == true
                        ? product!.longDesc
                        : 'No description available.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' less',
                    moreStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: IAMSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const IAMSectionHeading(
                        title: 'Review(19)',
                        showActionButton: false,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.arrow_right_3, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}