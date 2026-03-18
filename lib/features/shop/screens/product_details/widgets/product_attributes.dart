import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/chips/choice_chip.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_price_text.dart';
import 'package:iam_ecomm/common/widgets/texts/product_title_text.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMProductAttributes extends StatelessWidget {
  const IAMProductAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        // -- SELECTED ATTRIBUTE PRICING & DESCRIPTION
        IAMRoundedContainer(
          padding: const EdgeInsets.all(IAMSizes.md),
          backgroundColor: dark ? IAMColors.softGrey : IAMColors.grey,
          child: Column(
            children: [
              // -- TITLE PRICE & STOCK STATUS
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IAMSectionHeading(
                      title: 'Product Summary',
                      showActionButton: false,
                    ),

                    const SizedBox(height: IAMSizes.spaceBtwItems),

                    /// PRICE ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Label Column (Aligned)
                        const SizedBox(
                          width: 80,
                          child: IAMProductTitleText(
                            title: 'Price:',
                            smallSize: true,
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// Prices
                        Text(
                          '₱1,000.00',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                        ),

                        const SizedBox(width: 10),

                        IAMProductPriceText(price: '500.00'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// STOCK ROW
                    Row(
                      children: [
                        /// Label Column (Fixed Width for Alignment)
                        const SizedBox(
                          width: 80,
                          child: IAMProductTitleText(
                            title: 'Stock:',
                            smallSize: true,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          'In Stock',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // // -- VARIATION DESCRIPTION
              // const IAMProductTitleText(
              //   title: 'Selected variation description.',
              //   smallSize: true,
              //   maxLines: 4,
              // ),
            ],
          ),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),

        // -- ATTRIBUTES
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const IAMSectionHeading(title: 'Colors', showActionButton: false),
        //     const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        //     Wrap(
        //       spacing: 10,
        //       children: [
        //         IAMChoiceChip(
        //           text: 'Green',
        //           selected: true,
        //           onSelected: (value) {},
        //         ),
        //         IAMChoiceChip(
        //           text: 'Pink',
        //           selected: false,
        //           onSelected: (value) {},
        //         ),
        //         IAMChoiceChip(
        //           text: 'Purple',
        //           selected: false,
        //           onSelected: (value) {},
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        const SizedBox(height: IAMSizes.spaceBtwItems),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IAMSectionHeading(
              title: 'Bundle Options',
              showActionButton: false,
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems / 2),

            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text("Starter Pack"),
                  ),
                  selected: true,
                  onSelected: (value) {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  selectedColor: Theme.of(context).primaryColor,
                ),

                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text("Energy Bundle"),
                  ),
                  selected: false,
                  onSelected: (value) {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                ),

                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text("Performance Pack"),
                  ),
                  selected: false,
                  onSelected: (value) {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
