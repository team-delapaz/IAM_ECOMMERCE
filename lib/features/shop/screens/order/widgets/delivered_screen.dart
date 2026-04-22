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

  Future<List<Map<String, dynamic>>> fetchAllDetails(
    List<OrderItem?> orders,
  ) async {
    final results = await Future.wait(
      orders.map((o) => ApiMiddleware.orders.getOrderDetail(o!.orderRefno)),
    );

    List<Map<String, dynamic>> combined = [];

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

                DateTime orderDate;
                try {
                  orderDate = DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).parse(order.orderDate);
                } catch (_) {
                  orderDate = DateTime.now();
                }

                return _orderCard(context, order, orderDate, orderDetail);
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
    DateTime orderDate,
    OrderDetailItem orderDetail,
  ) {
    final items = orderDetail.items ?? [];

    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: IAMColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
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

          Divider(color: Colors.grey[300]),
          const SizedBox(height: IAMSizes.spaceBtwItems),

          Row(
            children: [
              Expanded(
                child: FutureBuilder<ApiResponse<List<ProductReviewItem?>>>(
                  future: (items.isNotEmpty && items.first?.productCode != null)
                      ? ApiMiddleware.productReview.getReviews(
                          items.first!.productCode!,
                        )
                      : null,
                  builder: (context, reviewSnapshot) {
                    bool hasReviewed = false;
                    ProductReviewItem? firstReview;

                    if (reviewSnapshot.hasData &&
                        reviewSnapshot.data!.success &&
                        reviewSnapshot.data!.data != null) {
                      final reviews = reviewSnapshot.data!.data!
                          .where((r) => r != null)
                          .cast<ProductReviewItem>()
                          .toList();

                      if (reviews.isNotEmpty) {
                        hasReviewed = true;
                        firstReview = reviews.first;
                      }
                    }

                    return OutlinedButton.icon(
                      onPressed: () async {
                        if (items.isEmpty || items.first?.productCode == null)
                          return;

                        final productCode = items.first!.productCode!;

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
                        }

                        _showRatingModal(
                          context,
                          productCode,
                          order.orderRefno,
                        );
                      },
                      icon: const Icon(
                        Iconsax.star1,
                        size: 23,
                        color: IAMColors.primary,
                      ),
                      label: Text(hasReviewed ? 'View Rating' : 'Rate'),
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
                    );
                  },
                ),
              ),

              const SizedBox(width: IAMSizes.spaceBtwItems),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
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
  }
}

// (rest of your code unchanged: _itemRow, modals, _RatingSheet)

Widget _itemRow(String title, String price, String qty, String? imageUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
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

/// ---------------- SHOW RATING MODAL ----------------
void _showRatingModal(
  BuildContext context,
  String productCode,
  String orderRefNo,
) {
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
        child: _RatingSheet(productCode: productCode, orderRefNo: orderRefNo),
      );
    },
  );
}

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

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isSelected ? Iconsax.star1 : Iconsax.star,
                    color: IAMColors.primary,
                    size: isSelected ? 44 : 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: IAMSizes.md),
            Text(review.reviewComment ?? ''),
            const SizedBox(height: IAMSizes.lg),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}

class _RatingSheet extends StatefulWidget {
  final String productCode;
  final String orderRefNo;

  const _RatingSheet({required this.productCode, required this.orderRefNo});

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isSelected ? Iconsax.star1 : Iconsax.star,
                  color: isSelected ? IAMColors.primary : Colors.grey,
                  size: isSelected ? 44 : 36,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: IAMSizes.md),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write your review here!',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: IAMSizes.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_rating == 0) return;

                  try {
                    final response = await ApiMiddleware.productReview
                        .addReview(
                          productCode: widget.productCode,
                          orderRefNo: widget.orderRefNo,
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
                            response.message.isNotEmpty
                                ? response.message
                                : 'Failed to submit review',
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
              ),
            ),
          ],
        ),
        const SizedBox(height: IAMSizes.md),
      ],
    );
  }
}
