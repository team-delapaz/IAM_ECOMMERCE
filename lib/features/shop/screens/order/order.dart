import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/order_list.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      //Appbar
      appBar: IAMAppBar(
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Swipe left or right on the tabs to view more order statuses.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: IAMColors.primary,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : IAMColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: IAMColors.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: IAMColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text('Info', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(IAMSizes.defaultSpace),

        //Order
        child: IAMOrderListItems(),
      ),
    );
  }
}
