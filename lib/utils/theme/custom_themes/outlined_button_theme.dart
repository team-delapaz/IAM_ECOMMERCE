import 'package:flutter/material.dart';

class IAMOutlinedButtonTheme {
  IAMOutlinedButtonTheme._();

  static const Color _goldPrimary = Color(0xFFDBA724);
  static const Color _goldLight = Color(0xFFE8C45A);
  static const Color _goldSoft = Color(0xFFF1DFA0);

  /// ---------------- LIGHT THEME ----------------
  static final lightOutLinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: _goldPrimary,
      side: const BorderSide(
        color: _goldPrimary, // Strong gold border
        width: 1.5,
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  /// ---------------- DARK THEME ----------------
  static final darkOutLinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: _goldLight, // Softer gold text
      side: const BorderSide(
        color: _goldSoft, // Softer border for dark background
        width: 1.2,
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
