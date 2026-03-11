import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global theme controller to switch between light and dark mode.
class ThemeController extends GetxController {
  static ThemeController get instance => Get.find<ThemeController>();

  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    _isDarkMode.value = Get.isDarkMode;
    super.onInit();
  }

  void toggleTheme(bool value) {
    _isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
