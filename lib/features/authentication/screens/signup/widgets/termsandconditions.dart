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
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    final linkStyle = Theme.of(context).textTheme.bodyMedium!.apply(
      color: dark ? IAMColors.white : IAMColors.primary,
      decoration: TextDecoration.underline,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: [
        Checkbox(
          value: true,
          onChanged: (value) {},
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        SizedBox(width: IAMSizes.spaceBtwItems),
        Text(' ${IAMTexts.iAgreeTo}', style: bodySmall),
        GestureDetector(
          onTap: () => Get.to(() => const PrivacyPolicyScreen()),
          child: Text(IAMTexts.privacyPolicy, style: linkStyle),
        ),
        Text(' ${IAMTexts.and}', style: bodySmall),
        GestureDetector(
          onTap: () => Get.to(() => const TermsConditionsScreen()),
          child: Text(IAMTexts.termsOfUse, style: linkStyle),
        ),
      ],
    );
  }
}
