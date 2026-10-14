import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class HomeSectionTitle extends ConsumerWidget {
  final String? eyebrow;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? trailing;

  const HomeSectionTitle({
    super.key,
    this.eyebrow,
    required this.title,
    this.actionText,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final eyebrowColor = isDark
        ? AppColors.lavender
        : const Color(0xFFB4694D);
    final titleColor = AppColors.textPrimary(isDark);
    final actionColor = isDark
        ? AppColors.lavender
        : const Color(0xFFB4694D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!,
                style: GoogleFonts.dmMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                  color: eyebrowColor,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.9,
                color: titleColor,
              ),
            ),
          ],
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: actionColor,
              ),
            ),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}