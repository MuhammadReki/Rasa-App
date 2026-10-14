import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class ArticleActionBar extends ConsumerWidget {
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  const ArticleActionBar({
    super.key,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.surface(isDark);
    final borderColor = AppColors.dividerColor(isDark);
    final iconColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFF8C6F5E);
    final likeActive = isDark
        ? const Color(0xFFE8A8A8)
        : const Color(0xFFC97B7B);
    final bookmarkActive = isDark
        ? AppColors.lavender
        : const Color(0xFFB4694D);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: '$likes',
            color: isLiked ? likeActive : iconColor,
            onTap: onLike,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: '$comments',
            color: iconColor,
            onTap: onComment,
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.share_outlined,
            color: iconColor,
            onTap: onShare,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? bookmarkActive : iconColor,
            onTap: onBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 9, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}