import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iam_ecomm/common/widgets/login_signup/form_divider.dart';
import 'package:iam_ecomm/common/widgets/login_signup/social_buttons.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_form.dart';
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_header.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() => const NavigationMenu());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              //Logo
              IAMLoginHeader(dark: dark),

              //Form
              IAMLoginForm(),

              //Divider
              //IAMFormDivider(dividerText: IAMTexts.orSignInWith.capitalize!),
              //const SizedBox(height: IAMSizes.spaceBtwSections),

              //Footer
              //IAMSocialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
