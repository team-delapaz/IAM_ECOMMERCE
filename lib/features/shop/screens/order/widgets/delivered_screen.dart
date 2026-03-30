import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';

class DeliveredTab extends StatelessWidget {
  const DeliveredTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: IAMColors.white,

      body: ListView.separated(
        padding: const EdgeInsets.all(IAMSizes.md),
        itemCount: 5, // sample count
        separatorBuilder: (_, __) =>
            const SizedBox(height: IAMSizes.spaceBtwItems),
        itemBuilder: (_, index) {
          return _orderCard(context);
        },
      ),
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(BuildContext context) {
    return IAMRoundedContainer(
      padding: const EdgeInsets.all(IAMSizes.md),
      backgroundColor: IAMColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER (Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Delivered',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: IAMColors.primary,
                ),
              ),
              const Icon(Iconsax.tick_circle, color: IAMColors.primary),
            ],
          ),

          const SizedBox(height: IAMSizes.spaceBtwItems),

          /// ITEM LIST
          _itemRow('iPhone 15 Pro Max', '₱75,990', 'x1'),
          const SizedBox(height: IAMSizes.sm),
          _itemRow('AirPods Pro', '₱14,990', 'x1'),

          const SizedBox(height: IAMSizes.spaceBtwItems),

          /// TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Order Total', style: TextStyle(color: Colors.grey)),
              Text('₱90,980', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: IAMSizes.spaceBtwItems),

          Divider(color: Colors.grey[300]),

          const SizedBox(height: IAMSizes.spaceBtwItems),

          /// ACTIONS
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
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
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
                  // You can handle the submitted rating and comment here
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
