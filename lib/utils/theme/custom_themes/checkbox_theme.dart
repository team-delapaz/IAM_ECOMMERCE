import 'package:flutter/material.dart';

class IAMCheckboxTheme {
  IAMCheckboxTheme._();

  static const Color _goldPrimary = Color(0xFFDBA724);
  static const Color _goldLight = Color(0xFFE8C45A);
  static const Color _goldSoft = Color(0xFFF1DFA0);

  /// ---------------- LIGHT THEME ----------------
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.black;
    }),

    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _goldPrimary; // Strong gold when selected
      }
      return Colors.transparent;
    }),

    side: const BorderSide(
      color: _goldLight, // Light gold border
      width: 1.2,
    ),
  );

  /// ---------------- DARK THEME ----------------
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.black;
      }
      return Colors.white;
    }),

    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _goldLight; // Softer gold for dark mode
      }
      return Colors.transparent;
    }),

    side: const BorderSide(
      color: _goldSoft, // Softer border for dark mode
      width: 1.2,
    ),
  );
}
