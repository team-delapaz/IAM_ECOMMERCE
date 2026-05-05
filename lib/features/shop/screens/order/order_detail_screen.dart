import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/payments/checkout_webview_sheet.dart';
import 'package:iam_ecomm/common/widgets/payments/iam_wallet_pay_sheet.dart';
import 'package:iam_ecomm/features/shop/screens/order/widgets/track_order_screen.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final String refNo;
  const OrderDetailScreen({super.key, required this.refNo});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        foregroundColor: dark ? IAMColors.white : IAMColors.black,
        iconTheme: IconThemeData(
          color: dark ? IAMColors.white : IAMColors.black,
        ),
      ),
      body: FutureBuilder<ApiResponse<OrderDetailItem?>>(
        future: ApiMiddleware.orders.getOrderDetail(refNo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !(snapshot.data?.success ?? false)) {
            return const Center(child: Text('Failed to load order details'));
          }
          final order = snapshot.data!.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final shipping = order.shippingInfo;
          final pickup = order.pickupLocation;
          final fulfillmentId = order.fulfillmentTypeId;
          final fulfillmentName =
              order.fulfillmentTypeName.trim().toLowerCase();
          final isHomeDelivery =
              fulfillmentId == 1 && fulfillmentName == 'home delivery';
          final isStorePickup =
              fulfillmentId == 2 && fulfillmentName == 'store pickup';
          final effectivePickup = isStorePickup
              ? pickup
              : (!isHomeDelivery ? pickup : null);
          final effectiveShipping = isHomeDelivery
              ? shipping
              : (!isStorePickup ? shipping : null);
          final dark = IAMHelperFunctions.isDarkMode(context);
          final items = order.items;
          final paymentCard = _PaymentCardModel.from(order);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              IAMSizes.defaultSpace,
              IAMSizes.defaultSpace,
              IAMSizes.defaultSpace,
              IAMSizes.defaultSpace +
                  MediaQuery.of(context).padding.bottom +
                  24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(IAMSizes.md),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          IAMRoundedContainer(
                            padding: EdgeInsets.all(IAMSizes.md),
                            backgroundColor: dark
                                ? IAMColors.dark
                                : IAMColors.light,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrackingOrderScreen(order: order),
                                        ),
                                      );
                                    },

                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Track Your Order',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Order #${order.orderRefno}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: dark
                                                          ? IAMColors.darkGrey
                                                          : Colors.grey[600],
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? IAMColors.darkerGrey
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(
                                      IAMSizes.sm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_shipping,
                                        color: IAMColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.orderStatusName.trim().isNotEmpty
                                                ? order.orderStatusName.trim()
                                                : 'Order status unavailable',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: IAMColors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat(
                                              'dd-MMM-yyyy, hh:mma',
                                            ).format(
                                              DateTime.parse(order.orderDate),
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            color: IAMColors.primary,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Order #${order.orderRefno}',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .apply(
                                    color: Colors.white,
                                    fontWeightDelta: 2,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: dark ? IAMColors.dark : Colors.grey[100],
                          borderRadius: BorderRadius.circular(IAMSizes.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectivePickup != null
                                  ? 'Pickup Information'
                                  : 'Shipping Information',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (effectivePickup != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.store_mall_directory,
                                    color: IAMColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: effectivePickup
                                                    .pickupLocationName,
                                                style: TextStyle(
                                                  color: dark
                                                      ? IAMColors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              if (effectivePickup
                                                  .contactNo
                                                  .isNotEmpty)
                                                TextSpan(
                                                  text:
                                                      ' • ${effectivePickup.contactNo}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 1,
                                          thickness: 1.5,
                                          color:
                                              (dark
                                                      ? IAMColors.white
                                                      : IAMColors.black)
                                                  .withOpacity(0.10),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          effectivePickup.completeAddress,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: dark
                                                ? IAMColors.grey
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (effectivePickup
                                            .emailAddress
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            effectivePickup.emailAddress,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: dark
                                                  ? IAMColors.grey
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                        if (effectivePickup.operatingHours
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Hours: ${effectivePickup.operatingHours}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: dark
                                                  ? IAMColors.grey
                                                  : Colors.black87,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (effectiveShipping != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_pin,
                                    color: IAMColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${effectiveShipping.fullName} • ',
                                                style: TextStyle(
                                                  color: dark
                                                      ? IAMColors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    effectiveShipping.mobileNo,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 1,
                                          thickness: 1.5,
                                          color:
                                              (dark
                                                      ? IAMColors.white
                                                      : IAMColors.black)
                                                  .withOpacity(0.10),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          effectiveShipping.completeAddress,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: dark
                                                ? IAMColors.grey
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (effectiveShipping
                                            .notes
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Notes: ${effectiveShipping.notes}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: dark
                                                  ? IAMColors.grey
                                                  : Colors.black87,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                'No fulfillment address information available.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Text('Date: ${order.orderDate}'),
                // Text('Status: ${order.orderStatusName}'),
                _PaymentStatusCard(
                  model: paymentCard,
                  dark: dark,
                  onPayNow: paymentCard.canPayNow
                      ? () async {
                          final ok = await _handlePayNow(
                            context,
                            order,
                            paymentCard,
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(refNo: refNo),
                              ),
                            );
                          }
                        }
                      : null,
                ),
                const Divider(height: 32),

                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),

                ...items.map((item) {
                  if (item == null) return const SizedBox.shrink();

                  return Card(
                    color: IAMColors.primary.withOpacity(0.08),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      leading: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.inventory_2_outlined),

                      title: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        'Quantity: ${item.qty}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      trailing: Text(
                        NumberFormat.currency(
                          locale: 'en_PH',
                          symbol: '₱',
                          decimalDigits: 2,
                        ).format(item.lineTotal),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),

                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_PH',
                        symbol: '₱',
                        decimalDigits: 2,
                      ).format(order.subtotalAmount),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping:'),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_PH',
                        symbol: '₱',
                        decimalDigits: 2,
                      ).format(order.shippingAmount),
                    ),
                  ],
                ),

                if (order.voucherDiscountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voucher Discount:'),
                      Text(
                        '-${NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2).format(order.voucherDiscountAmount)}',
                      ),
                    ],
                  ),

                if (order.discountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Text(
                        '-${NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2).format(order.discountAmount)}',
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_PH',
                        symbol: '₱',
                        decimalDigits: 2,
                      ).format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // Show "Continue Payment" button if there's a checkout URL available
                /*if (order.checkoutUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text('Continue Payment'),
                  ),
                ],*/
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<bool> _handlePayNow(
  BuildContext context,
  OrderDetailItem order,
  _PaymentCardModel card,
) async {
  final orderRef = order.orderRefno;
  final amount = order.totalAmount;

  final provider = (order.paymentProvider).trim().toUpperCase();
  final isLockedToPaymaya = provider == 'PAYMAYA';

  final choice = isLockedToPaymaya
      ? _PayProviderChoice.paymaya
      : await showModalBottomSheet<_PayProviderChoice>(
          context: context,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _PayChoiceSheet(orderRef: orderRef, amount: amount),
        );

  if (choice == null) return false;

  if (choice == _PayProviderChoice.wallet) {
    final paid = await showIamWalletPaySheet(
      context: context,
      orderRef: orderRef,
      totalAmount: amount,
    );
    if (!paid) {
      _redirectToStoreWithUnpaidToast();
    }
    return paid;
  }

  final memberRes = await ApiMiddleware.member.getMember();
  if (!context.mounted) return false;
  final idno = memberRes.data?.idno ?? '';
  if (!memberRes.success || idno.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          memberRes.message.isNotEmpty
              ? memberRes.message
              : 'Unable to load your profile for payment.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
    return false;
  }

  final paymentRes = await ApiMiddleware.payment.createPayment(
    orderNo: orderRef,
    idno: idno,
    amount: amount,
    currency: 'PHP',
    paymentProvider: 'PAYMAYA',
    paymentMethod: 'PAYMAYA',
    description: 'Order payment',
    clientReferenceNo: orderRef,
  );

  if (!context.mounted) return false;
  if (!paymentRes.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          paymentRes.message.isNotEmpty
              ? paymentRes.message
              : 'Unable to start PayMaya checkout.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
    return false;
  }

  final checkoutUrl = paymentRes.data?.checkoutUrl ?? '';
  if (checkoutUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'No checkout URL returned.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[300],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
    return false;
  }

  final paid = await showCheckoutWebViewSheet(
    context: context,
    checkoutUrl: checkoutUrl,
    orderRef: orderRef,
    totalAmount: amount,
  );
  if (!paid && context.mounted) {
    _redirectToStoreWithUnpaidToast();
  }
  return paid;
}

void _redirectToStoreWithUnpaidToast() {
  final navController = Get.isRegistered<NavigationController>()
      ? Get.find<NavigationController>()
      : Get.put(NavigationController());
  navController.selectedIndex.value = 1;
  Get.offAll(() => const NavigationMenu());
  void showOnReady([int attempts = 0]) {
    final currentContext = Get.context;
    if (currentContext == null) {
      if (attempts < 10) {
        Future.delayed(
          const Duration(milliseconds: 120),
          () => showOnReady(attempts + 1),
        );
      }
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(currentContext);
    if (messenger == null) {
      if (attempts < 10) {
        Future.delayed(
          const Duration(milliseconds: 120),
          () => showOnReady(attempts + 1),
        );
      }
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Order is currently unpaid, head to "My Orders" to continue payment.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade300,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => showOnReady());
}

enum _PayProviderChoice { wallet, paymaya }

class _PayChoiceSheet extends StatelessWidget {
  const _PayChoiceSheet({required this.orderRef, required this.amount});

  final String orderRef;
  final num amount;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.62);

    return FractionallySizedBox(
      heightFactor: 0.58,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Container(
          color: surface,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(dark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IAMSizes.defaultSpace,
                  14,
                  IAMSizes.sm,
                  6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose payment',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order $orderRef · ₱${amount.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    10,
                    IAMSizes.defaultSpace,
                    IAMSizes.defaultSpace,
                  ),
                  children: [
                    _PayChoiceTile(
                      title: 'IAM Wallet',
                      subtitle: 'Pay instantly from wallet balance',
                      color: IAMColors.primary,
                      icon: Icons.account_balance_wallet_rounded,
                      onTap: () =>
                          Navigator.of(context).pop(_PayProviderChoice.wallet),
                    ),
                    const SizedBox(height: 10),
                    _PayChoiceTile(
                      title: 'PayMaya',
                      subtitle: 'Pay via PayMaya checkout',
                      color: Colors.green.shade600,
                      icon: Icons.payment_rounded,
                      onTap: () =>
                          Navigator.of(context).pop(_PayProviderChoice.paymaya),
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

class _PayChoiceTile extends StatelessWidget {
  const _PayChoiceTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.62);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: IAMRoundedContainer(
          showBorder: true,
          backgroundColor: dark ? IAMColors.black : IAMColors.lightGrey,
          borderColor: onSurface.withOpacity(dark ? 0.16 : 0.1),
          padding: const EdgeInsets.all(IAMSizes.md),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(dark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(dark ? 0.35 : 0.25),
                  ),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCardModel {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final bool canPayNow;

  const _PaymentCardModel({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.canPayNow,
  });

  static _PaymentCardModel from(OrderDetailItem order) {
    final providerRaw = order.paymentProvider.trim();
    final provider = providerRaw.toUpperCase();
    final paid =
        order.paymentStatusName.toUpperCase() == 'PAID' ||
        order.paymentStatusId != 0;

    if (provider.isEmpty && !paid) {
      return const _PaymentCardModel(
        title: 'Unpaid',
        subtitle: 'Select Payment Provider',
        accent: Color(0xFFEF5350),
        icon: Icons.error_outline_rounded,
        canPayNow: true,
      );
    }

    if (provider == 'PAYMAYA') {
      final statusText = paid
          ? 'PAID'
          : (order.paymentStatusName.isNotEmpty
                ? order.paymentStatusName
                : order.paymentStatusMessage);
      return _PaymentCardModel(
        title: 'Maya · $statusText',
        subtitle: order.paymentStatusMessage.isNotEmpty
            ? 'Pending Payment'
            : (paid ? 'Payment successful.' : 'Complete your Maya checkout.'),
        accent: Colors.green.shade600,
        icon: Icons.payment_rounded,
        canPayNow: !paid,
      );
    }

    if (provider.contains('WALLET')) {
      final statusText = paid
          ? 'PAID'
          : (order.paymentStatusName.isNotEmpty
                ? order.paymentStatusName
                : 'PENDING');
      return _PaymentCardModel(
        title: 'IAM WALLET · $statusText',
        subtitle: order.paymentStatusMessage.isNotEmpty
            ? order.paymentStatusMessage
            : (paid
                  ? 'Wallet payment successful.'
                  : 'Complete your wallet payment.'),
        accent: IAMColors.primary,
        icon: Icons.account_balance_wallet_rounded,
        canPayNow: !paid,
      );
    }

    final statusText = paid
        ? 'PAID'
        : (order.paymentStatusName.isNotEmpty
              ? order.paymentStatusName
              : 'PENDING');
    return _PaymentCardModel(
      title: '${providerRaw.isEmpty ? 'PAYMENT' : providerRaw} · $statusText',
      subtitle: order.paymentStatusMessage.isNotEmpty
          ? order.paymentStatusMessage
          : 'Payment status: $statusText',
      accent: IAMColors.primary,
      icon: Icons.payments_outlined,
      canPayNow: !paid,
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard({
    required this.model,
    required this.dark,
    this.onPayNow,
  });

  final _PaymentCardModel model;
  final bool dark;
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    final surface = dark ? IAMColors.black : IAMColors.lightGrey;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.62);
    final accent = model.accent;

    return Card(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.12),
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(IAMSizes.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.12),
              ),
              child: Icon(Icons.wallet, color: accent, size: 24),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    model.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            if (onPayNow != null) ...[
              const SizedBox(width: 10),
              TextButton(
                onPressed: onPayNow,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  backgroundColor: accent.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Pay now',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
