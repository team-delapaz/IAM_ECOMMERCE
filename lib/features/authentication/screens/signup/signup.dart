import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:iam_ecomm/common/widgets/login_signup/form_divider.dart';
import 'package:iam_ecomm/common/widgets/login_signup/social_buttons.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/signup.form.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              Text(
                IAMTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              //Form
              const IAMSignupForm(),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              //Divider
              //IAMFormDivider(dividerText: IAMTexts.orSignUpWith.capitalize!),
              //const SizedBox(height: IAMSizes.spaceBtwSections),

              //Social Button
              //const IAMSocialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
