import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

class IAMCartCounterIcon extends StatefulWidget {
  const IAMCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  State<IAMCartCounterIcon> createState() => _IAMCartCounterIconState();
}

class _IAMCartCounterIconState extends State<IAMCartCounterIcon> {
  late Future<int> _cartCountFuture;

  @override
  void initState() {
    super.initState();
    _cartCountFuture = _loadCartCount();
  }

  Future<int> _loadCartCount() async {
    final res = await ApiMiddleware.cart.getCart();
    if (!res.success || res.data == null) return 0;
    return res.data!.totalQty;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            widget.onPressed();
            Get.to(() => const CartScreen())?.then((_) {
              if (!mounted) return;
              setState(() {
                _cartCountFuture = _loadCartCount();
              });
            });
          },
          icon: Icon(
            Iconsax.shopping_bag,
            color: widget.iconColor ?? Theme.of(context).iconTheme.color,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 2,
          child: FutureBuilder<int>(
            future: _cartCountFuture,
            initialData: 0,
            builder: (context, snapshot) {
              final totalQty = snapshot.data ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: BoxDecoration(
                  color: IAMColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.90),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$totalQty',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: IAMColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          Theme.of(context).textTheme.labelLarge!.fontSize! *
                          0.75,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
