import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';

class IAMUserProfile extends StatelessWidget {
  const IAMUserProfile({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthController.instance.user.value;
      return ListTile(
        leading: IAMCircularImage(
          image: IAMImages.darkAppLogo,
          width: 50,
          height: 50,
          padding: 8,
        ),
        title: Text(
          user?.fullName ?? 'IAM User',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.apply(color: IAMColors.white),
        ),
        subtitle: Text(
          user != null ? '${user.packageName} (${user.idno})' : '@iamusername',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.apply(color: IAMColors.white),
        ),
        trailing: IconButton(
          onPressed: onPressed,
          icon: Icon(Iconsax.edit, color: IAMColors.white),
        ),
      );
    });
  }
}
