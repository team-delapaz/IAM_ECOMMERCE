import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    return Scaffold(
      appBar: const IAMAppBar(
        title: Text('Popular Products'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
                onChanged: (_) {},
                items: [
                  'Name',
                  'Higher Price',
                  'Lower Price',
                  'Sale',
                  'Newest',
                  'Popularity',
                ]
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
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
            ],
          ),
        ),
      ),
    );
  }
}