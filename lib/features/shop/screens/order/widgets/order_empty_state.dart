import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/features/screens/home/home.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMOrderEmptyState extends StatelessWidget {
  const IAMOrderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaText = 'Browse Products',
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaText;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final creamCircle = dark
        ? IAMColors.primary.withValues(alpha: 0.12)
        : const Color(0xFFFFF9E5);

    void browseProducts() {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().navigateToStore(0);
      } else {
        Get.to(const HomeScreen());
      }
      if (Navigator.of(context).canPop()) {
        Get.back();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: IAMSizes.sm),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: creamCircle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 100,
                    color: IAMColors.primary,
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: dark ? IAMColors.white : IAMColors.black,
                      ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark
                            ? IAMColors.white.withValues(alpha: 0.75)
                            : IAMColors.black.withValues(alpha: 0.70),
                      ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: browseProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: IAMSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(ctaText),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

