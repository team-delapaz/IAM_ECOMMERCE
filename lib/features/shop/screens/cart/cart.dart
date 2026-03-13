import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<_CartViewModel> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<_CartViewModel> _loadCart() async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;

    if (isLoggedIn) {
      ///////Integrated Logged-in Cart
      final ApiResponse<CartPayload?> res = await ApiMiddleware.cart.getCart();
      if (!res.success || res.data == null) {
        return _CartViewModel(items: const [], subtotal: 0, error: res.message);
      }
      final cart = res.data!;
      final items = cart.items
          .map(
            (i) => _CartItemView(
              productCode: i.productCode,
              name: i.productName,
              imageUrl: i.imageUrl,
              qty: i.qty,
              price: i.sellingPrice,
              lineTotal: i.lineTotal,
            ),
          )
          .toList();
      return _CartViewModel(
        items: items,
        subtotal: cart.subtotal,
      );
    }

    ////TEmporary section while waiting for guest session api
    final storage = IAMLocalStorage();
    final raw = storage.readData<List>('guest_cart') ?? [];
    if (raw.isEmpty) {
      return const _CartViewModel(items: [], subtotal: 0);
    }

    final productsRes = await ApiMiddleware.products.getProducts();
    final productsList = productsRes.data ?? [];
    final productMap = {
      for (final p in productsList.whereType<ProductItem>()) p.productCode: p,
    };

    final List<_CartItemView> items = [];
    num subtotal = 0;

    for (final entry in raw) {
      final map = Map<String, dynamic>.from(entry as Map);
      final code = map['productCode'] as String? ?? '';
      final qty = map['qty'] as int? ?? 0;
      if (code.isEmpty || qty <= 0) continue;

      final product = productMap[code];
      final name = product?.productName ?? code;
      final price = product?.memberPrice ?? 0;
      final imageUrl = product?.imageUrl ?? '';
      final lineTotal = price * qty;
      subtotal += lineTotal;

      items.add(
        _CartItemView(
          productCode: code,
          name: name,
          imageUrl: imageUrl,
          qty: qty,
          price: price,
          lineTotal: lineTotal,
        ),
      );
    }

    return _CartViewModel(items: items, subtotal: subtotal);
  }

  Future<void> _updateQuantity(_CartItemView item, int newQty) async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;

    if (isLoggedIn) {
      final safeQty = newQty < 0 ? 0 : newQty;
      await ApiMiddleware.cart.updateQty(item.productCode, safeQty);
    } else {
      final storage = IAMLocalStorage();
      final raw = storage.readData<List>('guest_cart') ?? [];
      final cart = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final index = cart.indexWhere((e) => e['productCode'] == item.productCode);
      if (index >= 0) {
        if (newQty <= 0) {
          cart.removeAt(index);
        } else {
          cart[index]['qty'] = newQty;
        }
        await storage.saveData('guest_cart', cart);
      }
    }

    setState(() {
      _cartFuture = _loadCart();
    });
  }

  Future<void> _removeItem(_CartItemView item) => _updateQuantity(item, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text('Cart', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
        child: FutureBuilder<_CartViewModel>(
          future: _cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Unable to load cart.'));
            }
            final model = snapshot.data!;
            if (model.error != null && model.items.isEmpty) {
              return Center(child: Text(model.error!));
            }
            if (model.items.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }
            return ListView.separated(
              itemCount: model.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: IAMSizes.spaceBtwSections),
              itemBuilder: (context, index) {
                final item = model.items[index];
                return Container(
                  padding: const EdgeInsets.all(IAMSizes.md),
                  decoration: BoxDecoration(
                    color: IAMColors.white,
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                    boxShadow: kElevationToShadow[1],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (item.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(IAMSizes.sm),
                          child: Image.network(
                            item.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const SizedBox(width: 56, height: 56),
                      const SizedBox(width: IAMSizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'x${item.qty}  ·  ${item.productCode}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: IAMSizes.spaceBtwItems),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₱${item.lineTotal.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(IAMSizes.cardRadiusSm),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withOpacity(0.6),
                      ),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: item.qty > 1
                                          ? () => _updateQuantity(
                                                item,
                                                item.qty - 1,
                                              )
                                          : () => _removeItem(item),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.qty}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _updateQuantity(item, item.qty + 1),
                                      child: const Icon(Icons.add, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                                onPressed: () => _removeItem(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder<_CartViewModel>(
        future: _cartFuture,
        builder: (context, snapshot) {
          final model = snapshot.data;
          final hasItems = model != null && model.items.isNotEmpty;
          final subtotal = model?.subtotal ?? 0;
          return Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '₱${subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: hasItems
                      ? () => Get.to(() => const CheckoutScreen())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.warning,
                    foregroundColor: IAMColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: IAMSizes.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(IAMSizes.cardRadiusLg),
                    ),
                  ),
                  child:
                      Text('Checkout ₱${subtotal.toStringAsFixed(2)}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartItemView {
  final String productCode;
  final String name;
  final String imageUrl;
  final int qty;
  final num price;
  final num lineTotal;

  _CartItemView({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.qty,
    required this.price,
    required this.lineTotal,
  });
}

class _CartViewModel {
  final List<_CartItemView> items;
  final num subtotal;
  final String? error;

  const _CartViewModel({
    required this.items,
    required this.subtotal,
    this.error,
  });
}