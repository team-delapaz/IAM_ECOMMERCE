import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMBottomAddToCart extends StatefulWidget {
  const IAMBottomAddToCart({super.key, this.product});

  final ProductItem? product;

  @override
  State<IAMBottomAddToCart> createState() => _IAMBottomAddToCartState();
}

class _IAMBottomAddToCartState extends State<IAMBottomAddToCart> {
  int _qty = 1;

  Future<void> _addToCart() async {
    final code = widget.product?.productCode;
    if (code == null || code.isEmpty) return;
    final res = await ApiMiddleware.cart.add(productCode: code, qty: _qty);
    if (res.success && mounted) {
      Get.snackbar('Cart', 'Added to cart');
    } else if (mounted) {
      Get.snackbar('Error', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IAMSizes.defaultSpace, vertical: IAMSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: dark ? IAMColors.darkerGrey : IAMColors.light,
        borderRadius:  const BorderRadius.only(
          topLeft: Radius.circular(IAMSizes.cardRadiusLg),
          topRight: Radius.circular(IAMSizes.cardRadiusLg),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_qty > 1) setState(() => _qty--);
                },
                child: IAMCircularIcon(
                  icon: Iconsax.minus,
                  backgroundColor: IAMColors.darkGrey,
                  width: 40,
                  height: 40,
                  color: IAMColors.white,
                ),
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Text('$_qty', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              GestureDetector(
                onTap: () => setState(() => _qty++),
                child: IAMCircularIcon(
                  icon: Iconsax.add,
                  backgroundColor: IAMColors.warning,
                  width: 40,
                  height: 40,
                  color: IAMColors.white,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: widget.product != null ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(IAMSizes.md),
              backgroundColor: IAMColors.warning,
              side: const BorderSide(color: IAMColors.black),
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}