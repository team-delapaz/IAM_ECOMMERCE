import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';

class IAMBillingAmountSection extends StatelessWidget {
  const IAMBillingAmountSection({
    super.key,
    required this.subtotal,
    this.shipping = 0,
    this.tax = 0,
  });

  final num subtotal;
  final num shipping;
  final num tax;

  num get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
            Text('₱${subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('₱${shipping.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax', style: Theme.of(context).textTheme.bodyMedium),
            Text('₱${tax.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('₱${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}