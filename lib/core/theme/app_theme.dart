import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/generated/fonts.gen.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    fontFamily: FontFamily.baloo2,
    scaffoldBackgroundColor: ColorName.colorSky,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ColorName.colorGreen,
      onPrimary: ColorName.colorWhite,
      secondary: ColorName.colorYellow,
      onSecondary: ColorName.colorNavy,
      surface: ColorName.colorCream,
      onSurface: ColorName.colorNavy,
      error: ColorName.colorRed,
      onError: ColorName.colorWhite,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyMedium: AppTextStyles.cardBody,
      titleMedium: AppTextStyles.rowLabel,
      labelLarge: AppTextStyles.textButton,
    ).apply(bodyColor: ColorName.colorNavy, displayColor: ColorName.colorNavy),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ColorName.colorNavy,
      contentTextStyle: AppTextStyles.textButton.copyWith(
        color: ColorName.colorWhite,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
