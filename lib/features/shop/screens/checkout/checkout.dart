import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/products.cart/coupon_widget.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/controllers/products/checkout_controller.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_amount_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_payment_provider_section.dart';
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
  AddressItem? _selectedAddress;
  bool _hasSavedAddress = false;
  late final CheckoutController _checkoutController;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
    _checkoutController = Get.isRegistered<CheckoutController>()
        ? CheckoutController.instance
        : Get.put(CheckoutController());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<_CartViewModel> _loadCart() async {
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

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
    final selectedAddress = _selectedAddress;
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address.')),
      );
      return;
    }

    // Determine if the user is logged in (member) or checking out as guest.
    final isLoggedIn =
        Get.isRegistered<AuthController>() &&
        AuthController.instance.isLoggedIn.value;

    String emailAddress = '';
    String memberIdno = '';
    if (isLoggedIn) {
      final memberRes = await ApiMiddleware.member.getMember();
      if (!memberRes.success || memberRes.data == null) {
        // Fallback: use idNo from selected address if available
        memberIdno = selectedAddress.idNo ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              memberRes.message.isNotEmpty
                  ? memberRes.message
                  : 'Unable to load your profile. Proceeding with address info.',
            ),
          ),
        );
      } else {
        final member = memberRes.data!;
        emailAddress = member.emailAddress;
        memberIdno = member.idno;
      }
    } else {
      // Not logged in: fallback to address idNo if available
      memberIdno = selectedAddress.idNo ?? '';
    }

    final notesInput = _notesController.text.trim();
    final notesToSend = notesInput.isEmpty ? 'checkout' : notesInput;

    final res = await ApiMiddleware.checkout.checkout(
      fullName: selectedAddress.recipientName,
      mobileNo: selectedAddress.mobileNo,
      emailAddress: emailAddress,
      country: selectedAddress.country,
      province: selectedAddress.province,
      city: selectedAddress.city,
      barangay: selectedAddress.barangay,
      streetAddress: selectedAddress.streetAddress,
      postalCode: selectedAddress.postalCode,
      completeAddress: selectedAddress.completeAddress,
      notes: notesToSend,
    );
    if (!res.success) {
      final msg = res.message.isNotEmpty ? res.message : 'Checkout failed.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final data = res.data as Map<String, dynamic>? ?? {};
    final orderRef = data['orderRefno'] as String? ?? '';
    final totalAmount = (data['totalAmount'] as num?) ?? model.subtotal;

    // After a successful checkout, create a payment record using the selected
    // payment provider/method and the order reference from the checkout API.
    final providerCode = _checkoutController.selectedPaymentProviderCode.value;
    if (providerCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment provider.')),
      );
      return;
    }

    final paymentRes = await ApiMiddleware.payment.createPayment(
      orderNo: orderRef,
      idno: memberIdno,
      amount: totalAmount,
      currency: 'PHP',
      paymentProvider: providerCode,
      paymentMethod: providerCode,
      description: 'Checkout',
      clientReferenceNo: orderRef,
    );

    if (!paymentRes.success) {
      final msg = paymentRes.message.isNotEmpty
          ? paymentRes.message
          : 'Unable to create payment.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    // Log raw payment response for inspection during integration.
    // ignore: avoid_print
    print('createPayment response: ${paymentRes.data}');

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
            return const Center(
              child: Text('Unable to load checkout details.'),
            );
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
                          style: Theme.of(context).textTheme.bodyLarge
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
                        IAMBillingPaymentProviderSection(),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        IAMBillingPaymentSection(),
                        const SizedBox(height: IAMSizes.spaceBtwItems),
                        IAMBillingAddressSection(
                          onAddressAvailabilityChanged: (hasAddress) {
                            setState(() => _hasSavedAddress = hasAddress);
                          },
                          onAddressSelected: (addr) {
                            // Always set _selectedAddress, even on initial load
                            if (_selectedAddress != addr) {
                              setState(() {
                                _selectedAddress = addr;
                                _hasSavedAddress = addr != null;
                              });
                            } else if (_hasSavedAddress != (addr != null)) {
                              setState(() {
                                _hasSavedAddress = addr != null;
                              });
                            }
                          },
                        ),
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
          return Obx(() {
            final paymentMethodSelected =
                _checkoutController.selectedPaymentMethod.value.name.isNotEmpty;
            String? warningMessage;
            if (!hasItems) {
              warningMessage = 'Your cart is empty.';
            } else if (!paymentMethodSelected) {
              warningMessage = 'Please select a payment method.';
            }
            return Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (!hasItems) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your cart is empty.')),
                        );
                        return;
                      }
                      if (!paymentMethodSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a payment method.')),
                        );
                        return;
                      }
                      _placeOrder(model);
                    },
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
                  if (warningMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      warningMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );
          });
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
