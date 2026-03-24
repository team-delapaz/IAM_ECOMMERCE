import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/onboarding.dart';
import 'package:iam_ecomm/utils/theme/theme.dart';
import 'package:iam_ecomm/utils/theme/theme_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
      // return GetMaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   themeMode: ThemeMode.system,
      //   theme: IAMTheme.lightTheme,
      //   darkTheme: IAMTheme.darkTheme,
      //   home: const OnBoardingScreen(),
      // );

      if (!Get.isRegistered<ThemeController>()) {
        Get.put(ThemeController(), permanent: true);
      }
      if (!Get.isRegistered<AuthController>()) {
        Get.put(AuthController(), permanent: true);
      }

      final themeController = ThemeController.instance;

      return Obx(
        () => GetMaterialApp(
          themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: IAMTheme.lightTheme,
          darkTheme: IAMTheme.darkTheme,
          home: const OnBoardingScreen(),
        ),
    );
  }
}