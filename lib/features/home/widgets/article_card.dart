import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/article.dart';

class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  Color _tagBg(String tag, bool isDark) {
    if (isDark) {
      switch (tag) {
        case '#patahhati':
          return const Color(0xFF3E2A2A);
        case '#selflove':
          return const Color(0xFF2E3A2E);
        case '#relationship':
          return const Color(0xFF3E2E2E);
        case '#random':
          return const Color(0xFF2A3540);
        default:
          return const Color(0xFF3E2A2A);
      }
    }
    switch (tag) {
      case '#patahhati':
        return const Color(0xFFF3DDD7);
      case '#selflove':
        return const Color(0xFFE0E9DF);
      case '#relationship':
        return const Color(0xFFF2DDDD);
      case '#random':
        return const Color(0xFFE0E9F1);
      default:
        return const Color(0xFFF3DDD7);
    }
  }

  Color _tagText(String tag, bool isDark) {
    if (isDark) {
      switch (tag) {
        case '#patahhati':
          return const Color(0xFFE8A8A8);
        case '#selflove':
          return const Color(0xFFA8C8A8);
        case '#relationship':
          return const Color(0xFFE8B0B0);
        case '#random':
          return const Color(0xFFA8C0D8);
        default:
          return const Color(0xFFE8A8A8);
      }
    }
    switch (tag) {
      case '#patahhati':
        return const Color(0xFFAA5C5C);
      case '#selflove':
        return const Color(0xFF587458);
      case '#relationship':
        return const Color(0xFF9F6666);
      case '#random':
        return const Color(0xFF557594);
      default:
        return const Color(0xFFAA5C5C);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final cardBg = AppColors.surface(isDark);
    final titleColor = AppColors.textPrimary(isDark);
    final previewColor = AppColors.textSecondary(isDark);
    final metaColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFF947867);

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
                    .withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                      height: 129,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheHeight: 400,
                      placeholder: (context, url) => Container(
                        height: 129,
                        color: isDark
                            ? const Color(0xFF3A3A55)
                            : const Color(0xFFF0E4D6),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 129,
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
                              Colors.black.withValues(alpha: 0.23),
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
                          color: _tagBg(article.tag, isDark),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.tag,
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                            color: _tagText(article.tag, isDark),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Row(
                        children: [
                          _buildIconButton(Icons.favorite_border),
                          const SizedBox(width: 7),
                          _buildIconButton(Icons.bookmark_border),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.17,
                        letterSpacing: -0.55,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        height: 1.45,
                        color: previewColor,
                      ),
                    ),
                    const SizedBox(height: 9),
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
                        Icon(Icons.visibility_outlined,
                            size: 9, color: metaColor),
                        const SizedBox(width: 2),
                        Text(
                          '${article.views}',
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: const Color(0xFF513B30)),
    );
  }
}