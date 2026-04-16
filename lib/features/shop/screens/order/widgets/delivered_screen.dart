import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
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

        final orders = (snapshot.data!.data ?? [])
            .where(
              (order) =>
                  order != null &&
                  order.orderStatusName.toLowerCase() == 'delivered',
            )
            .toList();

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
              ).parse(order.orderDate);
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
    return FutureBuilder<ApiResponse<OrderDetailItem?>>(
      future: ApiMiddleware.orders.getOrderDetail(order.orderRefno),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IAMRoundedContainer(
            padding: const EdgeInsets.all(IAMSizes.md),
            backgroundColor: IAMColors.light,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !(snapshot.data?.success ?? false) ||
            snapshot.data!.data == null) {
          return IAMRoundedContainer(
            padding: const EdgeInsets.all(IAMSizes.md),
            backgroundColor: IAMColors.light,
            child: const Text('Failed to load order details'),
          );
        }

        final orderDetail = snapshot.data!.data!;
        final items = orderDetail.items ?? [];

        return IAMRoundedContainer(
          padding: const EdgeInsets.all(IAMSizes.md),
          backgroundColor: IAMColors.light,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        order.orderStatusName,
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

              /// ---------------- ORDER NUMBER ----------------
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
              Column(
                children: items.where((item) => item != null).map((item) {
                  final nonNullItem = item!;
                  return _itemRow(
                    nonNullItem.productName ?? 'Unnamed Product',
                    NumberFormat.currency(
                      locale: 'en_PH',
                      symbol: '₱',
                      decimalDigits: 2,
                    ).format(nonNullItem.sellingPrice ?? 0),
                    'x${nonNullItem.qty ?? 1}',
                    nonNullItem.imageUrl,
                  );
                }).toList(),
              ),

              const SizedBox(height: IAMSizes.spaceBtwItems * 2),

              /// ---------------- TOTAL ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Total',
                    style: TextStyle(color: Colors.grey),
                  ),
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

              Divider(color: Colors.grey[300]),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              /// ---------------- ACTIONS ----------------
              Row(
                children: [
                  /// RATE / VIEW REVIEW BUTTON
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (items.isEmpty || items.first?.productCode == null)
                          return;

                        final productCode = items.first!.productCode!;

                        // Fetch first review safely
                        final reviewsResponse = await ApiMiddleware
                            .productReview
                            .getReviews(productCode);

                        final hasReviewed =
                            reviewsResponse.success &&
                            reviewsResponse.data != null &&
                            reviewsResponse.data!.isNotEmpty;

                        if (hasReviewed) {
                          final firstReview = reviewsResponse.data!.firstWhere(
                            (r) => r != null,
                            orElse: () => null,
                          );

                          if (firstReview != null) {
                            _showViewReviewModal(context, firstReview);
                            return;
                          }
                        }

                        _showRatingModal(context, productCode);
                      },

                      icon: Icon(
                        Iconsax.star1, // filled star
                        size: 23,
                        color: IAMColors.primary,
                      ),
                      label: const Text('View Rating'),
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

                  /// BUY AGAIN BUTTON
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
        );
      },
    );
  }
}

/// ---------------- ITEM ROW ----------------
Widget _itemRow(String title, String price, String qty, String? imageUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        /// IMAGE
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
    ),
  );
}

/// ---------------- SHOW RATING MODAL ----------------
void _showRatingModal(BuildContext context, String productCode) {
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
        child: _RatingSheet(productCode: productCode),
      );
    },
  );
}

// sho0w rating details

void _showViewReviewModal(BuildContext context, ProductReviewItem review) {
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
        child: Column(
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
              'Your Review',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: IAMSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final rating = review.rating ?? 0;
                final isSelected = index < rating;
                final double size = isSelected ? 44 : 36;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isSelected ? Iconsax.star1 : Iconsax.star,
                    color: IAMColors.primary,
                    size: size,
                  ),
                );
              }),
            ),
            const SizedBox(height: IAMSizes.md),
            Text(
              review.reviewComment ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: IAMSizes.lg),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: IAMColors.dark,
                side: const BorderSide(color: IAMColors.grey),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: IAMSizes.md),
          ],
        ),
      );
    },
  );
}

/// ---------------- RATING SHEET ----------------
class _RatingSheet extends StatefulWidget {
  final String productCode;

  const _RatingSheet({required this.productCode});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
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
              child: AnimatedRotation(
                turns: isSelected ? 0.75 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                child: AnimatedScale(
                  scale: isSelected ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Iconsax.star1 : Iconsax.star,
                      color: isSelected ? IAMColors.primary : Colors.grey,
                      size: isSelected ? 44 : 36,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: IAMSizes.md),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your review here!',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: IAMSizes.lg),
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
                onPressed: () async {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a rating')),
                    );
                    return;
                  }

                  try {
                    final response = await ApiMiddleware.productReview
                        .addReview(
                          productCode: widget.productCode,
                          rating: _rating,
                          reviewComment: _commentController.text,
                        );

                    if (response.success) {
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Review submitted successfully!'),
                          backgroundColor: Colors.green[300],
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response.message ?? 'Failed to submit review',
                          ),
                          backgroundColor: Colors.red[300],
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Something went wrong'),
                        backgroundColor: Colors.red[300],
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
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
