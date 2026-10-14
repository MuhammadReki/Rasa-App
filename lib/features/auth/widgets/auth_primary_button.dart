import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class AuthPrimaryButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final gradientColors = isDark
        ? const [
            AppColors.lavender,
            Color(0xFF8A6BB0),
          ]
        : const [
            Color(0xFFC97B5A),
            Color(0xFFB9674C),
          ];

    final shadowColor = isDark
        ? AppColors.lavender.withValues(alpha: 0.25)
        : const Color(0xFFB9674C).withValues(alpha: 0.22);

    final textColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFFFFAF4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 16,
                  color: textColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}