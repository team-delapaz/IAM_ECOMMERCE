import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/controllers/products/checkout_controller.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

String _iconForMethodCode(String methodCode) {
  switch (methodCode.toUpperCase()) {
    case 'IAMWALLET':
      return IAMImages.iamwallet;
    case 'PAYMAYA':
      return IAMImages.maya;
    case 'GCASH':
      return IAMImages.gcash;
    default:
      return IAMImages.iamwallet;
  }
}

class IAMBillingPaymentSection extends StatefulWidget {
  const IAMBillingPaymentSection({super.key});

  @override
  State<IAMBillingPaymentSection> createState() =>
      _IAMBillingPaymentSectionState();
}

class _IAMBillingPaymentSectionState extends State<IAMBillingPaymentSection> {
  _PaymentViewModel? _current;
  bool _loading = true;
  String? _error;

  late final CheckoutController _checkout;

  @override
  void initState() {
    super.initState();
    _checkout = Get.isRegistered<CheckoutController>()
        ? CheckoutController.instance
        : Get.put(CheckoutController());
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ApiResponse<List<PaymentMethodItem?>> methodsRes = await ApiMiddleware
        .payment
        .getPaymentMethods();
    final methods = methodsRes.data ?? [];
    final methodList =
        methods.whereType<PaymentMethodItem>().where((m) => m.isActive).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (mounted) {
      setState(() {
        _loading = false;
        if (!methodsRes.success) {
          _error = methodsRes.message;
          _current = null;
        } else if (methodList.isEmpty) {
          _error = 'No payment methods available.';
          _current = null;
        } else {
          // Methods loaded successfully, but do NOT auto-select.
          // Leave `_current` null and show a placeholder until the
          // user explicitly chooses a payment method.
          _error = null;
          _current = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Obx(() {
      final providerSelected = _checkout.selectedPaymentProviderCode.isNotEmpty;

      if (!providerSelected) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IAMSectionHeading(
              title: 'Payment Method',
              showActionButton: false,
            ),
            const SizedBox(height: IAMSizes.spaceBtwItems / 2),
            Opacity(
              opacity: 0.6,
              child: Row(
                children: [
                  IAMRoundedContainer(
                    width: 60,
                    height: 35,
                    backgroundColor: dark ? IAMColors.light : IAMColors.white,
                    padding: const EdgeInsets.all(IAMSizes.sm),
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(width: IAMSizes.spaceBtwItems / 2),
                  Expanded(
                    child: Text(
                      'Select a payment provider first',
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      if (_loading) {
        return const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      if (_error != null) {
        return Text(_error ?? 'Unable to load payment methods.');
      }
      final hasSelection = _current != null;
      final iconPath = hasSelection
          ? _iconForMethodCode(_current!.method.methodCode)
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IAMSectionHeading(
            title: 'Payment Method',
            buttonTitle: hasSelection ? 'Change' : 'Select',
            onPressed: providerSelected ? () => _showSelector(context) : null,
          ),
          const SizedBox(height: IAMSizes.spaceBtwItems / 2),
          Row(
            children: [
              IAMRoundedContainer(
                width: 60,
                height: 35,
                backgroundColor: dark ? IAMColors.light : IAMColors.white,
                padding: const EdgeInsets.all(IAMSizes.sm),
                child: Center(
                  child: hasSelection && iconPath != null
                      ? Image.asset(
                          iconPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            _current!.method.methodCode,
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
              Expanded(
                child: Text(
                  hasSelection
                      ? _current!.method.methodName
                      : 'Select Payment Method',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: hasSelection ? null : Theme.of(context).hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _showSelector(BuildContext context) async {
    final ApiResponse<List<PaymentMethodItem?>> methodsRes = await ApiMiddleware
        .payment
        .getPaymentMethods();
    final methods = methodsRes.data ?? [];
    final methodList =
        methods.whereType<PaymentMethodItem>().where((m) => m.isActive).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (methodList.isEmpty) return;

    final selected = await showModalBottomSheet<PaymentMethodItem>(
      context: context,
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: methodList.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            final m = methodList[index];
            final isSelected = _current?.method.methodCode == m.methodCode;
            final iconPath = _iconForMethodCode(m.methodCode);
            return ListTile(
              leading: SizedBox(
                width: 48,
                height: 28,
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              title: Text(m.methodName),
              subtitle: Text(m.methodCode),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: IAMColors.warning)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () => Navigator.of(context).pop(m),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _current = _PaymentViewModel(method: selected);
      });

      _checkout.setPaymentMethod(
        name: selected.methodName,
        image: _iconForMethodCode(selected.methodCode),
      );
      // Also set the provider code so checkout can proceed
      _checkout.selectedPaymentProviderCode.value = selected.methodCode;
    }
  }
}

class _PaymentViewModel {
  final PaymentMethodItem method;

  _PaymentViewModel({required this.method});
}
