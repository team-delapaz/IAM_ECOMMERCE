import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/personalization/screens/address/add_new_address.dart';
import 'package:iam_ecomm/features/personalization/screens/address/widgets/single_address.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class UserAddressScreen extends StatefulWidget {
  const UserAddressScreen({super.key});

  @override
  State<UserAddressScreen> createState() => _UserAddressScreenState();
}

class _UserAddressScreenState extends State<UserAddressScreen> {
  late Future<ApiResponse<List<AddressItem?>>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = ApiMiddleware.address.getAddresses();
  }

  Future<void> _reload() async {
    setState(() {
      _addressesFuture = ApiMiddleware.address.getAddresses();
    });
  }

  Future<void> _setDefault(AddressItem address) async {
    final res = await ApiMiddleware.address.setDefaultAddress(address.autoId);

    if (!res.success) {
      if (!mounted) return;
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Changed Default Address to "${address.recipientName}"',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: IAMColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    await _reload();
  }

  Future<void> _delete(AddressItem address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Delete "${address.recipientName}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ApiMiddleware.address.deleteAddress(address.autoId);

    if (!res.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'Unable to delete address.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: IAMColors.primary.withOpacity(0.8),
        onPressed: () async {
          await Get.to(() => const AddNewAddressScreen());
          await _reload();
        },
        backgroundColor: IAMColors.primary,
        foregroundColor: IAMColors.textWhite,
        child: const Icon(Iconsax.add),
      ),
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(
          'Delivery Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: FutureBuilder<ApiResponse<List<AddressItem?>>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.success) {
            final msg =
                snapshot.data?.message ?? 'Unable to load saved addresses.';
            return Center(child: Text(msg));
          }

          final addresses =
              snapshot.data!.data?.whereType<AddressItem>().toList() ?? [];

          if (addresses.isEmpty) {
            return const Center(child: Text('No saved addresses yet.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              child: Column(
                children: [
                  for (final address in addresses)
                    IAMSingleAddress(
                      address: address,
                      selectedAddress: address.isDefault,
                      optionsButton: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: IAMSizes.iconSm,
                        ),
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<String>>[];

                          if (!address.isDefault) {
                            items.add(
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as default'),
                              ),
                            );
                          }

                          items.add(
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          );

                          items.add(
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          );

                          return items;
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'default':
                              await _setDefault(address);
                              break;
                            case 'edit':
                              await Get.to(
                                () => AddNewAddressScreen(
                                  initialAddress: address,
                                ),
                              );
                              await _reload();
                              break;
                            case 'delete':
                              await _delete(address);
                              break;
                          }
                        },
                      ),
                      onTap: () async {
                        await _setDefault(address);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
