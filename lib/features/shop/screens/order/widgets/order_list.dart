import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/cancelled_order_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/delivered_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/processing_order_screen.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_detail_screen.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class IAMOrderListItems extends StatefulWidget {
  const IAMOrderListItems({super.key});

  @override
  State<IAMOrderListItems> createState() => _IAMOrderListItemsState();
}

class _IAMOrderListItemsState extends State<IAMOrderListItems> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        IAMRoundedContainer(
          padding: const EdgeInsets.all(4),
          backgroundColor: dark ? Colors.grey[900]! : Colors.grey[200]!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 3; // tab count :D

              return Stack(
                children: [
                  // Sliding background
                  AnimatedPositioned(
                    left: selectedIndex * tabWidth,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: tabWidth,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildTab('Processing', 0, tabWidth),
                      _buildTab('Delivered', 1, tabWidth),
                      _buildTab('Cancelled', 2, tabWidth),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: IAMSizes.spaceBtwItems),

        /// ---------------- TAB CONTENT ----------------
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: const [ProcessingTab(), DeliveredTab(), CancelledTab()],
          ),
        ),
      ],
    );
  }

  /// TAB BUILDER
  Widget _buildTab(String title, int index, double tabWidth) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: SizedBox(
        width: tabWidth,
        height: 40,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
