import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IAMAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.surfaceTintColor,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final Color? backgroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;
  final Color? surfaceTintColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: elevation,
        scrolledUnderElevation: scrolledUnderElevation,
        surfaceTintColor: surfaceTintColor,
        leading: showBackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Iconsax.arrow_left,
                  color: IAMHelperFunctions.isDarkMode(context)
                      ? Colors.white
                      : Theme.of(context).iconTheme.color,
                ),
              )
            : leadingIcon != null
            ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
            : null,
        centerTitle: centerTitle,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  //TO DO: implement preferredSize
  Size get preferredSize => Size.fromHeight(IAMDeviceUtils.getAppBarHeight());
}
