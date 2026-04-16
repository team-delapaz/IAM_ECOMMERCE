import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class TrackingOrderScreen extends StatelessWidget {
  const TrackingOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tracking Result'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.md),
        child: Column(
          children: [
            /// PRODUCT CARD
            _productCard(),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            /// ORDER DETAILS
            _orderDetails(),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            /// TIMELINE
            Expanded(child: _timeline()),

            /// BUTTONS
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  /// ---------------- PRODUCT CARD ----------------
  Widget _productCard() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Row(
        children: [
          /// IMAGE
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(IAMSizes.md),
            ),
            child: const Icon(Iconsax.mobile, size: 28),
          ),

          const SizedBox(width: IAMSizes.spaceBtwItems),

          /// TITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Item Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Order ID: 123 Sample Number',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          /// COPY ICON
          const Icon(Iconsax.copy, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  /// ---------------- ORDER DETAILS ----------------
  Widget _orderDetails() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Column(
        children: [
          const Text(
            'Order Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: IAMSizes.spaceBtwItems),

          _row('Customer Name:', 'Sample'),

          _row('Destination:', 'Sample Address'),
          _row('Quantity:', '1'),
          _row('Payment:', 'Success'),

          /// STATUS BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status:'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: IAMColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'In Transit',
                  style: TextStyle(
                    color: IAMColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IAMSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- TIMELINE ----------------
  /// ---------------- TIMELINE ----------------
  Widget _timeline() {
    return Column(
      children: [
        _step('Processing', 'Courier Warehouse 1', isDone: true),
        _step(
          'In Transit',
          'Courier Warehouse 2',
          isDone: true,
          isCurrent: true,
        ), // recent status
        _step('Out of Delivery', 'On the way', isDone: false),
        _step('Delivered', 'Sample Address', isDone: false, isLast: true),
      ],
    );
  }

  Widget _step(
    String title,
    String subtitle, {
    required bool isDone,
    bool isLast = false,
    bool isCurrent = false, // new parameter
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// DOT + LINE
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone
                    ? (isCurrent ? IAMColors.primary : Colors.black)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(
                      Iconsax.tick_circle,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: Colors.grey[300]),
          ],
        ),

        const SizedBox(width: IAMSizes.spaceBtwItems),

        /// TEXT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDone
                    ? (isCurrent ? IAMColors.primary : Colors.black)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// ---------------- BUTTONS ----------------
  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: IAMSizes.md),
      child: Row(
        children: [
          /// CANCEL
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Cancel Order'),
            ),
          ),

          const SizedBox(width: IAMSizes.spaceBtwItems),

          /// LIVE TRACKING
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
              child: const Text('Live Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
