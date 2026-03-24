import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_detail_screen.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iconsax/iconsax.dart';

class IAMOrderListItems extends StatelessWidget {
  const IAMOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return FutureBuilder(
      future: ApiMiddleware.orders.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.success) {
          return const Center(child: Text('No orders found'));
        }
        final List<OrderItem?> orders = snapshot.data!.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final order = orders[index];
            if (order == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
                  ),
                );
              },
              child: IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.dark : IAMColors.light,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.routing),
                        const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderStatusName,
                                style: Theme.of(context).textTheme.bodyLarge!.apply(
                                  color: IAMColors.primary,
                                  fontWeightDelta: 1,
                                ),
                              ),
                              Text(
                                order.orderDate,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
                              ),
                            );
                          },
                          icon: const Icon(
                            Iconsax.arrow_right_34,
                            size: IAMSizes.iconSm,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwItems),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Iconsax.tag),
                              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    Text(
                                      '#${order.orderRefno}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Iconsax.calendar),
                              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    Text(
                                      '${order.totalAmount}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}
