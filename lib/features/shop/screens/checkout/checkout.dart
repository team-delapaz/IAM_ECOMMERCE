import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products.cart/coupon_widget.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/signup.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_amount_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_payment_section.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<_CartViewModel> _cartFuture;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<_CartViewModel> _loadCart() async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;

    if (isLoggedIn) {
      ///////Integrated Checkout Cart (logged in)
      final ApiResponse<CartPayload?> res = await ApiMiddleware.cart.getCart();
      if (!res.success || res.data == null) {
        return _CartViewModel(items: const [], subtotal: 0, error: res.message);
      }
      final cart = res.data!;
      final items = cart.items
          .map(
            (i) => _CheckoutItemView(
              productCode: i.productCode,
              name: i.productName,
              qty: i.qty,
              price: i.sellingPrice,
              lineTotal: i.lineTotal,
            ),
          )
          .toList();
      return _CartViewModel(items: items, subtotal: cart.subtotal);
    }

    ////temporary section while waiting for guest session api pa..
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

    final List<_CheckoutItemView> items = [];
    num subtotal = 0;

    for (final entry in raw) {
      final map = Map<String, dynamic>.from(entry as Map);
      final code = map['productCode'] as String? ?? '';
      final qty = map['qty'] as int? ?? 0;
      if (code.isEmpty || qty <= 0) continue;

      final product = productMap[code];
      final name = product?.productName ?? code;
      final price = product?.memberPrice ?? 0;
      final lineTotal = price * qty;
      subtotal += lineTotal;

      items.add(
        _CheckoutItemView(
          productCode: code,
          name: name,
          qty: qty,
          price: price,
          lineTotal: lineTotal,
        ),
      );
    }

    return _CartViewModel(items: items, subtotal: subtotal);
  }
      ////temp din na section while waiting for guest session api, local storage muna.
  Future<void> _placeOrder(_CartViewModel model) async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() && AuthController.instance.isLoggedIn.value;
    if (!isLoggedIn) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign up required'),
          content: const Text('You need to sign up or log in to check out.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.to(() => const LoginScreen());
              },
              child: const Text('Existing member? Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.to(() => const SignupScreen());
              },
              child: const Text('Sign up'),
            ),
          ],
        ),
      );
      return;
    }

    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter order notes before checkout.')),
      );
      return;
    }

    final res = await ApiMiddleware.checkout.checkout(
      notes: notes,
    );
    if (!res.success) {
      final msg = res.message.isNotEmpty ? res.message : 'Checkout failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    final data = res.data as Map<String, dynamic>? ?? {};
    final orderRef = data['orderRefno'] as String? ?? '';
    final totalAmount = (data['totalAmount'] as num?) ?? model.subtotal;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          orderRef.isNotEmpty
              ? 'Order $orderRef placed successfully.'
              : 'Checkout completed successfully.',
        ),
      ),
    );

    Get.to(
      () => SuccessScreen(
        image: IAMImages.successfulPaymentIcon,
        title: 'Payment Successful!',
        subTitle: orderRef.isNotEmpty
            ? 'Order $orderRef · Total ₱${totalAmount.toStringAsFixed(2)}'
            : 'Your items will be shipped soon!',
        onPressed: () => Get.offAll(() => const NavigationMenu()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(
          'Order Review',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: FutureBuilder<_CartViewModel>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load checkout details.'));
          }
          final model = snapshot.data!;
          if (model.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: IAMSizes.spaceBtwSections),
                    itemBuilder: (context, index) {
                      final item = model.items[index];
                      return ListTile(
                        title: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('x${item.qty}  ·  ${item.productCode}'),
                        trailing: Text(
                          '₱${item.lineTotal.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  IAMCouponCode(),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Order notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: IAMSizes.spaceBtwSections),
                  IAMRoundedContainer(
                    showBorder: true,
                    padding: const EdgeInsets.all(IAMSizes.md),
                    backgroundColor: dark ? IAMColors.black : IAMColors.white,
                    child: Column(
                      children: [
                        IAMBillingAmountSection(subtotal: model.subtotal),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        const Divider(),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        const IAMBillingPaymentSection(),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        const IAMBillingAddressSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<_CartViewModel>(
        future: _cartFuture,
        builder: (context, snapshot) {
          final model = snapshot.data;
          final hasItems = model != null && model.items.isNotEmpty;
          final subtotal = model?.subtotal ?? 0;
          return Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: ElevatedButton(
              onPressed: hasItems ? () => _placeOrder(model!) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: IAMColors.warning,
                foregroundColor: IAMColors.white,
                padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                ),
              ),
              child: Text('Checkout ₱${subtotal.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutItemView {
  final String productCode;
  final String name;
  final int qty;
  final num price;
  final num lineTotal;

  _CheckoutItemView({
    required this.productCode,
    required this.name,
    required this.qty,
    required this.price,
    required this.lineTotal,
  });
}

class _CartViewModel {
  final List<_CheckoutItemView> items;
  final num subtotal;
  final String? error;

  const _CartViewModel({
    required this.items,
    required this.subtotal,
    this.error,
  });
}
