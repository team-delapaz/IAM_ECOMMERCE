import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_status_ids.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CancelledTab extends StatelessWidget {
  const CancelledTab({super.key});

  Future<List<Map<String, dynamic>>> fetchAllDetails(
    List<OrderItem?> orders,
  ) async {
    final results = await Future.wait(
      orders.map((o) => ApiMiddleware.orders.getOrderDetail(o!.orderRefno)),
    );

    final List<Map<String, dynamic>> combined = [];

    for (int i = 0; i < orders.length; i++) {
      final order = orders[i];
      final detailResponse = results[i];

      if (order != null &&
          detailResponse.success &&
          detailResponse.data != null) {
        combined.add({'order': order, 'detail': detailResponse.data});
      }
    }

    return combined;
  }

  @override
  Widget build(BuildContext context) {
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

        const terminalIds = {
          OrderStatusIds.cancelled,
          OrderStatusIds.failedDelivery,
          OrderStatusIds.returned,
          OrderStatusIds.lostAndDamaged,
        };
        final orders = (snapshot.data!.data ?? [])
            .where(
              (order) =>
                  order != null && terminalIds.contains(order.orderStatusId),
            )
            .toList();

        if (orders.isEmpty) {
          return const Center(child: Text('No orders in this category'));
        }

        return FutureBuilder(
          future: fetchAllDetails(orders),
          builder: (context, detailSnapshot) {
            if (detailSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!detailSnapshot.hasData ||
                detailSnapshot.data == null ||
                detailSnapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found'));
            }

            final combined = detailSnapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(IAMSizes.md),
              itemCount: combined.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: IAMSizes.spaceBtwItems),
              itemBuilder: (_, index) {
                final data = combined[index];
                final order = data['order'] as OrderItem;
                final orderDetail = data['detail'] as OrderDetailItem;

                return _orderCard(context, order, orderDetail);
              },
            );
          },
        );
      },
    );
  }

  Widget _orderCard(
    BuildContext context,
    OrderItem order,
    OrderDetailItem orderDetail,
  ) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final items = orderDetail.items;

    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: dark ? IAMColors.dark : IAMColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.close_circle,
                  size: 20,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderStatusName.isNotEmpty
                        ? order.orderStatusName
                        : 'Cancelled',
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Colors.red.shade800,
                          fontWeightDelta: 1,
                        ),
                  ),
                  Text(
                    DateFormat('dd-MMM-yyyy, hh:mma').format(
                      DateTime.tryParse(order.orderDate) ?? DateTime.now(),
                    ),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.darkerGrey : IAMColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.hashtag,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Order ${order.orderRefno}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems),
          Column(
            children: items.whereType<OrderProductItem>().map((line) {
              return _itemRow(
                dark: dark,
                title: line.productName.isEmpty
                    ? 'Unnamed Product'
                    : line.productName,
                price: NumberFormat.currency(
                  locale: 'en_PH',
                  symbol: '₱',
                  decimalDigits: 2,
                ).format(line.sellingPrice),
                qty: 'x${line.qty}',
                imageUrl: line.imageUrl.isEmpty ? null : line.imageUrl,
              );
            }).toList(),
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Total', style: TextStyle(color: Colors.grey)),
              Text(
                NumberFormat.currency(
                  locale: 'en_PH',
                  symbol: '₱',
                  decimalDigits: 2,
                ).format(orderDetail.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _itemRow({
  required bool dark,
  required String title,
  required String price,
  required String qty,
  required String? imageUrl,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: dark ? IAMColors.darkerGrey : Colors.grey[200],
            borderRadius: BorderRadius.circular(IAMSizes.sm),
            image: (imageUrl != null && imageUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (imageUrl == null || imageUrl.isEmpty)
              ? const Icon(Iconsax.box, size: 20)
              : null,
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price),
            Text(qty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}
