import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_showcase.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCategoryTab extends StatelessWidget {
  const IAMCategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              //Categories
              IAMBrandShowCase(
                images: [
                  IAMImages.pibarcap,
                  IAMImages.pibarcho,
                  IAMImages.piacaibr,
                ],
              ),
              //  IAMBrandShowCase(
              //   images: [
              //     IAMImages.pibarcap,
              //     IAMImages.pibarcho,
              //     IAMImages.piacaibr,
              //   ],
              // ),   ADD THIS IF YOU HAVE MORE CATEGORIES
              const SizedBox(height: IAMSizes.spaceBtwItems),

              //products
              IAMSectionHeading(title: 'You might like', onPressed: () {}),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              Obx(() {
                final controller = Get.find<HomeController>();
                if (controller.productsLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.productsError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      controller.productsError.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = controller.products;
                return IAMGridLayout(
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      IAMProductCardVertical(product: list[index]),
                );
              }),
              const SizedBox(height: IAMSizes.spaceBtwSections),
            ],
          ),
        ),
      ],
    );
  }
}
