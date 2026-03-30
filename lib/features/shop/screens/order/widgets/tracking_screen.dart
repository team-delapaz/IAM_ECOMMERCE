import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Track Order'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(IAMSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            _buildHeader(),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            /// ETA
            Text(
              'ETA: 15 Min',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// TIMELINE
            _buildTimeline(),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            /// ADDRESS
            _buildAddress(),

            const SizedBox(height: IAMSizes.spaceBtwSections),

            /// RATE
            _buildRating(),
          ],
        ),
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wed, 12 Sep', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Order ID: 5t36-83j4'), Text('Amt: 345.00')],
          ),
        ],
      ),
    );
  }

  /// ---------------- TIMELINE ----------------
  Widget _buildTimeline() {
    return Column(
      children: [
        _buildStep(
          title: 'Ready to Pickup',
          subtitle: 'Order#1234562 from Tasty Food.',
          time: '11:00',
          isActive: true,
          isCompleted: true,
          icon: Iconsax.bag,
        ),
        _buildStep(
          title: 'Order Processed',
          subtitle: 'We are preparing your order.',
          time: '10:08',
          isActive: false,
          isCompleted: true,
          icon: Iconsax.box,
        ),
        _buildStep(
          title: 'Payment Confirmed',
          subtitle: 'Awaiting confirmation...',
          time: '10:06',
          isActive: false,
          isCompleted: true,
          icon: Iconsax.wallet_check,
        ),
        _buildStep(
          title: 'Order Placed',
          subtitle: 'We have received your order.',
          time: '10:04',
          isActive: false,
          isCompleted: true,
          icon: Iconsax.receipt_2,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    bool isActive = false,
    bool isCompleted = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT LINE + DOT
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive
                    ? IAMColors.primary
                    : isCompleted
                    ? Colors.green
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: Colors.grey[300]),
          ],
        ),

        const SizedBox(width: IAMSizes.spaceBtwItems),

        /// ICON
        Icon(icon, size: 20, color: Colors.grey),

        const SizedBox(width: IAMSizes.spaceBtwItems),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        /// TIME
        Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// ---------------- ADDRESS ----------------
  Widget _buildAddress() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Iconsax.location, color: IAMColors.primary),
          SizedBox(width: IAMSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'House No. 13/14, 2nd Floor, Sector 18, Gurgaon...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- RATING ----------------
  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Don't forget to rate",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Help other users by rating your experience.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Iconsax.star, color: Colors.grey),
              Icon(Iconsax.star, color: Colors.grey),
              Icon(Iconsax.star, color: Colors.grey),
              Icon(Iconsax.star, color: Colors.grey),
              Icon(Iconsax.star, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
