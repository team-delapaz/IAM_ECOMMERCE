import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/screens/home/widgets/iam_wallet_balance_sheet.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
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
            () {
              final isLoggedIn = AuthController.instance.isLoggedIn.value;
              final user = AuthController.instance.user.value;
              return Text(
                isLoggedIn && user != null
                    ? 'Welcome, ${user.firstName}!'
                    : IAMTexts.homeAppbarSubTitleLoggedOut,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall!.apply(color: IAMColors.white),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'IAM Wallet balance',
          onPressed: () => showIamWalletBalanceQuickSheet(context),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Image.asset(
            IAMImages.walletIconW,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
            semanticLabel: 'IAM Wallet',
            errorBuilder: (_, __, ___) => Icon(
              Icons.account_balance_wallet_outlined,
              color: IAMColors.white.withOpacity(0.95),
              size: 26,
            ),
          ),
        ),
        IAMCartCounterIcon(onPressed: () {}, iconColor: IAMColors.white),
      ],
    );
  }
}
