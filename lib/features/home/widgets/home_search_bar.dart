import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class HomeSearchBar extends ConsumerWidget {
  final VoidCallback? onTap;

  const HomeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = AppColors.surface(isDark);
    final textColor = AppColors.textSecondary(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF3E2C23))
                  .withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cari cerita atau tag...',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.tune, size: 17, color: textColor),
          ],
        ),
      ),
    );
  }
}