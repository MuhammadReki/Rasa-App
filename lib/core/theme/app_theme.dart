import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: const ColorScheme.light(
          primary: AppColors.terracotta,
          secondary: AppColors.dustyRose,
          surface: AppColors.paper,
          onPrimary: Colors.white,
          onSurface: AppColors.espresso,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.espresso),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.midnight,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.lavender,
          secondary: AppColors.warmPeach,
          surface: AppColors.midnightSurface,
          onPrimary: AppColors.midnight,
          onSurface: AppColors.darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.midnight,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.darkText),
        ),
      );
}