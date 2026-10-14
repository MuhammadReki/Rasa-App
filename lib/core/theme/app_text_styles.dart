import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.2,
    height: 1.1,
  );

  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
  );

  static TextStyle titleLarge = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 14,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 12,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 11,
    height: 1.5,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle eyebrow = GoogleFonts.dmMono(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.4,
  );

  static TextStyle quote = GoogleFonts.lora(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    height: 1.4,
  );
}