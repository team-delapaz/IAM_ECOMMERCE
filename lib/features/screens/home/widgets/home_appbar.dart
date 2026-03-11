import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';

class IAMHomeAppBar extends StatelessWidget {
  const IAMHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return IAMAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IAMTexts.homeAppbarTitle,
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.apply(color: IAMColors.lightGrey),
          ),
          Obx(
            () => Text(
              AuthController.instance.isLoggedIn.value
                  ? IAMTexts.homeAppbarSubTitleLoggedIn
                  : IAMTexts.homeAppbarSubTitleLoggedOut,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.apply(color: IAMColors.white),
            ),
          ),
        ],
      ),
      actions: [
        IAMCartCounterIcon(onPressed: () {}, iconColor: IAMColors.white),
      ],
    );
  }
}
