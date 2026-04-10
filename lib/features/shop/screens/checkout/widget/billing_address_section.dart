import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/features/personalization/screens/address/add_new_address.dart';
import 'package:iam_ecomm/features/personalization/screens/address/widgets/single_address.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class IAMBillingAddressSection extends StatefulWidget {
  const IAMBillingAddressSection({
    super.key,
    this.onAddressSelected,
    this.onAddressAvailabilityChanged,
  });

  final ValueChanged<AddressItem?>? onAddressSelected;
  final ValueChanged<bool>? onAddressAvailabilityChanged;

  @override
  State<IAMBillingAddressSection> createState() =>
      _IAMBillingAddressSectionState();
}

class _IAMBillingAddressSectionState extends State<IAMBillingAddressSection> {
  bool _loading = true;
  String? _error;
  final List<AddressItem> _addresses = [];
  AddressItem? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ApiMiddleware.address.getAddresses();
    if (!mounted) return;

    if (!res.success) {
      setState(() {
        _loading = false;
        _error = res.message.isNotEmpty
            ? res.message
            : 'Unable to load addresses.';
      });
      return;
    }

    final list = res.data?.whereType<AddressItem>().toList() ?? [];
    AddressItem? selected;
    for (final a in list) {
      if (a.isDefault) {
        selected = a;
        break;
      }
    }
    selected ??= list.isNotEmpty ? list.first : null;

    setState(() {
      _loading = false;
      _addresses
        ..clear()
        ..addAll(list);
      _selectedAddress = selected;
    });

    widget.onAddressAvailabilityChanged?.call(list.isNotEmpty);
    widget.onAddressSelected?.call(_selectedAddress);
  }

  Future<void> _setAsDefaultAndSelect(AddressItem address) async {
    setState(() => _selectedAddress = address);
    widget.onAddressSelected?.call(address);

    final res = await ApiMiddleware.address.setDefaultAddress(address.autoId);
    if (!mounted) return;

    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Unable to set default address.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    await _loadAddresses();
  }

  void _openSelectSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (_loading) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(IAMSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Shipping Address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Iconsax.close_circle),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),

                if (_addresses.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _error ?? 'No saved addresses yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: IAMSizes.spaceBtwItems),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Get.to(() => const AddNewAddressScreen());
                            await _loadAddresses();
                          },
                          child: const Text('Add New Address'),
                        ),
                      ),
                    ],
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        final selected =
                            _selectedAddress?.autoId == address.autoId;
                        return IAMSingleAddress(
                          address: address,
                          selectedAddress: selected,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _setAsDefaultAndSelect(address);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = _selectedAddress != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IAMSectionHeading(
          title: 'Shipping Address',
          buttonTitle: _addresses.isEmpty ? 'Add' : 'Change',
          onPressed: _openSelectSheet,
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),

        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null && !hasAddress)
          Text(_error!, style: Theme.of(context).textTheme.bodyMedium)
        else if (!hasAddress)
          Text(
            'No address selected.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          Text(
            _selectedAddress!.recipientName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: IAMSizes.spaceBtwItems / 2),

          Row(
            children: [
              const Icon(Icons.phone, color: Colors.grey, size: 16),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Text(
                _selectedAddress!.mobileNo,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: IAMSizes.spaceBtwItems / 2),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_history, color: Colors.grey, size: 16),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Expanded(
                child: Text(
                  _selectedAddress!.completeAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
