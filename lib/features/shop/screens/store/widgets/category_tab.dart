import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_showcase.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMCategoryTab extends StatefulWidget {
  const IAMCategoryTab({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<IAMCategoryTab> createState() => _IAMCategoryTabState();
}

class _IAMCategoryTabState extends State<IAMCategoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<StoreController>();
      if (!controller.loadingByCategory.containsKey(widget.categoryId) &&
          !controller.productsByCategory.containsKey(widget.categoryId)) {
        controller.fetchProductsByCategory(widget.categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final categoryId = widget.categoryId;
    final categoryName =
        ProductCategories.names[ProductCategories.ids
            .indexOf(categoryId)
            .clamp(0, ProductCategories.names.length - 1)];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              /*IAMBrandShowCase(
                images: [
                  IAMImages.pibarcap,
                  IAMImages.pibarcho,
                  IAMImages.piacaibr,
                ],
              ),*/
              const SizedBox(height: IAMSizes.spaceBtwItems),
              IAMSectionHeading(title: categoryName, onPressed: () {}),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Obx(() {
                if (controller.loadingByCategory[categoryId] == true) {
                  return const Padding(
                    padding: EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final err = controller.errorByCategory[categoryId];
                if (err != null && err.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      err,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = controller.productsFor(categoryId);
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
