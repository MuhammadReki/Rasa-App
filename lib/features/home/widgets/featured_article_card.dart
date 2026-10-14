import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/article.dart';

class FeaturedArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback? onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final cardBg = AppColors.surface(isDark);
    final titleColor = AppColors.textPrimary(isDark);
    final previewColor = AppColors.textSecondary(isDark);
    final metaColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFF947867);
    final tagBg =
        isDark ? const Color(0xFF3E2E2E) : const Color(0xFFF2DDDD);
    final tagText =
        isDark ? const Color(0xFFE8B0B0) : const Color(0xFF9F6666);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF3E2C23))
                    .withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.coverUrl,
                      height: 149,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheHeight: 500,
                      placeholder: (context, url) => Container(
                        height: 149,
                        color: isDark
                            ? const Color(0xFF3A3A55)
                            : const Color(0xFFF0E4D6),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 149,
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
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.tag,
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                            color: tagText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: -0.6,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      article.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        height: 1.45,
                        color: previewColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildAvatar(article.authorAvatarUrl, isDark),
                        const SizedBox(width: 6),
                        Text(
                          article.authorName,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: metaColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        _buildDot(metaColor),
                        const SizedBox(width: 5),
                        Text(
                          article.date,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: metaColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        _buildDot(metaColor),
                        const SizedBox(width: 5),
                        Text(
                          article.readTime,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: metaColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, bool isDark) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 10,
        backgroundImage: CachedNetworkImageProvider(url),
        onBackgroundImageError: (_, __) {},
        backgroundColor:
            isDark ? AppColors.midnightSurface : const Color(0xFFF0E4D6),
      );
    }
    return CircleAvatar(
      radius: 10,
      backgroundColor:
          isDark ? AppColors.midnightSurface : const Color(0xFFF0E4D6),
      child: Icon(
        Icons.person,
        size: 10,
        color: isDark ? AppColors.lavender : AppColors.terracotta,
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 2,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}