import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class ArticleBody extends ConsumerWidget {
  const ArticleBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bodyColor = isDark
        ? const Color(0xFFC5B9AD)
        : const Color(0xFF654E40);
    final italicColor = isDark
        ? AppColors.lavender
        : const Color(0xFFB4694D);
    final quoteBorder = isDark
        ? AppColors.lavender
        : AppColors.terracotta;
    final quoteText = isDark
        ? const Color(0xFFE4CFBD)
        : const Color(0xFF8A5744);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParagraph(
          context,
          'Ada masa ketika semua orang berkata, ',
          italicPart: '"kamu kuat, kok."',
          afterItalic:
              ' Dan aku mengangguk, seolah kalimat itu sebuah selimut hangat yang bisa kupakai sepanjang hari.',
          bodyColor: bodyColor,
          italicColor: italicColor,
        ),
        _buildParagraph(
          context,
          'Padahal, kuat bukan selalu tentang bertahan. Kadang ia adalah keberanian untuk berdiam sebentar, lalu mengakui bahwa kita lelah.',
          bodyColor: bodyColor,
          italicColor: italicColor,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: quoteBorder, width: 2),
            ),
          ),
          child: Text(
            '"Kita tidak perlu menjadi versi paling kuat dari diri kita untuk tetap layak dicintai."',
            style: GoogleFonts.lora(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
              letterSpacing: -0.3,
              color: quoteText,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildParagraph(
          context,
          'Aku belajar memberi ruang pada hari-hari yang tidak rapi. Membuat teh, membuka jendela, dan membiarkan hati bernapas tanpa harus menjelaskan apa-apa.',
          bodyColor: bodyColor,
          italicColor: italicColor,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://images.pexels.com/photos/8924253/pexels-photo-8924253.jpeg?auto=compress&cs=tinysrgb&w=800',
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 120,
              color: isDark
                  ? const Color(0xFF3A3A55)
                  : const Color(0xFFF0E4D6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(
    BuildContext context,
    String beforeItalic, {
    String? italicPart,
    String? afterItalic,
    required Color bodyColor,
    required Color italicColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 11,
            height: 1.66,
            color: bodyColor,
          ),
          children: [
            TextSpan(text: beforeItalic),
            if (italicPart != null)
              TextSpan(
                text: italicPart,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  height: 1.66,
                  fontStyle: FontStyle.italic,
                  color: italicColor,
                ),
              ),
            if (afterItalic != null) TextSpan(text: afterItalic),
          ],
        ),
      ),
    );
  }
}