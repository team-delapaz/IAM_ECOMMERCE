import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/appbar/tabbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/features/shop/screens/store/widgets/category_tab.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreController>()) {
      Get.put(StoreController());
    }

    // Initialize featured products data
    final controller = Get.find<StoreController>();
    if (controller.featuredProducts.isEmpty && !controller.featuredLoading.value) {
      controller.fetchFeaturedProducts();
    }

    return DefaultTabController(
      initialIndex: initialTabIndex.clamp(0, ProductCategories.ids.length - 1),
      length: ProductCategories.ids.length,
      child: Scaffold(
        appBar: IAMAppBar(
          title: Text(
            'Store',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [IAMCartCounterIcon(onPressed: () {})],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: IAMHelperFunctions.isDarkMode(context)
                    ? IAMColors.black
                    : IAMColors.white,

                // Divider for Featured Products & Products Category
                expandedHeight: 370,
                flexibleSpace: Padding(
                  padding: EdgeInsets.all(IAMSizes.defaultSpace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      //Search Bar
                      SizedBox(height: IAMSizes.spaceBtwItems),
                      IAMSearchBar(
                        text: 'Search in Store',
                        showBorder: true,
                        showBackground: false,
                        padding: EdgeInsets.zero,
                      ),

                      SizedBox(height: IAMSizes.spaceBtwSections),

                      //Featured Items
                      IAMSectionHeading(
                        title: 'Featured Items',
                        showActionButton: false,
                        onPressed: () {},
                      ),

                      const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                      // Featured Products - Horizontal Cards
                      SizedBox(
                        height: 130,
                        child: Obx(() {
                          final controller = Get.find<StoreController>();

                          if (controller.featuredLoading.value) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 2,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: IAMSizes.spaceBtwItems),
                              itemBuilder: (_, __) => const IAMSkeleton(
                                height: 130,
                                width: 260,
                                radius: IAMSizes.cardRadiusLg,
                              ),
                            );
                          }

                          if (controller.featuredError.value.isNotEmpty) {
                            return Center(
                              child: Text(
                                'Error loading products: ${controller.featuredError.value}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (controller.featuredProducts.isEmpty) {
                            return const Center(
                              child: Text('No featured products available'),
                            );
                          }

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: controller.featuredProducts.map((
                              product,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: IAMSizes.spaceBtwItems,
                                ),
                                child: IAMProductCardHorizontal(
                                  product: product,
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                //Tabs
                bottom: IAMTabBar(
                  tabs: ProductCategories.names
                      .map((name) => Tab(child: Text(name)))
                      .toList(),
                ),
              ),
            ];
          },

          //Body
          body: TabBarView(
            children: ProductCategories.ids
                .map((id) => IAMCategoryTab(categoryId: id))
                .toList(),
          ),
        ),
      ),
    );
  }
}
