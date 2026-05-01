import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/styles/spacing_styles.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.onPressed,
    this.subTitleWidget,
  });

  final String image, title, subTitle;
  final VoidCallback onPressed;
  final Widget? subTitleWidget;

  ///final VoidCallback? onPressed;   and remove the required for the error msg.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: IAMSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              //Image
              Image(
                image: AssetImage(image),
                width: IAMHelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),

              // TITLE AND SUBTITLE
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              subTitleWidget ??
                  Text(
                    subTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              //BUTTONS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text(IAMTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
