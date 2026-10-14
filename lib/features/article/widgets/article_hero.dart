import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class ArticleHero extends ConsumerWidget {
  final String coverUrl;
  final String readTime;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  const ArticleHero({
    super.key,
    required this.coverUrl,
    required this.readTime,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final buttonBg = isDark
        ? AppColors.midnightSurface.withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.88);
    final buttonIcon = isDark ? AppColors.darkText : const Color(0xFF513B30);

    return SizedBox(
      height: 213,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: coverUrl,
            width: double.infinity,
            height: 213,
            fit: BoxFit.cover,
            memCacheHeight: 600,
            placeholder: (context, url) => Container(
              height: 213,
              color: isDark
                  ? const Color(0xFF3A3A55)
                  : const Color(0xFFF0E4D6),
            ),
            errorWidget: (context, url, error) => Container(
              height: 213,
              color: isDark
                  ? const Color(0xFF3A3A55)
                  : const Color(0xFFF0E4D6),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: Icons.arrow_back,
                  onTap: onBack,
                  bg: buttonBg,
                  iconColor: buttonIcon,
                ),
                Row(
                  children: [
                    _buildCircularButton(
                      icon: Icons.share_outlined,
                      onTap: onShare,
                      bg: buttonBg,
                      iconColor: buttonIcon,
                    ),
                    const SizedBox(width: 7),
                    _buildCircularButton(
                      icon: Icons.bookmark_border,
                      onTap: onBookmark,
                      bg: buttonBg,
                      iconColor: buttonIcon,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 16,
            child: Text(
              readTime,
              style: GoogleFonts.dmMono(
                fontSize: 7,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    );
  }
}