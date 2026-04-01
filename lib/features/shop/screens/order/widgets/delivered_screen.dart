import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:intl/intl.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class DeliveredTab extends StatelessWidget {
  const DeliveredTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

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

        final orders = snapshot.data!.data ?? [];

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

            DateTime orderDate;
            try {
              orderDate = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).parse(order.orderDate!);
            } catch (_) {
              orderDate = DateTime.now();
            }

            return _orderCard(context, order, orderDate);
          },
        );
      },
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(BuildContext context, OrderItem order, DateTime orderDate) {
    return GestureDetector(
      onTap: () {
        print('Tapped on order card');
      },
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.md),
        backgroundColor: IAMColors.light,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            /// ---------------- HEADER ----------------
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: IAMColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_circle,
                    size: 20,
                    color: IAMColors.grey,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivered",
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: IAMColors.primary,
                        fontWeightDelta: 1,
                      ),
                    ),

                    Text(
                      DateFormat(
                        'dd-MMM-yyyy, hh:mma',
                      ).format(DateTime.parse(order.orderDate)),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// ---------------- SUBTITLE BELOW TITLE ----------------
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: IAMColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.hashtag,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                // const SizedBox(width: 8),
                // Text(
                //   'Order 123456789',
                //   style: Theme.of(
                //     context,
                //   ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                // ),
                const SizedBox(width: 4),

                Text(
                  'Order ${order.orderRefno}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// ---------------- ITEM LIST ----------------
            _itemRow('Item 1', '₱100.00', 'x1'),
            const SizedBox(height: IAMSizes.sm),
            _itemRow('Item 2', '₱0.00', 'x2'),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// ---------------- TOTAL ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Order Total', style: TextStyle(color: Colors.grey)),
                Text('₱00.00', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            Divider(color: Colors.grey[300]),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// ---------------- ACTIONS ----------------
            Row(
              children: [
                /// RATE (LEFT)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRatingModal(context),
                    icon: const Icon(Iconsax.star, size: 18),
                    label: const Text('Rate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: IAMColors.dark,
                      side: const BorderSide(color: IAMColors.grey),
                      padding: const EdgeInsets.symmetric(
                        vertical: IAMSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: IAMSizes.spaceBtwItems),

                /// BUY AGAIN (RIGHT)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: IAMSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Buy Again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- ITEM ROW ----------------
  Widget _itemRow(String title, String price, String qty) {
    return Row(
      children: [
        /// IMAGE PLACEHOLDER
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(IAMSizes.sm),
          ),
          child: const Icon(Iconsax.box, size: 20),
        ),

        const SizedBox(width: IAMSizes.spaceBtwItems),

        /// NAME
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        /// PRICE + QTY
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price),
            Text(qty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  /// ---------------- SHOW RATING MODAL ----------------
  void _showRatingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: IAMColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: IAMSizes.md,
            right: IAMSizes.md,
            top: IAMSizes.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + IAMSizes.md,
          ),
          child: _RatingSheet(),
        );
      },
    );
  }
}

/// ---------------- RATING SHEET ----------------
class _RatingSheet extends StatefulWidget {
  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: IAMSizes.md),
        const Text(
          'Rate this order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: IAMSizes.md),

        /// ---------------- STARS ----------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < _rating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isSelected ? Iconsax.star1 : Iconsax.star,
                  color: isSelected ? IAMColors.primary : Colors.grey,
                  size: 40,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: IAMSizes.md),

        /// ---------------- COMMENT FIELD ----------------
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),

        const SizedBox(height: IAMSizes.lg),

        /// ---------------- CANCEL / CONFIRM ----------------
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: IAMColors.dark,
                  side: const BorderSide(color: IAMColors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  print('Rating: $_rating');
                  print('Comment: ${_commentController.text}');
                  Navigator.of(context).pop();
                },
                child: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IAMColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: IAMSizes.md),
      ],
    );
  }
}
