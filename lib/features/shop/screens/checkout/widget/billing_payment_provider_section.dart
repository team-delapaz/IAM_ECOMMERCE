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

String _iconForProviderCode(String providerCode) {
  switch (providerCode.toUpperCase()) {
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

class IAMBillingPaymentProviderSection extends StatefulWidget {
  const IAMBillingPaymentProviderSection({super.key});

  @override
  State<IAMBillingPaymentProviderSection> createState() =>
      _IAMBillingPaymentProviderSectionState();
}

class _IAMBillingPaymentProviderSectionState
    extends State<IAMBillingPaymentProviderSection> {
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
    final ApiResponse<List<PaymentProviderItem?>> providersRes =
        await ApiMiddleware.payment.getPaymentProviders();
    final providers = providersRes.data ?? [];
    final providerList =
        providers
            .whereType<PaymentProviderItem>()
            .where((p) => p.isActive)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (mounted) {
      setState(() {
        _loading = false;
        if (!providersRes.success) {
          _error = providersRes.message;
          _current = null;
          _checkout.clearPaymentProvider();
        } else if (providerList.isEmpty) {
          _error = 'No payment providers available.';
          _current = null;
          _checkout.clearPaymentProvider();
        } else {
          _error = null;
          final first = providerList.first;
          _current = _PaymentViewModel(provider: first);
          _checkout.setPaymentProvider(
            code: first.providerCode,
            name: first.providerName,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    if (_loading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_error != null || _current == null) {
      return Text(_error ?? 'Unable to load payment providers.');
    }
    final model = _current!;
    final iconPath = _iconForProviderCode(model.provider.providerCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IAMSectionHeading(
          title: 'Payment Provider',
          buttonTitle: 'Change',
          onPressed: () => _showSelector(context),
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
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    model.provider.providerCode,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems / 2),
            Expanded(
              child: Text(
                model.provider.providerName,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showSelector(BuildContext context) async {
    final ApiResponse<List<PaymentProviderItem?>> providersRes =
        await ApiMiddleware.payment.getPaymentProviders();
    final providers = providersRes.data ?? [];
    final providerList =
        providers
            .whereType<PaymentProviderItem>()
            .where((p) => p.isActive)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (providerList.isEmpty) return;

    final selected = await showModalBottomSheet<PaymentProviderItem>(
      context: context,
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(IAMSizes.md),
          itemCount: providerList.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: IAMSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            final p = providerList[index];
            final isSelected =
                _current?.provider.providerCode == p.providerCode;
            final iconPath = _iconForProviderCode(p.providerCode);
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
              title: Text(p.providerName),
              subtitle: Text(p.providerCode),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: IAMColors.warning)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () => Navigator.of(context).pop(p),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _current = _PaymentViewModel(provider: selected);
      });

      _checkout.setPaymentProvider(
        code: selected.providerCode,
        name: selected.providerName,
      );
    }
  }
}

class _PaymentViewModel {
  final PaymentProviderItem provider;

  _PaymentViewModel({required this.provider});
}
