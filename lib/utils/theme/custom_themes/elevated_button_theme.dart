import 'package:flutter/material.dart';

class IAMElevatedButtonTheme {
  IAMElevatedButtonTheme._();

  /// -- Light Theme (Stronger Gold)
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFFDBA724), // main gold
      disabledForegroundColor: Colors.grey[300],
      disabledBackgroundColor: Colors.grey[300],
      side: const BorderSide(
        color: Color(0xFFE8C45A), // lighter gold for border
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /// -- Dark Theme (Softer Gold for Dark Background)
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFFE8C45A), // softer gold
      disabledForegroundColor: Colors.grey[700],
      disabledBackgroundColor: Colors.grey[800],
      side: const BorderSide(
        color: Color(0xFFE6BE8A), // even softer gold border
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
