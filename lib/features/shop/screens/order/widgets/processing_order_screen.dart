import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/payments/checkout_webview_sheet.dart';
import 'package:iam_ecomm/common/widgets/payments/iam_wallet_pay_sheet.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_detail_screen.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ProcessingTab extends StatefulWidget {
  const ProcessingTab({super.key});

  @override
  State<ProcessingTab> createState() => _ProcessingTabState();
}

class _ProcessingTabState extends State<ProcessingTab> {
  Future<ApiResponse<List<OrderItem?>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiMiddleware.orders.getOrders();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = ApiMiddleware.orders.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return FutureBuilder(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          return const Center(child: Text('No orders found'));
        }

        final List<OrderItem?> orders = (snapshot.data!.data ?? [])
            .where(
              (order) =>
                  order != null &&
                  order.orderStatusName.toLowerCase() == 'pending',
            )
            .toList();

        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: orders.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final order = orders[index];
            if (order == null) return const SizedBox.shrink();

            return _orderCard(context, order, formatter, dark);
          },
        );
      },
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(
    BuildContext context,
    OrderItem order,
    NumberFormat formatter,
    bool dark,
  ) {
    final isUnpaid =
        order.paymentStatusId == 0 ||
        order.paymentStatusName.toLowerCase() == 'not paid';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(refNo: order.orderRefno),
          ),
        );
      },
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.md),
        backgroundColor: dark ? IAMColors.dark : IAMColors.light,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER NUMBER + COPY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.orderRefno}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.apply(fontWeightDelta: 2),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderRefno));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Order number copied!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green[300],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.copy),
                  iconSize: IAMSizes.iconSm,
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems / 2),

            /// STATUS
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: IAMColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.routing,
                    size: 20,
                    color: IAMColors.grey,
                  ),
                ),

                const SizedBox(width: IAMSizes.spaceBtwItems / 2),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderStatusName,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .apply(
                                    color: IAMColors.primary,
                                    fontWeightDelta: 1,
                                  ),
                            ),
                          ),

                          Tooltip(
                            message: 'Click on the card to View Details',
                            child: const Icon(
                              Iconsax.arrow_right_3,
                              size: 18,
                              color: IAMColors.darkGrey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "We're processing your order now!",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),

            /// DATE
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: IAMColors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.calendar,
                    size: 20,
                    color: IAMColors.darkGrey,
                  ),
                ),
                const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                Text(
                  DateFormat(
                    'dd-MMM-yyyy, hh:mma',
                  ).format(DateTime.parse(order.orderDate)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: IAMSizes.spaceBtwItems),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),

            /// TOTAL + BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${formatter.format(order.totalAmount)}',
                  style: Theme.of(context).textTheme.titleMedium!.apply(
                    fontWeightDelta: 1,
                    color: IAMColors.dark,
                  ),
                ),

                if (isUnpaid)
                  TextButton(
                    onPressed: () async {
                      final didPay = await _showPayNowFlow(
                        context,
                        order,
                        formatter,
                      );
                      if (!context.mounted) return;
                      if (didPay) {
                        _refresh();
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: IAMColors.primary,
                    ),
                    child: const Text('Pay now'),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            /// VIEW DETAILS (moved below)
            // /// VIEW DETAILS (full width with border)
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton.icon(
            //     onPressed: () {
            //       Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (_) =>
            //               OrderDetailScreen(refNo: order.orderRefno),
            //         ),
            //       );
            //     },
            //     icon: const Icon(Iconsax.arrow_right_3, size: 20),
            //     label: const Text('View Details'),
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: IAMColors.primary,
            //       side: const BorderSide(color: IAMColors.primary, width: 1),
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showPayNowFlow(
    BuildContext context,
    OrderItem order,
    NumberFormat formatter,
  ) async {
    final provider = order.paymentProvider.trim().toUpperCase();
    final orderRef = order.orderRefno;
    final amount = order.totalAmount;

    final allowed = <_PayProviderOption>[
      if (provider == 'PAYMAYA')
        const _PayProviderOption.paymaya()
      else ...[
        const _PayProviderOption.wallet(),
        const _PayProviderOption.paymaya(),
      ],
    ];

    final selected = allowed.length == 1
        ? allowed.first
        : await showModalBottomSheet<_PayProviderOption>(
            context: context,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => _PayNowProviderSheet(
              orderRef: orderRef,
              amountText: formatter.format(amount),
              options: allowed,
            ),
          );

    if (selected == null) return false;

    if (selected.type == _PayProviderType.wallet) {
      final paid = await showIamWalletPaySheet(
        context: context,
        orderRef: orderRef,
        totalAmount: amount,
      );
      if (!context.mounted) return false;
      if (paid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Wallet payment successful.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[300],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      } else {
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
}

enum _PayProviderType { wallet, paymaya }

class _PayProviderOption {
  final _PayProviderType type;
  final String title;
  final String code;
  final String iconAsset;

  const _PayProviderOption._({
    required this.type,
    required this.title,
    required this.code,
    required this.iconAsset,
  });

  const _PayProviderOption.wallet()
    : this._(
        type: _PayProviderType.wallet,
        title: 'IAM Wallet',
        code: 'IAMWALLET',
        iconAsset: IAMImages.walletIcon,
      );

  const _PayProviderOption.paymaya()
    : this._(
        type: _PayProviderType.paymaya,
        title: 'PayMaya',
        code: 'PAYMAYA',
        iconAsset: IAMImages.maya,
      );
}

class _PayNowProviderSheet extends StatelessWidget {
  const _PayNowProviderSheet({
    required this.orderRef,
    required this.amountText,
    required this.options,
  });

  final String orderRef;
  final String amountText;
  final List<_PayProviderOption> options;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final surface = dark ? const Color(0xFF101217) : IAMColors.white;
    final onSurface = dark ? IAMColors.white : IAMColors.black;
    final muted = onSurface.withOpacity(dark ? 0.72 : 0.62);

    return FractionallySizedBox(
      heightFactor: options.length > 1 ? 0.62 : 0.5,
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
                            'Pay now',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order $orderRef · $amountText',
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
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    IAMSizes.defaultSpace,
                    10,
                    IAMSizes.defaultSpace,
                    IAMSizes.defaultSpace,
                  ),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final opt = options[idx];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).pop(opt),
                        child: IAMRoundedContainer(
                          showBorder: true,
                          backgroundColor: dark
                              ? IAMColors.black
                              : IAMColors.lightGrey,
                          borderColor: onSurface.withOpacity(dark ? 0.16 : 0.1),
                          padding: const EdgeInsets.all(IAMSizes.md),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: IAMColors.primary.withOpacity(
                                    dark ? 0.18 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: IAMColors.primary.withOpacity(
                                      dark ? 0.28 : 0.22,
                                    ),
                                  ),
                                ),
                                child: Image.asset(
                                  opt.iconAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.code,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: muted),
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
