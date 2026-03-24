import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/authentication/controllers/onboarding_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/widgets/onboading_dot_navigation.dart';
import 'package:iam_ecomm/features/authentication/screens/widgets/onboarding_next_button.dart';
import 'package:iam_ecomm/features/authentication/screens/widgets/onboarding_page.dart';
import 'package:iam_ecomm/features/authentication/screens/widgets/onboarding_skip.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:lottie/lottie.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          //Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnboardingPage(
                image: IAMImages.onBoardingImage1,
                title: IAMTexts.onBoardingTitle1,
                subTitle: IAMTexts.onBoardingSubTitle1,
              ),
              OnboardingPage(
                image: IAMImages.onBoardingImage2,
                title: IAMTexts.onBoardingTitle2,
                subTitle: IAMTexts.onBoardingSubTitle2,
              ),
              OnboardingPage(
                image: IAMImages.onBoardingImage3,
                title: IAMTexts.onBoardingTitle3,
                subTitle: IAMTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          // Skip Button
          const OnBoardSkip(),

          // Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          // Circular Button
          OnBoardingNextButton(),
        ],
      ),
    );
  }
}
