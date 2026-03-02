import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iam_ecomm/features/authentication/screens/onboarding.dart';
import 'package:iam_ecomm/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: IAMTheme.lightTheme,
      darkTheme: IAMTheme.darkTheme,
      home: const OnBoardingScreen(),
    );
  }
}
