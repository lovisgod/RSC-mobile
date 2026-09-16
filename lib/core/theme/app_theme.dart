import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColorsLight.rscBrand,
      onPrimary: Colors.white,
      secondary: AppColorsLight.rscMain,
      onSecondary: Colors.white,
      surface: AppColorsLight.rscPanel,
      onSurface: AppColorsLight.rscInk,
      error: AppColorsLight.rscDanger,
      onError: Colors.white,
      outline: AppColorsLight.rscLine,
    ),
    scaffoldBackgroundColor: AppColorsLight.rscSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.rscPanel,
      foregroundColor: AppColorsLight.rscInk,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h3,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.rscBrand,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.rscFieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorsLight.rscBrand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorsLight.rscDanger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.body.copyWith(color: AppColorsLight.rscMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorsLight.rscBottomNavBg,
      indicatorColor: AppColorsLight.rscSidebarActiveBg,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColorsLight.rscBrand);
        }
        return const IconThemeData(color: AppColorsLight.rscBottomNavMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.caption.copyWith(
            color: AppColorsLight.rscBrand,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.caption.copyWith(color: AppColorsLight.rscBottomNavMuted);
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsLight.rscLine,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.rscBrand,
      onPrimary: Colors.white,
      secondary: AppColors.rscMain,
      onSecondary: Colors.white,
      surface: AppColors.rscPanel,
      onSurface: AppColors.rscInk,
      error: AppColors.rscDanger,
      onError: Colors.white,
      outline: AppColors.rscLine,
    ),
    scaffoldBackgroundColor: AppColors.rscSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.rscPanel,
      foregroundColor: AppColors.rscInk,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h3,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rscBrand,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.rscFieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.rscBrand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.rscDanger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.rscMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.rscBottomNavBg,
      indicatorColor: AppColors.rscSidebarActiveBg,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.rscBrand);
        }
        return const IconThemeData(color: AppColors.rscBottomNavMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.caption.copyWith(
            color: AppColors.rscBrand,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.caption.copyWith(color: AppColors.rscBottomNavMuted);
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.rscLine,
      thickness: 1,
      space: 1,
    ),
  );
}
