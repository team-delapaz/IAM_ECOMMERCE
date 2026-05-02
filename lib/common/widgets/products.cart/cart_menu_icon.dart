import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iam_ecomm/features/shop/screens/cart/cart.dart';
import 'package:iam_ecomm/utils/api/api.dart';
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
          right: 0,
          child: FutureBuilder<int>(
            future: _cartCountFuture,
            initialData: 0,
            builder: (context, snapshot) {
              final totalQty = snapshot.data ?? 0;
              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    '$totalQty',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize:
                          Theme.of(context).textTheme.labelLarge!.fontSize! *
                          0.8,
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
