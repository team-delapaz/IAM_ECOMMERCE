import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  //Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Jump tp the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  //Update Current index and jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      _completeOnboarding();
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  //Update Current Index and jump to the last page
  void skipPage() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as seen so it won't show again on next app launch.
    final storage = IAMLocalStorage();
    await storage.saveData('has_seen_onboarding', true);

    // Skip onboarding and proceed to main app (Home with bottom navigation).
    Get.offAll(() => const NavigationMenu());
  }
}
