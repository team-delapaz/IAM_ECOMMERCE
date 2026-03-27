import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
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
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Column(
      children: [
        IAMRoundedContainer(
          padding: const EdgeInsets.all(4),
          backgroundColor: dark ? Colors.grey[900]! : Colors.grey[200]!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 3; //tab count :D

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

        /// Tab CONTENT
        Expanded(
          child: selectedIndex == 0
              ? FutureBuilder(
                  future: ApiMiddleware.orders.getOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        !snapshot.data!.success) {
                      return const Center(child: Text('No orders found'));
                    }

                    final List<OrderItem?> orders = snapshot.data!.data ?? [];

                    if (orders.isEmpty) {
                      return const Center(child: Text('No orders found'));
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: IAMSizes.spaceBtwItems),
                      itemBuilder: (_, index) {
                        final order = orders[index];
                        if (order == null) return const SizedBox.shrink();

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(refNo: order.orderRefno),
                              ),
                            );
                          },
                          child: IAMRoundedContainer(
                            padding: EdgeInsets.all(IAMSizes.md),
                            backgroundColor: dark
                                ? IAMColors.dark
                                : IAMColors.light,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ORDER NUMBER + COPY
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${order.orderRefno}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .apply(fontWeightDelta: 2),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: order.orderRefno),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Order number copied!',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.green[300],
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Iconsax.copy),
                                      iconSize: IAMSizes.iconSm,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: IAMSizes.spaceBtwItems / 2,
                                ),

                                Row(
                                  children: [
                                    // Badge icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: IAMColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Iconsax.routing,
                                        size: 20,
                                        color: IAMColors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: IAMSizes.spaceBtwItems / 2,
                                    ),
                                    // Status & subtitle
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.orderStatusName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .apply(
                                                color: IAMColors.primary,
                                                fontWeightDelta: 1,
                                              ),
                                        ),
                                        Text(
                                          "We're processing your order now!",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // const Divider(),
                                const SizedBox(height: IAMSizes.spaceBtwItems),

                                // ORDER DETAILS: Date with icon
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: IAMColors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Iconsax.calendar,
                                        size: 20,
                                        color: IAMColors.darkGrey,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: IAMSizes.spaceBtwItems / 2,
                                    ),
                                    // Date text
                                    Text(
                                      DateFormat(
                                        'dd-MMM-yyyy, hh:mma',
                                      ).format(DateTime.parse(order.orderDate)),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: IAMSizes.spaceBtwItems),
                                Divider(color: Colors.grey[400], thickness: 1),

                                const SizedBox(
                                  height: IAMSizes.spaceBtwItems / 2,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: ${formatter.format(order.totalAmount)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .apply(
                                            fontWeightDelta: 1,
                                            color: IAMColors.dark,
                                          ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => OrderDetailScreen(
                                              refNo: order.orderRefno,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Iconsax.arrow_right_3,
                                        size: 20,
                                      ),
                                      label: const Text('View Details'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: IAMColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(child: Text('No orders found')),
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
