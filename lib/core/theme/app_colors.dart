import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Mode
  static const Color cream = Color(0xFFFAF3E0);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color terracotta = Color(0xFFC97B5A);
  static const Color terracottaDark = Color(0xFFB9674C);
  static const Color dustyRose = Color(0xFFE8B4A0);
  static const Color espresso = Color(0xFF3E2C23);
  static const Color mocha = Color(0xFF8B6F5C);
  static const Color divider = Color(0xFFEFE4D4);

  // Dark Mode
  static const Color midnight = Color(0xFF1A1A2E);
  static const Color midnightSurface = Color(0xFF252540);
  static const Color lavender = Color(0xFFA084CA);
  static const Color warmPeach = Color(0xFFF0A88C);
  static const Color darkText = Color(0xFFF5F0E8);
  static const Color darkTextSecondary = Color(0xFFB8AFA0);
  static const Color darkDivider = Color(0xFF383850);

  // Tag Colors (Light)
  static const Color tagHeartbreakBg = Color(0xFFF3DDD7);
  static const Color tagHeartbreakText = Color(0xFFAA5C5C);
  static const Color tagSelfloveBg = Color(0xFFE0E9DF);
  static const Color tagSelfloveText = Color(0xFF587458);
  static const Color tagRelationshipBg = Color(0xFFF2DDDD);
  static const Color tagRelationshipText = Color(0xFF9F6666);
  static const Color tagRandomBg = Color(0xFFE0E9F1);
  static const Color tagRandomText = Color(0xFF557594);

  // Helper methods
  static Color background(bool isDark) => isDark ? midnight : cream;
  static Color surface(bool isDark) => isDark ? midnightSurface : paper;
  static Color textPrimary(bool isDark) => isDark ? darkText : espresso;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : mocha;
  static Color accent(bool isDark) => isDark ? lavender : terracotta;
  static Color dividerColor(bool isDark) => isDark ? darkDivider : divider;
}