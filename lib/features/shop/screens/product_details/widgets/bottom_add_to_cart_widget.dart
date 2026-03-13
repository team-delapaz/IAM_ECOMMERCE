import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/icons/circular_icon.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
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
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;

    ////TEmporary section while waiting for guest session api
    if (!isLoggedIn) {
      final storage = IAMLocalStorage();
      final existing = storage.readData<List>('guest_cart') ?? [];
      final cart = existing
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final index = cart.indexWhere((e) => e['productCode'] == code);
      if (index >= 0) {
        final current = cart[index]['qty'] as int? ?? 0;
        cart[index]['qty'] = current + _qty;
      } else {
        cart.add({'productCode': code, 'qty': _qty});
      }
      await storage.saveData('guest_cart', cart);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart (guest).')),
      );
      return;
    }

    final res = await ApiMiddleware.cart.add(productCode: code, qty: _qty);
    if (!mounted) return;

    if (res.success) {
      final msg =
          res.message.isNotEmpty ? res.message : 'Item added to cart.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } else {
      final msg = res.message.isNotEmpty
          ? res.message
          : 'Unable to add item to cart.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add to cart failed: $msg')),
      );
    }
  }

  Future<void> _checkout() async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;

    await _addToCart();
    if (!mounted) return;

    if (isLoggedIn) {
      Get.to(() => const CartScreen());
    } else {
      Get.to(() => const CheckoutScreen());
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