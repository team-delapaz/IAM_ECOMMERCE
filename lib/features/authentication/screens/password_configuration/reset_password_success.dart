import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/success_screen/success_screen.dart';
import 'package:iam_ecomm/features/authentication/screens/login/login.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SuccessScreen(
      image: IAMImages.successRegistration,
      title: 'Password Reset Successful',
      subTitle: message.isNotEmpty
          ? message
          : 'Your password has been updated successfully. You may now sign in.',
      onPressed: () => Get.offAll(() => const LoginScreen()),
    );
  }
}
