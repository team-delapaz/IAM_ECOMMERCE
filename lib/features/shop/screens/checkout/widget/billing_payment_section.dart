import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ApiResponse<List<PaymentMethodItem?>> methodsRes =
          await ApiMiddleware.payment.getPaymentMethods();
      final ApiResponse<List<PaymentProviderItem?>> providersRes =
          await ApiMiddleware.payment.getPaymentProviders();

      final methods = methodsRes.data ?? [];
      final providers = providersRes.data ?? [];

      if (methods.isEmpty || providers.isEmpty) {
        _error = 'No payment methods available.';
        _current = null;
      } else {
        final methodList = methods.whereType<PaymentMethodItem>().toList();
        final providerList = providers.whereType<PaymentProviderItem>().toList();

        PaymentMethodItem method = methodList.firstWhere(
          (m) => m.isActive,
          orElse: () => methodList.first,
        );

        PaymentProviderItem provider = providerList.firstWhere(
          (p) => p.providerCode == method.methodCode && p.isActive,
          orElse: () => providerList.first,
        );

        _current = _PaymentViewModel(method: method, provider: provider);
      }
    } catch (e) {
      _error = 'Unable to load payment methods.';
      _current = null;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    ///will comment out muna to for integration of paymnet methods and providers
    // final controller = Get.put(CheckoutController());
    // return existing controller-based UI...

    if (_loading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_error != null || _current == null) {
      return Text(_error ?? 'Unable to load payment methods.');
    }
    final model = _current!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IAMSectionHeading(
          title: 'Payment Method',
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
                child: Text(
                  model.provider.providerCode,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems / 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.method.methodName,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.provider.providerName,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showSelector(BuildContext context) async {
    final ApiResponse<List<PaymentMethodItem?>> methodsRes =
        await ApiMiddleware.payment.getPaymentMethods();
    final ApiResponse<List<PaymentProviderItem?>> providersRes =
        await ApiMiddleware.payment.getPaymentProviders();

    final methods = methodsRes.data ?? [];
    final providers = providersRes.data ?? [];
    final methodList = methods.whereType<PaymentMethodItem>().toList();
    final providerList = providers.whereType<PaymentProviderItem>().toList();
    if (methodList.isEmpty || providerList.isEmpty) return;

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
            return ListTile(
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

    if (selected == null) return;

    PaymentProviderItem provider = providerList.firstWhere(
      (p) => p.providerCode == selected.methodCode && p.isActive,
      orElse: () => providerList.first,
    );

    setState(() {
      _current = _PaymentViewModel(method: selected, provider: provider);
    });
  }
}

class _PaymentViewModel {
  final PaymentMethodItem method;
  final PaymentProviderItem provider;

  _PaymentViewModel({
    required this.method,
    required this.provider,
  });
}