import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/theme/custom_themes/text_theme.dart';
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/outlined_button_theme.dart';
import 'custom_themes/text_field_theme.dart';

class IAMTheme {
  IAMTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: const Color(0xFFDBA724),
    textTheme: IAMTextTheme.lightTextTheme,
    chipTheme: IAMChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: IAMBarTheme.lightAppBarTheme,
    checkboxTheme: IAMCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: IAMBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: IAMElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: IAMOutlinedButtonTheme.lightOutLinedButtonTheme,
    inputDecorationTheme: IAMTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFDBA724),
    textTheme: IAMTextTheme.darkTextTheme,
    chipTheme: IAMChipTheme.darkChipTheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: IAMBarTheme.darkAppBarTheme,
    checkboxTheme: IAMCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: IAMBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: IAMElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: IAMOutlinedButtonTheme.darkOutLinedButtonTheme,
    inputDecorationTheme: IAMTextFormFieldTheme.darkInputDecorationTheme,
  );
}
