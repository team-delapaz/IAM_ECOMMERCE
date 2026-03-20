import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

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
          if (!snapshot.hasData || snapshot.data == null || !(snapshot.data?.success ?? false)) {
            return const Center(child: Text('Failed to load order details'));
          }
          final order = snapshot.data!.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final shipping = order.shippingInfo;
          final items = order.items ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.orderRefno}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Date: ${order.orderDate}'),
                Text('Status: ${order.orderStatusName}'),
                Text('Payment: ${order.paymentProvider} (${order.paymentStatusMessage})'),
                Text('Total: ₱${order.totalAmount.toStringAsFixed(2)}'),
                const Divider(height: 32),
                Text('Shipping Information', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                if (shipping != null) ...[
                  Text(shipping.fullName),
                  Text(shipping.mobileNo),
                  Text(shipping.completeAddress),
                  if (shipping.notes.isNotEmpty) Text('Notes: ${shipping.notes}'),
                ],
                const Divider(height: 32),
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...items.map((item) {
                  if (item == null) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: (item.imageUrl?.isNotEmpty ?? false)
                          ? Image.network(item.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                          : const Icon(Icons.inventory_2_outlined),
                      title: Text(item.productName ?? ''),
                      subtitle: Text('Qty: ${item.qty ?? 0}'),
                      trailing: Text('₱${(item.lineTotal ?? 0).toStringAsFixed(2)}'),
                    ),
                  );
                }),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('₱${order.subtotalAmount.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping:'),
                    Text('₱${order.shippingAmount.toStringAsFixed(2)}'),
                  ],
                ),
                if (order.voucherDiscountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voucher Discount:'),
                      Text('-₱${order.voucherDiscountAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                if (order.discountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Text('-₱${order.discountAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₱${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
