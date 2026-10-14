import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class AuthTextField extends ConsumerStatefulWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  ConsumerState<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends ConsumerState<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final labelColor = isDark
        ? const Color(0xFFC8BFB2)
        : const Color(0xFF624B3E);
    final inputBg = isDark
        ? AppColors.midnightSurface
        : Colors.white.withValues(alpha: 0.68);
    final borderColor = isDark
        ? const Color(0xFF454562)
        : const Color(0xFFEADBCA);
    final iconColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFFA88873);
    final textColor = isDark ? AppColors.darkText : const Color(0xFF49362B);
    final hintColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFFB69B8A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 1, bottom: 7),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 17, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: widget.keyboardType,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: hintColor,
                    ),
                  ),
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 17,
                    color: iconColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}