import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/appbar/tabbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/common/widgets/categories/brand_card.dart';
import 'package:iam_ecomm/features/shop/screens/store/widgets/category_tab.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.initialTabIndex = 0});
  
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 8,
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
                expandedHeight: 440,

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

                      //Featured Categories
                      IAMSectionHeading(
                        title: 'Featured Items',
                        showActionButton: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: IAMSizes.spaceBtwItems / 1.5),

                      IAMGridLayout(
                        itemCount: 4,
                        mainAxisExtent: 80,
                        itemBuilder: (_, index) {
                          return IAMBrandCard(showBorder: true);
                        },
                      ),
                    ],
                  ),
                ),

                //Tabs
                bottom: IAMTabBar(
                  tabs: [
                    Tab(child: Text('IAM Packages')),
                    Tab(child: Text('Amazing Barley')),
                    Tab(child: Text('Amazing Skin Care')),
                    Tab(child: Text('Delicious Juice Drinks')),
                    Tab(child: Text('Food Supplements')),
                    Tab(child: Text('Healthy Coffee')),
                    Tab(child: Text('Protective Accessories')),
                    Tab(child: Text('SJK Products')),
                  ],
                ),
              ),
            ];
          },
          //Body
          body: const TabBarView(
            children: [
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
              IAMCategoryTab(),
            ],
          ),
        ),
      ),
    );
  }
}
