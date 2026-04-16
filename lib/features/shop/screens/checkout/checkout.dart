import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/common/widgets/products.cart/coupon_widget.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/controllers/products/checkout_controller.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_amount_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_payment_provider_section.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:webview_flutter/webview_flutter.dart';

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

  Future<void> _showOpeningCheckoutSpinner() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final dark = IAMHelperFunctions.isDarkMode(context);
        final surface = dark ? IAMColors.black : IAMColors.white;
        final onSurface = dark ? IAMColors.white : IAMColors.black;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: surface,
            elevation: 24,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opening checkout page…',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please wait while we prepare your payment.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: onSurface.withOpacity(0.72),
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _showCheckoutUrlSheet({
    required String checkoutUrl,
    required String orderRef,
    required num totalAmount,
  }) async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return _CheckoutWebViewSheet(
          checkoutUrl: checkoutUrl,
          orderRef: orderRef,
          totalAmount: totalAmount,
        );
      },
    );
  }

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
              imageUrl: i.imageUrl,
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
          imageUrl: product?.imageUrl ?? '',
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
        SnackBar(
          content: const Text(
            'Please select a shipping address.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
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
        memberIdno = selectedAddress.idNo;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              memberRes.message.isNotEmpty
                  ? memberRes.message
                  : 'Unable to load your profile. Proceeding with address info.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[300],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      } else {
        final member = memberRes.data!;
        emailAddress = member.emailAddress;
        memberIdno = member.idno;
      }
    } else {
      // Not logged in: fallback to address idNo if available
      memberIdno = selectedAddress.idNo;
    }

    final notesInput = _notesController.text.trim();
    final notesToSend = notesInput.isEmpty ? 'checkout' : notesInput;

    // Ensure a payment provider is selected before performing checkout.
    final providerCode = _checkoutController.selectedPaymentProviderCode.value;
    if (providerCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select a payment provider.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    final res = await ApiMiddleware.checkout.checkout(
      fullName: selectedAddress.recipientName,
      mobileNo: selectedAddress.mobileNo,
      emailAddress: emailAddress,
      paymentProviderCode: providerCode,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    final data = res.data as Map<String, dynamic>? ?? {};
    final orderRef = data['orderRefno'] as String? ?? '';
    final totalAmount = (data['totalAmount'] as num?) ?? model.subtotal;

    // After a successful checkout, create a payment record using the selected
    // payment provider/method and the order reference from the checkout API.
    if (providerCode.toUpperCase() == 'IAMWALLET') {
      final paid = await _showIamWalletSheet(
        orderRef: orderRef,
        totalAmount: totalAmount,
      );
      if (!paid) return;
      _showPaymentSuccess(
        orderRef: orderRef,
        totalAmount: totalAmount,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    final checkoutUrl = paymentRes.data?.checkoutUrl ?? '';
    if (checkoutUrl.isNotEmpty) {
      await _showOpeningCheckoutSpinner();
      if (!mounted) return;
      await _showCheckoutUrlSheet(
        checkoutUrl: checkoutUrl,
        orderRef: orderRef,
        totalAmount: totalAmount,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          orderRef.isNotEmpty
              ? 'Order $orderRef placed successfully.'
              : 'Checkout completed successfully.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    _showPaymentSuccess(
      orderRef: orderRef,
      totalAmount: totalAmount,
    );
  }

  Future<bool> _showIamWalletSheet({
    required String orderRef,
    required num totalAmount,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IamWalletPaymentSheet(
        orderRef: orderRef,
        totalAmount: totalAmount,
      ),
    );
    return result ?? false;
  }

  void _showPaymentSuccess({
    required String orderRef,
    required num totalAmount,
  }) {
    Get.to(
      () => SuccessScreen(
        image: IAMImages.successfulPaymentIcon,
        title: 'Payment Successful!',
        subTitle: orderRef.isNotEmpty
            ? 'Order $orderRef · Total ${IAMFormatter.formatCurrency(totalAmount.toDouble())}'
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
                        leading: item.imageUrl.isNotEmpty
                            ? IAMRoundedImage(
                                width: 48,
                                height: 48,
                                imageUrl: item.imageUrl,
                                isNetworkImage: true,
                                fit: BoxFit.cover,
                                backgroundColor:
                                    dark ? IAMColors.black : IAMColors.white,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: dark
                                      ? IAMColors.darkGrey
                                      : IAMColors.light,
                                  borderRadius:
                                      BorderRadius.circular(IAMSizes.md),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 20,
                                ),
                              ),
                        title: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('x${item.qty}  ·  ${item.productCode}'),
                            const SizedBox(height: 2),
                            Text(
                              'Price: ${IAMFormatter.formatCurrency(item.price.toDouble())}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Text(
                          IAMFormatter.formatCurrency(item.lineTotal.toDouble()),
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
            final paymentProviderSelected =
                _checkoutController.selectedPaymentProviderCode.isNotEmpty;
            String? warningMessage;
            if (!hasItems) {
              warningMessage = 'Your cart is empty.';
            } else if (!paymentProviderSelected) {
              warningMessage = 'Please select a payment provider.';
            }
            return SafeArea(
              top: false,
              minimum: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: (!hasItems || !paymentProviderSelected)
                        ? null
                        : () {
                      if (!hasItems) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Your cart is empty.',
                              style: TextStyle(color: Color.fromARGB(255, 35, 35, 35)),
                            ),
                            backgroundColor: Colors.red[300],
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                        return;
                      }
                      if (!paymentProviderSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please select a payment method.',
                              style: TextStyle(color: Color.fromARGB(255, 35, 35, 35)),
                            ),
                            backgroundColor: Colors.red[300],
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                        return;
                      }

                      _placeOrder(model);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: IAMColors.white,
                      disabledBackgroundColor: IAMColors.grey,
                      disabledForegroundColor: const Color.fromARGB(255, 146, 0, 0),
                      padding: const EdgeInsets.symmetric(
                        vertical: IAMSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          IAMSizes.cardRadiusLg,
                        ),
                      ),
                    ),
                    child: Text(
                      ((!hasItems || !paymentProviderSelected) &&
                                  warningMessage !=
                                      null)
                              ? warningMessage
                              : 'Checkout ${IAMFormatter.formatCurrency(subtotal.toDouble())}',
                      textAlign: TextAlign.center,
                    ),
                  ),
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
  final String imageUrl;
  final int qty;
  final num price;
  final num lineTotal;

  _CheckoutItemView({
    required this.productCode,
    required this.name,
    required this.imageUrl,
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

class _WalletModalSideAccent extends StatelessWidget {
  const _WalletModalSideAccent({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final gold = IAMColors.primary;
    return Container(
      width: 108,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [
                  gold.withOpacity(0.22),
                  gold.withOpacity(0.06),
                  const Color(0xFF101217),
                ]
              : [
                  gold.withOpacity(0.18),
                  const Color(0xFFFFF8E1).withOpacity(0.55),
                  IAMColors.lightGrey,
                ],
        ),
        border: Border(
          right: BorderSide(
            color: (dark ? IAMColors.white : IAMColors.black).withOpacity(0.08),
          ),
        ),
      ),
      child: SafeArea(
        left: true,
        top: false,
        bottom: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (dark ? IAMColors.black : IAMColors.white).withOpacity(
                    dark ? 0.35 : 0.75,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: gold.withOpacity(dark ? 0.35 : 0.45),
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  IAMImages.walletIcon,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  semanticLabel: 'IAM Wallet',
                ),
              ),
              const Spacer(),
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: gold.withOpacity(0.85),
              ),
              const SizedBox(height: 6),
              Text(
                'Secure',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: (dark ? IAMColors.white : IAMColors.textPrimary)
                          .withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IamWalletPaymentSheet extends StatefulWidget {
  const _IamWalletPaymentSheet({
    required this.orderRef,
    required this.totalAmount,
  });

  final String orderRef;
  final num totalAmount;

  @override
  State<_IamWalletPaymentSheet> createState() => _IamWalletPaymentSheetState();
}

class _IamWalletPaymentSheetState extends State<_IamWalletPaymentSheet> {
  WalletBalanceData? _walletData;
  bool _loadingBalance = true;
  bool _isValidating = false;
  bool _isPaying = false;
  bool _validated = false;
  String? _statusText;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _loadingBalance = true;
      _statusText = null;
      _statusIsError = false;
    });
    final res = await ApiMiddleware.wallet.getBalance();
    if (!mounted) return;
    setState(() {
      _loadingBalance = false;
      _walletData = res.data;
      if (!res.success) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to load wallet balance.';
        _statusIsError = true;
      }
    });
  }

  Future<bool> _validateOrder({bool showSuccessMessage = true}) async {
    if (_isValidating || _isPaying) return false;
    setState(() {
      _isValidating = true;
      _statusText = null;
      _statusIsError = false;
    });
    final res = await ApiMiddleware.wallet.validateOrder(
      amount: widget.totalAmount,
      orderRefNo: widget.orderRef,
      remarks: 'Wallet validation',
    );
    if (!mounted) return false;
    setState(() {
      _isValidating = false;
      _validated = res.success;
      final data = res.data;
      if (res.success && data != null) {
        _walletData = WalletBalanceData(
          accountId: data.accountId,
          balance: data.remainingBalance,
        );
      }
      if (res.success && showSuccessMessage) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Order validated. You can proceed to payment.';
        _statusIsError = false;
      } else if (!res.success) {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Unable to validate wallet payment.';
        _statusIsError = true;
      }
    });
    return res.success;
  }

  Future<void> _payOrder() async {
    if (_isPaying || _isValidating) return;
    setState(() {
      _isPaying = true;
      _statusText = null;
      _statusIsError = false;
    });

    var isValidated = _validated;
    if (!isValidated) {
      isValidated = await _validateOrder(showSuccessMessage: false);
      if (!mounted) return;
      if (!isValidated) {
        setState(() => _isPaying = false);
        return;
      }
    }

    final res = await ApiMiddleware.wallet.payOrder(
      amount: widget.totalAmount,
      orderRefNo: widget.orderRef,
      remarks: 'Wallet payment',
    );
    if (!mounted) return;
    setState(() => _isPaying = false);

    if (!res.success) {
      setState(() {
        _statusText = res.message.isNotEmpty
            ? res.message
            : 'Wallet payment was not completed.';
        _statusIsError = true;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.66);
    final amountText = IAMFormatter.formatCurrency(widget.totalAmount.toDouble());
    final balance = _walletData?.balance ?? 0;
    final balanceText = IAMFormatter.formatCurrency(balance.toDouble());
    final canPay = !_loadingBalance && !_isPaying && !_isValidating;

    return FractionallySizedBox(
      heightFactor: 0.86,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.6 : 0.2),
                blurRadius: 28,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(dark ? 0.22 : 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WalletModalSideAccent(dark: dark),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              IAMSizes.md,
                              12,
                              4,
                              8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'IAM Wallet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: onSurface,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.orderRef.isNotEmpty
                                            ? 'Order ${widget.orderRef}'
                                            : 'Wallet checkout',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: muted,
                                              height: 1.2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: _isPaying
                                      ? null
                                      : () => Navigator.of(context).pop(false),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: onSurface.withOpacity(0.72),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                IAMSizes.md,
                                0,
                                IAMSizes.defaultSpace,
                                IAMSizes.defaultSpace,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: onSurface.withOpacity(
                                          dark ? 0.14 : 0.1,
                                        ),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: dark
                                            ? [
                                                IAMColors.black,
                                                IAMColors.black.withOpacity(0.92),
                                              ]
                                            : [
                                                IAMColors.white,
                                                IAMColors.softGrey,
                                              ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(IAMSizes.md),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _WalletMetric(
                                              label: 'Wallet balance',
                                              value: _loadingBalance
                                                  ? '…'
                                                  : balanceText,
                                              valueColor: _loadingBalance
                                                  ? muted
                                                  : IAMColors.primary,
                                              dark: dark,
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 52,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            color: onSurface.withOpacity(0.1),
                                          ),
                                          Expanded(
                                            child: _WalletMetric(
                                              label: 'Amount due',
                                              value: amountText,
                                              valueColor: onSurface,
                                              dark: dark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_walletData != null) ...[
                                    const SizedBox(height: 12),
                                    IAMRoundedContainer(
                                      showBorder: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: IAMSizes.sm,
                                        vertical: 8,
                                      ),
                                      backgroundColor: dark
                                          ? IAMColors.black.withOpacity(0.45)
                                          : IAMColors.accent.withOpacity(0.35),
                                      borderColor: IAMColors.primary.withOpacity(
                                        dark ? 0.28 : 0.22,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.badge_outlined,
                                            size: 18,
                                            color: IAMColors.primary.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Account ${_walletData!.accountId}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.copyWith(
                                                    color: onSurface.withOpacity(
                                                      0.88,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_statusText != null) ...[
                                    const SizedBox(height: 14),
                                    IAMRoundedContainer(
                                      backgroundColor: _statusIsError
                                          ? Colors.red.withOpacity(
                                              dark ? 0.2 : 0.1,
                                            )
                                          : Colors.green.withOpacity(
                                              dark ? 0.2 : 0.1,
                                            ),
                                      borderColor: _statusIsError
                                          ? Colors.red.withOpacity(
                                              dark ? 0.4 : 0.2,
                                            )
                                          : Colors.green.withOpacity(
                                              dark ? 0.4 : 0.2,
                                            ),
                                      showBorder: true,
                                      padding: const EdgeInsets.all(IAMSizes.md),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            _statusIsError
                                                ? Icons.error_outline_rounded
                                                : Icons
                                                    .check_circle_outline_rounded,
                                            size: 20,
                                            color: _statusIsError
                                                ? Colors.red[300]
                                                : Colors.green[300],
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _statusText!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: onSurface,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Text(
                                    'Step 1 — confirm funds. Step 2 — charge wallet.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: muted,
                                          height: 1.3,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: _loadingBalance ||
                                              _isValidating ||
                                              _isPaying
                                          ? null
                                          : () => _validateOrder(),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: muted,
                                        side: BorderSide(
                                          color: onSurface.withOpacity(
                                            dark ? 0.18 : 0.14,
                                          ),
                                        ),
                                        minimumSize: const Size.fromHeight(46),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isValidating
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: IAMColors.primary
                                                    .withOpacity(0.85),
                                              ),
                                            )
                                          : Text(
                                              'Validate payment',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: onSurface.withOpacity(0.75),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: canPay ? _payOrder : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: IAMColors.primary,
                                        foregroundColor: IAMColors.white,
                                        elevation: dark ? 0 : 2,
                                        shadowColor: IAMColors.primary.withOpacity(
                                          0.45,
                                        ),
                                        minimumSize: const Size.fromHeight(54),
                                        disabledBackgroundColor: IAMColors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: _isPaying
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: IAMColors.white,
                                              ),
                                            )
                                          : Text(
                                              'Pay $amountText',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.dark,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final chipBg = dark
        ? IAMColors.white.withOpacity(0.06)
        : IAMColors.white.withOpacity(0.9);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(dark ? 0.2 : 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: IAMSizes.sm,
          vertical: IAMSizes.sm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutWebViewSheet extends StatefulWidget {
  final String checkoutUrl;
  final String orderRef;
  final num totalAmount;

  const _CheckoutWebViewSheet({
    required this.checkoutUrl,
    required this.orderRef,
    required this.totalAmount,
  });

  @override
  State<_CheckoutWebViewSheet> createState() => _CheckoutWebViewSheetState();
}

class _CheckoutWebViewSheetState extends State<_CheckoutWebViewSheet> {
  WebViewController? _controller;
  int _progress = 0;
  late final bool _canEmbedWebView;
  double _dragOffsetY = 0;
  bool _isExiting = false;

  void _redirectToHomeWithBottomNav() {
    if (_isExiting) return;
    _isExiting = true;

    if (mounted) {
      Navigator.of(context).pop();
    }
    Get.offAll(() => const NavigationMenu());
  }

  @override
  void initState() {
    super.initState();
    _canEmbedWebView =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (_canEmbedWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (p) {
              if (!mounted) return;
              setState(() => _progress = p.clamp(0, 100));
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.checkoutUrl));
    } else {
      _progress = 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF0F1115) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;

    return FractionallySizedBox(
      heightFactor: 0.92,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.55 : 0.25),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Transform.translate(
          offset: Offset(0, _dragOffsetY),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (_isExiting) return;
                  // Only react when the user drags downward.
                  if (details.delta.dy <= 0) return;

                  setState(() {
                    _dragOffsetY = math.min(
                      _dragOffsetY + details.delta.dy,
                      220,
                    );
                  });
                },
                onVerticalDragEnd: (_) {
                  if (_isExiting) return;

                  const closeThreshold = 120.0;
                  if (_dragOffsetY >= closeThreshold) {
                    _redirectToHomeWithBottomNav();
                  } else {
                    setState(() => _dragOffsetY = 0);
                  }
                },
                child: SizedBox(
                  height: 28,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: onSurface.withOpacity(dark ? 0.22 : 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.defaultSpace,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? [
                                  IAMColors.primary.withOpacity(0.95),
                                  IAMColors.primary.withOpacity(0.65),
                                ]
                              : [
                                  IAMColors.primary,
                                  IAMColors.primary.withOpacity(0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure checkout',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.orderRef.isNotEmpty
                                ? 'Order ${widget.orderRef} · ₱${widget.totalAmount.toStringAsFixed(2)}'
                                : 'Complete your payment to confirm the order.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: onSurface.withOpacity(0.72),
                                  height: 1.25,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () {
                        _redirectToHomeWithBottomNav();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (_progress < 100)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    value: _progress / 100.0,
                    minHeight: 2.5,
                    backgroundColor: onSurface.withOpacity(dark ? 0.12 : 0.08),
                    color: IAMColors.primary,
                  ),
                )
              else
                const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: IAMSizes.defaultSpace,
                ),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.checkoutUrl),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Checkout URL copied.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green[300],
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onSurface,
                        side: BorderSide(
                          color: onSurface.withOpacity(dark ? 0.22 : 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () =>
                          IAMDeviceUtils.launchUrl(widget.checkoutUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Browser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onSurface,
                        side: BorderSide(
                          color: onSurface.withOpacity(dark ? 0.22 : 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _canEmbedWebView
                          ? () => _controller?.reload()
                          : null,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    0,
                    IAMSizes.defaultSpace,
                    16,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: onSurface.withOpacity(dark ? 0.05 : 0.03),
                        border: Border.all(
                          color: onSurface.withOpacity(dark ? 0.14 : 0.10),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _canEmbedWebView
                          ? WebViewWidget(controller: _controller!)
                          : Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'In-app checkout isn’t available on Windows.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: onSurface,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap “Browser” to open the secure checkout page.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: onSurface.withOpacity(0.72),
                                          height: 1.25,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  SelectableText(
                                    widget.checkoutUrl,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: onSurface,
                                          height: 1.25,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
