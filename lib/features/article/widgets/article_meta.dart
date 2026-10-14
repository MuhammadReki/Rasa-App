import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_provider.dart';

class ArticleMeta extends ConsumerWidget {
  final String authorName;
  final String authorAvatarUrl;
  final String date;
  final String readTime;

  const ArticleMeta({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.date,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final metaColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFF947867);

    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundImage: NetworkImage(authorAvatarUrl),
        ),
        const SizedBox(width: 6),
        Text(
          authorName,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: metaColor,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: metaColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          date,
          style: GoogleFonts.inter(fontSize: 9, color: metaColor),
        ),
        const SizedBox(width: 5),
        Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: metaColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          readTime,
          style: GoogleFonts.inter(fontSize: 9, color: metaColor),
        ),
      ],
    );
  }
}