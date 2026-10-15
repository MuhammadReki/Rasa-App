import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_provider.dart';

class AuthOrDivider extends ConsumerWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final dividerColor = isDark
        ? const Color(0xFF454562)
        : const Color(0xFFEADFCE);
    final textColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFFA78A78);

    return Row(
      children: [ 
        Expanded(
          child: Divider(color: dividerColor, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'atau',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: textColor,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: dividerColor, thickness: 1),
        ),
      ],
    );
  }
}