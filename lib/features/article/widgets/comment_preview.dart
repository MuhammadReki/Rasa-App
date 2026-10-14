import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class CommentPreview extends ConsumerWidget {
  final String name;
  final String avatarUrl;
  final String timeAgo;
  final String comment;

  const CommentPreview({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.timeAgo,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final nameColor =
        isDark ? AppColors.darkText : const Color(0xFF60483A);
    final timeColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFFA78A78);
    final commentColor =
        isDark ? const Color(0xFFC5B9AD) : const Color(0xFF765E4F);
    final replyColor =
        isDark ? AppColors.lavender : const Color(0xFFB4694D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          backgroundColor: isDark
              ? AppColors.midnightSurface
              : const Color(0xFFF0E4D6),
          child: avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: 15,
                  color:
                      isDark ? AppColors.lavender : AppColors.terracotta,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                timeAgo,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: timeColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                comment,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  height: 1.4,
                  color: commentColor,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Balas',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: replyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}