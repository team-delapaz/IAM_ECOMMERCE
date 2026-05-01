import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';

class IAMBillingAmountSection extends StatelessWidget {
  const IAMBillingAmountSection({
    super.key,
    required this.subtotal,
    this.shipping = 0,
    this.tax = 0,
    this.totalOverride,
  });

  final num subtotal;
  final num shipping;
  final num tax;
  final num? totalOverride;

  num get total => totalOverride ?? (subtotal + shipping + tax);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
            Text(IAMFormatter.formatCurrency(subtotal.toDouble()),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(IAMFormatter.formatAccountingAmount(shipping.toDouble()),
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Processing Fee', style: Theme.of(context).textTheme.bodyMedium),
            Text(IAMFormatter.formatAccountingAmount(tax.toDouble()),
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(IAMFormatter.formatCurrency(total.toDouble()),
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}