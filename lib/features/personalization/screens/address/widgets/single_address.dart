import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

class IAMSingleAddress extends StatelessWidget {
  const IAMSingleAddress({
    super.key,
    required this.address,
    required this.selectedAddress,
    this.optionsButton,
    this.onTap,
  });

  final AddressItem address;
  final bool selectedAddress;
  final Widget? optionsButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
      child: IAMRoundedContainer(
        padding: const EdgeInsets.all(IAMSizes.md),
        width: double.infinity,
        showBorder: true,
        backgroundColor: selectedAddress
            ? IAMColors.primary.withOpacity(0.5)
            : Colors.transparent,
        borderColor: selectedAddress
            ? Colors.transparent
            : dark
                ? IAMColors.darkerGrey
                : IAMColors.grey,
        margin: const EdgeInsets.only(bottom: IAMSizes.spaceBtwItems),
        child: Stack(
          children: [
            Positioned(
              top: IAMSizes.xs / 2,
              right: IAMSizes.xs / 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedAddress)
                    Icon(
                      Iconsax.tick_circle5,
                      color: dark
                          ? IAMColors.light
                          : IAMColors.dark.withOpacity(0.4),
                    ),
                  if (selectedAddress && optionsButton != null)
                    const SizedBox(width: IAMSizes.xs),
                  if (optionsButton != null) optionsButton!,
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.recipientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: IAMSizes.sm / 2),
                Text(
                  address.mobileNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: IAMSizes.sm / 2),
                Text(
                  address.completeAddress,
                  softWrap: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
