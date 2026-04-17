import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/track_order_screen.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/tracking_screen.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  final String refNo;
  const OrderDetailScreen({super.key, required this.refNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<ApiResponse<OrderDetailItem?>>(
        future: ApiMiddleware.orders.getOrderDetail(refNo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !(snapshot.data?.success ?? false)) {
            return const Center(child: Text('Failed to load order details'));
          }
          final order = snapshot.data!.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final shipping = order.shippingInfo;
          final dark = IAMHelperFunctions.isDarkMode(context);
          final items = order.items ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(IAMSizes.md),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          IAMRoundedContainer(
                            padding: EdgeInsets.all(IAMSizes.md),
                            backgroundColor: dark
                                ? IAMColors.dark
                                : IAMColors.light,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrackingOrderScreen(order: order),
                                        ),
                                      );
                                    },

                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Track Your Order',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Sample Courier • Order #${order.orderRefno}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(
                                      IAMSizes.sm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_shipping,
                                        color: IAMColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order Status Name",
                                            // order.orderStatusName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: IAMColors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat(
                                              'dd-MMM-yyyy, hh:mma',
                                            ).format(
                                              DateTime.parse(order.orderDate),
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            color: IAMColors.primary,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Order #${order.orderRefno}',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .apply(
                                    color: Colors.white,
                                    fontWeightDelta: 2,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(IAMSizes.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipping Information',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (shipping != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_pin,
                                    color: IAMColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${shipping.fullName} • ',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text: shipping.mobileNo,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          shipping.completeAddress,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (shipping.notes.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Notes: ${shipping.notes}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black87,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
                // Text('Date: ${order.orderDate}'),
                // Text('Status: ${order.orderStatusName}'),
                Text(
                  'Payment: ${order.paymentProvider} (${order.paymentStatusMessage})',
                ),
                Text(
                  'Total: ${NumberFormat.currency(locale: 'en_PH', symbol: '₱').format(order.totalAmount)}',
                ),
                const Divider(height: 32),

                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...items.map((item) {
                  if (item == null) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: (item.imageUrl?.isNotEmpty ?? false)
                          ? Image.network(
                              item.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.inventory_2_outlined),
                      title: Text(item.productName ?? ''),
                      subtitle: Text('Qty: ${item.qty ?? 0}'),
                      trailing: Text(
                        '₱${(item.lineTotal ?? 0).toStringAsFixed(2)}',
                      ),
                    ),
                  );
                }),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_PH',
                        symbol: '₱',
                      ).format(order.subtotalAmount),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping:'),
                    Text(
                      IAMFormatter.formatAccountingAmount(
                        order.shippingAmount.toDouble(),
                      ),
                    ),
                  ],
                ),
                if (order.voucherDiscountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voucher Discount:'),
                      Text(
                        '-₱${order.voucherDiscountAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                if (order.discountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Text(
                        '-${IAMFormatter.formatCurrency(order.discountAmount.toDouble())}',
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_PH',
                        symbol: '₱',
                      ).format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // Show "Continue Payment" button if there's a checkout URL available
                /*if (order.checkoutUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text('Continue Payment'),
                  ),
                ],*/
              ],
            ),
          );
        },
      ),
    );
  }
}
