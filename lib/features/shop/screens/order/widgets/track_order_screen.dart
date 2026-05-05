import 'package:flutter/material.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/shop/screens/order/order_status_ids.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// Fixed fulfillment pipeline (top = earliest), aligned to `orderStatusId` 1–5.
const List<_FulfillmentPhase> _kFulfillmentPhases = [
  _FulfillmentPhase(
    title: 'Pending',
    subtitle: 'Your order has been received.',
    icon: Iconsax.clock,
  ),
  _FulfillmentPhase(
    title: 'Verified',
    subtitle: 'Your order has been verified.',
    icon: Iconsax.verify5,
  ),
  _FulfillmentPhase(
    title: 'Ready to Ship',
    subtitle: 'We are preparing your order for shipment.',
    icon: Iconsax.box,
  ),
  _FulfillmentPhase(
    title: 'In Transit',
    subtitle: 'Your package is on the way.',
    icon: Iconsax.truck,
  ),
  _FulfillmentPhase(
    title: 'Delivered',
    subtitle: 'Order completed successfully.',
    icon: Iconsax.tick_circle,
  ),
];

class TrackingOrderScreen extends StatelessWidget {
  final OrderDetailItem order;

  TrackingOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.user.value;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? IAMColors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tracking Result'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? IAMColors.white : Colors.black,
        iconTheme: IconThemeData(
          color: dark ? IAMColors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(IAMSizes.md),
        child: Column(
          children: [
            _productCard(context),
            const SizedBox(height: IAMSizes.spaceBtwSections),
            _orderDetails(context, user),
            const SizedBox(height: IAMSizes.spaceBtwSections),
            Expanded(child: _timeline()),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    OrderProductItem? first;
    for (final e in order.items) {
      if (e != null) {
        first = e;
        break;
      }
    }
    final imageUrl = first?.imageUrl ?? '';

    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: dark ? IAMColors.darkerGrey : Colors.grey[200],
              borderRadius: BorderRadius.circular(IAMSizes.md),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty ? const Icon(Iconsax.box) : null,
          ),
          const SizedBox(width: IAMSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first?.productName.isNotEmpty == true
                      ? first!.productName
                      : 'Item Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${order.orderRefno}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.copy, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Widget _orderDetails(BuildContext context, UserInfo? user) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(IAMSizes.md),
      decoration: BoxDecoration(
        color: dark ? IAMColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(IAMSizes.lg),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: IAMColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Order Details',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
              /*Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: IAMColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        order.paymentStatusMessage,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: IAMColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems),
          _row(context, 'Customer:', user?.fullName ?? 'IAM User'),
          _row(
            context,
            order.pickupLocation != null ? 'Pickup Location:' : 'Destination:',
            order.pickupLocation != null
                ? toTitleCase(order.pickupLocation!.completeAddress)
                : order.shippingInfo?.completeAddress != null
                    ? toTitleCase(order.shippingInfo!.completeAddress)
                    : 'No Selected Address',
          ),
          _row(
            context,
            'Contact No.:',
            order.pickupLocation?.contactNo.isNotEmpty == true
                ? order.pickupLocation!.contactNo
                : order.shippingInfo?.mobileNo ?? 'N/A',
          ),
          _row(context, 'Payment Method:', order.paymentMethod.isNotEmpty ? order.paymentMethod : 'N/A'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String title, String value) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: IAMSizes.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.45,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: IAMColors.darkGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.55,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ).copyWith(color: dark ? IAMColors.white : IAMColors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _timeline() {
    return FutureBuilder<ApiResponse<List<OrderStatusHistoryItem?>>>(
      future: ApiMiddleware.orders.getOrderHistory(order.orderRefno),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final history = <OrderStatusHistoryItem>[];
        if (snapshot.hasData &&
            snapshot.data != null &&
            (snapshot.data!.success)) {
          history.addAll(
            (snapshot.data!.data ?? []).whereType<OrderStatusHistoryItem>(),
          );
        }
        history.sort((a, b) {
          final da = DateTime.tryParse(a.tranDate) ?? DateTime(0);
          final db = DateTime.tryParse(b.tranDate) ?? DateTime(0);
          return da.compareTo(db);
        });

        final models = _buildStepModels(order, history);

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (loading)
              Padding(
                padding: const EdgeInsets.only(bottom: IAMSizes.sm),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  borderRadius: BorderRadius.circular(2),
                  color: IAMColors.primary,
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ...models.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              return _trackingStepRow(
                context: context,
                title: m.title,
                subtitle: m.subtitle,
                time: m.time,
                icon: m.icon,
                phase: m.phase,
                isLast: i == models.length - 1,
                dangerTerminal: m.dangerTerminal,
                warningTerminal: m.warningTerminal,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _trackingStepRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required _StepVisualPhase phase,
    required bool isLast,
    bool dangerTerminal = false,
    bool warningTerminal = false,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isAlertCurrent =
        phase == _StepVisualPhase.current && (dangerTerminal || warningTerminal);
    final accent = dangerTerminal
        ? Colors.red
        : (warningTerminal ? Colors.deepOrange : null);
    final mutedCompleted = dark ? Colors.grey.shade500 : Colors.grey.shade600;
    final mutedCompletedLine =
        dark ? Colors.grey.shade700 : Colors.grey.shade300;
    final upcomingBase = dark ? Colors.grey.shade300 : Colors.grey.shade700;
    final upcomingSubtitle =
        dark ? Colors.grey.shade500 : Colors.grey.shade500;
    final currentBase = IAMColors.primary;

    final Color dotColor = switch (phase) {
      _StepVisualPhase.current =>
        isAlertCurrent ? accent!.shade600 : currentBase,
      _StepVisualPhase.completed => mutedCompleted,
      _StepVisualPhase.upcoming => dark ? Colors.grey.shade700 : Colors.grey.shade300,
    };

    final Color titleColor = switch (phase) {
      _StepVisualPhase.current =>
        isAlertCurrent ? accent!.shade700 : currentBase,
      _StepVisualPhase.completed => mutedCompleted,
      _StepVisualPhase.upcoming => upcomingBase,
    };

    final Color subtitleColor = switch (phase) {
      _StepVisualPhase.current => isAlertCurrent
          ? accent!.shade600
          : currentBase.withOpacity(0.9),
      _StepVisualPhase.completed =>
        dark ? Colors.grey.shade400 : Colors.grey.shade600,
      _StepVisualPhase.upcoming => upcomingSubtitle,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: phase == _StepVisualPhase.completed
                    ? mutedCompletedLine
                    : (dark ? Colors.grey.shade800 : Colors.grey.shade300),
              ),
          ],
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Icon(
          icon,
          size: 20,
          color: switch (phase) {
            _StepVisualPhase.current => isAlertCurrent
                ? accent!.shade700
                : currentBase,
            _StepVisualPhase.completed => mutedCompleted,
            _StepVisualPhase.upcoming =>
              dark ? Colors.grey.shade500 : Colors.grey.shade500,
          },
        ),
        const SizedBox(width: IAMSizes.spaceBtwItems),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: phase == _StepVisualPhase.current
                ? (isAlertCurrent ? accent!.shade700 : currentBase)
                : (dark ? Colors.grey.shade500 : Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _bottomButtons() {
    final canCancel = _canUserCancelOrder(order);
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(top: IAMSizes.md),
        child: Row(
          children: [
            Expanded(
              child: canCancel
                  ? OutlinedButton(
                      onPressed: () {},
                      child: const Text('Cancel Order'),
                    )
                  : Tooltip(
                      message:
                          'You can only cancel while the order is still Pending. '
                          'After it is Ready to Ship, cancellation is disabled.',
                      child: OutlinedButton(
                        onPressed: null,
                        child: const Text('Cancel Order'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Step model & logic (file-private) ---

enum _StepVisualPhase { completed, current, upcoming }

enum _NegativeTerminal {
  cancelled,
  failedDelivery,
  returned,
  lostDamaged,
}

class _FulfillmentPhase {
  final String title;
  final String subtitle;
  final IconData icon;

  const _FulfillmentPhase({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _StepModel {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final _StepVisualPhase phase;
  final bool dangerTerminal;
  final bool warningTerminal;

  const _StepModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.phase,
    this.dangerTerminal = false,
    this.warningTerminal = false,
  });
}

/// Only **Pending** (`orderStatusId` **1**) may cancel; not after Verified / Ready to Ship.
bool _canUserCancelOrder(OrderDetailItem o) {
  if (_negativeTerminal(o) != null) return false;
  if (o.orderStatusId == OrderStatusIds.pending) return true;
  return o.orderStatusName.toLowerCase().trim() == 'pending';
}

_NegativeTerminal? _negativeTerminal(OrderDetailItem o) {
  switch (o.orderStatusId) {
    case OrderStatusIds.cancelled:
      return _NegativeTerminal.cancelled;
    case OrderStatusIds.failedDelivery:
      return _NegativeTerminal.failedDelivery;
    case OrderStatusIds.returned:
      return _NegativeTerminal.returned;
    case OrderStatusIds.lostAndDamaged:
      return _NegativeTerminal.lostDamaged;
    default:
      break;
  }
  final n = o.orderStatusName.toLowerCase();
  if (n.contains('cancel')) return _NegativeTerminal.cancelled;
  return null;
}

/// Fulfillment step index `0..4` for ids **1–5**; `null` for terminal / unknown fulfillment ids.
int? _fulfillmentStepIndex(int id, String name) {
  switch (id) {
    case OrderStatusIds.pending:
      return 0;
    case OrderStatusIds.verified:
      return 1;
    case OrderStatusIds.readyToShip:
      return 2;
    case OrderStatusIds.inTransit:
      return 3;
    case OrderStatusIds.delivered:
      return 4;
    case OrderStatusIds.cancelled:
    case OrderStatusIds.failedDelivery:
    case OrderStatusIds.returned:
    case OrderStatusIds.lostAndDamaged:
      return null;
    default:
      return _fulfillmentStepIndexFromName(name);
  }
}

int? _fulfillmentStepIndexFromName(String name) {
  final n = name.toLowerCase().trim();
  if (n.contains('cancel') ||
      (n.contains('fail') && n.contains('deliver')) ||
      n.contains('returned') ||
      (n.contains('lost') && n.contains('damag'))) {
    return null;
  }
  if (n.contains('delivered') || n.contains('completed')) return 4;
  if (n.contains('transit') ||
      n.contains('on the way') ||
      (n.contains('shipped') && !n.contains('ready'))) {
    return 3;
  }
  if ((n.contains('ready') && n.contains('ship')) || n.contains('ready to pickup')) {
    return 2;
  }
  if (n.contains('verified')) return 1;
  if (n.contains('pending') || n.contains('placed')) return 0;
  return null;
}

int _currentFulfillmentStep(OrderDetailItem order, List<OrderStatusHistoryItem> history) {
  var cur = _fulfillmentStepIndex(order.orderStatusId, order.orderStatusName) ?? 0;
  for (final h in history) {
    final idx = _fulfillmentStepIndex(h.orderStatusId, h.orderStatusName);
    if (idx != null && idx > cur) cur = idx;
  }
  if (cur > _kFulfillmentPhases.length - 1) {
    cur = _kFulfillmentPhases.length - 1;
  }
  return cur;
}

int _maxFulfillmentFromHistory(List<OrderStatusHistoryItem> history) {
  var max = -1;
  for (final h in history) {
    final idx = _fulfillmentStepIndex(h.orderStatusId, h.orderStatusName);
    if (idx != null && idx > max) max = idx;
  }
  if (max < 0) max = 0;
  if (max > _kFulfillmentPhases.length - 1) {
    max = _kFulfillmentPhases.length - 1;
  }
  return max;
}

String? _lastTimeForFulfillmentIndex(
  int index,
  List<OrderStatusHistoryItem> history,
) {
  OrderStatusHistoryItem? last;
  for (final h in history) {
    if (_fulfillmentStepIndex(h.orderStatusId, h.orderStatusName) == index) {
      last = h;
    }
  }
  return last?.tranDate;
}

String? _lastHistoryTimeForStatusId(
  List<OrderStatusHistoryItem> history,
  int statusId,
) {
  OrderStatusHistoryItem? last;
  for (final h in history) {
    if (h.orderStatusId == statusId) last = h;
  }
  return last?.tranDate;
}

String _remarksForLastHistoryWithId(
  List<OrderStatusHistoryItem> history,
  int statusId,
) {
  for (var i = history.length - 1; i >= 0; i--) {
    final h = history[i];
    if (h.orderStatusId == statusId) return h.remarks.trim();
  }
  return '';
}

String _formatStepTime(String? isoOrApi) {
  if (isoOrApi == null || isoOrApi.isEmpty) return '—';
  final dt = DateTime.tryParse(isoOrApi);
  if (dt == null) return '—';
  return DateFormat('hh:mm a').format(dt);
}

String _upcomingHint(int stepIndex) {
  switch (stepIndex) {
    case 1:
      return 'Waiting for verification.';
    case 2:
      return 'Waiting to be prepared for shipment.';
    case 3:
      return 'Waiting for shipment to go out for delivery.';
    case 4:
      return 'Waiting for delivery confirmation.';
    default:
      return 'Awaiting updates.';
  }
}

List<_StepModel> _buildPrefixFulfillmentSteps(
  List<OrderStatusHistoryItem> history,
  int maxReached,
) {
  final out = <_StepModel>[];
  for (var i = 0; i <= maxReached; i++) {
    final meta = _kFulfillmentPhases[i];
    final t = _lastTimeForFulfillmentIndex(i, history);
    out.add(
      _StepModel(
        title: meta.title,
        subtitle: meta.subtitle,
        time: _formatStepTime(t),
        icon: meta.icon,
        phase: _StepVisualPhase.completed,
      ),
    );
  }
  return out;
}

List<_StepModel> _buildStepModels(
  OrderDetailItem order,
  List<OrderStatusHistoryItem> history,
) {
  final neg = _negativeTerminal(order);
  if (neg != null) {
    final maxReached = _maxFulfillmentFromHistory(history);
    final out = _buildPrefixFulfillmentSteps(history, maxReached);

    late final String title;
    late final String defaultSubtitle;
    late final IconData icon;
    late final int remarkStatusId;
    late final bool danger;
    late final bool warning;

    switch (neg) {
      case _NegativeTerminal.cancelled:
        title = 'Cancelled';
        defaultSubtitle = 'This order was cancelled.';
        icon = Iconsax.close_circle;
        remarkStatusId = OrderStatusIds.cancelled;
        danger = true;
        warning = false;
        break;
      case _NegativeTerminal.failedDelivery:
        title = 'Failed Delivery';
        defaultSubtitle = 'Delivery could not be completed.';
        icon = Iconsax.warning_2;
        remarkStatusId = OrderStatusIds.failedDelivery;
        danger = false;
        warning = true;
        break;
      case _NegativeTerminal.returned:
        title = 'Returned';
        defaultSubtitle = 'This order was returned.';
        icon = Iconsax.refresh_circle;
        remarkStatusId = OrderStatusIds.returned;
        danger = false;
        warning = true;
        break;
      case _NegativeTerminal.lostDamaged:
        title = 'Lost & Damaged';
        defaultSubtitle = 'This shipment was reported lost or damaged.';
        icon = Iconsax.box_remove;
        remarkStatusId = OrderStatusIds.lostAndDamaged;
        danger = false;
        warning = true;
        break;
    }

    final remark = _remarksForLastHistoryWithId(history, remarkStatusId);
    out.add(
      _StepModel(
        title: title,
        subtitle: remark.isNotEmpty ? remark : defaultSubtitle,
        time: _formatStepTime(_lastHistoryTimeForStatusId(history, remarkStatusId)),
        icon: icon,
        phase: _StepVisualPhase.current,
        dangerTerminal: danger,
        warningTerminal: warning,
      ),
    );
    return out;
  }

  final current = _currentFulfillmentStep(order, history);
  final out = <_StepModel>[];
  for (var i = 0; i < _kFulfillmentPhases.length; i++) {
    final meta = _kFulfillmentPhases[i];
    final t = _lastTimeForFulfillmentIndex(i, history);
    late _StepVisualPhase phase;
    if (i < current) {
      phase = _StepVisualPhase.completed;
    } else if (i == current) {
      phase = _StepVisualPhase.current;
    } else {
      phase = _StepVisualPhase.upcoming;
    }
    final subtitle = phase == _StepVisualPhase.upcoming
        ? _upcomingHint(i)
        : meta.subtitle;
    out.add(
      _StepModel(
        title: meta.title,
        subtitle: subtitle,
        time: _formatStepTime(
          t ??
              (i == 0 && phase == _StepVisualPhase.current
                  ? order.orderDate
                  : null),
        ),
        icon: meta.icon,
        phase: phase,
      ),
    );
  }
  return out;
}
