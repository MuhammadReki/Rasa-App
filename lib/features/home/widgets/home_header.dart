import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final greetingColor = AppColors.textSecondary(isDark);
    final nameColor = AppColors.textPrimary(isDark);
    final iconBg = AppColors.surface(isDark);
    final iconColor = isDark ? AppColors.lavender : const Color(0xFF513B30);

    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.valueOrNull;

    final displayName = profile?.displayName.split(' ').first ?? 'Pengguna';
    final avatarUrl = profile?.avatarUrl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: greetingColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Hai, $displayName 👋',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.9,
                color: nameColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF3E2C23))
                        .withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 8),
            _buildAvatar(avatarUrl, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl, bool isDark) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isDark ? AppColors.midnightSurface : const Color(0xFFF0E4D6),
      child: Icon(
        Icons.person,
        size: 16,
        color: isDark ? AppColors.lavender : AppColors.terracotta,
      ),
    );
  }
}