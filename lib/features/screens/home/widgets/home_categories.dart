import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';

class IAMHomeCategories extends StatelessWidget {
  const IAMHomeCategories({super.key});

  static const List<String> _categoryImages = [
    IAMImages.amazingBarley1,
    IAMImages.amazingSkinCare,
    IAMImages.deliciousJuiceDrinks1,
    IAMImages.foodSupplements1,
    IAMImages.healthyCoffee1,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: ProductCategories.ids.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final name = ProductCategories.names[index];
          final image = index < _categoryImages.length
              ? _categoryImages[index]
              : IAMImages.sjkProducts;
          return IAMVerticalImageText(
            image: image,
            title: name,
            applyIconTint: false,
            onTap: () {
              Get.find<NavigationController>().navigateToStore(index);
            },
          );
        },
      ),
    );
  }
}
