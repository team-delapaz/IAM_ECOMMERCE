import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/privacy_policy_screen.dart';
import 'package:iam_ecomm/features/authentication/screens/signup/widgets/terms_conditions_screen.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMTermsAndConditions extends StatelessWidget {
  const IAMTermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(value: true, onChanged: (value) {}),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: ' ${IAMTexts.iAgreeTo} ',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const PrivacyPolicyScreen());
                  },
                  child: Text(
                    IAMTexts.privacyPolicy,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: dark ? IAMColors.white : IAMColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              TextSpan(
                text: ' ${IAMTexts.and} ',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const TermsConditionsScreen());
                  },
                  child: Text(
                    IAMTexts.termsOfUse,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: dark ? IAMColors.white : IAMColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
