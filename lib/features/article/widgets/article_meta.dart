import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_provider.dart';

class ArticleMeta extends ConsumerWidget {
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String date;
  final String readTime;
  final int views;

  const ArticleMeta({
    super.key,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.date,
    required this.readTime,
    this.views = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final metaColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFF947867);

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (authorId.isNotEmpty) {
              context.push('/user/$authorId');
            }
          },
          child: CircleAvatar(
            radius: 10,
            backgroundImage: authorAvatarUrl.isNotEmpty
                ? NetworkImage(authorAvatarUrl)
                : null,
            backgroundColor:
                isDark ? const Color(0xFF3A3A55) : const Color(0xFFF0E4D6),
            child: authorAvatarUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 10,
                    color: isDark
                        ? const Color(0xFFA084CA)
                        : const Color(0xFFC97B5A),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            if (authorId.isNotEmpty) {
              context.push('/user/$authorId');
            }
          },
          child: Text(
            authorName,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: metaColor,
            ),
          ),
        ),
        const SizedBox(width: 5),
        _buildDot(metaColor),
        const SizedBox(width: 5),
        Text(
          date,
          style: GoogleFonts.inter(fontSize: 9, color: metaColor),
        ),
        const SizedBox(width: 5),
        _buildDot(metaColor),
        const SizedBox(width: 5),
        Icon(Icons.schedule, size: 10, color: metaColor),
        const SizedBox(width: 2),
        Text(
          readTime,
          style: GoogleFonts.inter(fontSize: 9, color: metaColor),
        ),
        const SizedBox(width: 5),
        _buildDot(metaColor),
        const SizedBox(width: 5),
        Icon(Icons.visibility_outlined, size: 10, color: metaColor),
        const SizedBox(width: 2),
        Text(
          '$views',
          style: GoogleFonts.inter(fontSize: 9, color: metaColor),
        ),
      ],
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