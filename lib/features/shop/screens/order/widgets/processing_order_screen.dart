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

class ProcessingTab extends StatelessWidget {
  const ProcessingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return FutureBuilder(
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
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: orders.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final order = orders[index];
            if (order == null) return const SizedBox.shrink();

            return _orderCard(context, order, formatter, dark);
          },
        );
      },
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(
    BuildContext context,
    OrderItem order,
    NumberFormat formatter,
    bool dark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
          ),
        );
      },
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.md),
        backgroundColor: dark ? IAMColors.dark : IAMColors.light,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER NUMBER + COPY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.orderRefno}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.apply(fontWeightDelta: 2),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderRefno));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Order number copied!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green[300],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.copy),
                  iconSize: IAMSizes.iconSm,
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems / 2),

            /// STATUS
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: IAMColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.routing,
                    size: 20,
                    color: IAMColors.grey,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderStatusName,
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: IAMColors.primary,
                        fontWeightDelta: 1,
                      ),
                    ),
                    Text(
                      "We're processing your order now!",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// DATE
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: IAMColors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.calendar,
                    size: 20,
                    color: IAMColors.darkGrey,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Text(
                  DateFormat(
                    'dd-MMM-yyyy, hh:mma',
                  ).format(DateTime.parse(order.orderDate)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),

            /// TOTAL + BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${formatter.format(order.totalAmount)}',
                  style: Theme.of(context).textTheme.titleMedium!.apply(
                    fontWeightDelta: 1,
                    color: IAMColors.dark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailScreen(refNo: order.orderRefno),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.arrow_right_3, size: 20),
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
  }
}
