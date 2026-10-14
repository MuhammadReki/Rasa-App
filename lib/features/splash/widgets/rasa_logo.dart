import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class RasaLogo extends StatelessWidget {
  final double fontSize;
  final Color? textColor;
  final bool showTagline;

  const RasaLogo({
    super.key,
    this.fontSize = 53,
    this.textColor,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RasaFlower(size: fontSize * 0.55),
            const SizedBox(width: 8),
            Text(
              'Rasa',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -fontSize * 0.065,
                color: textColor ?? AppColors.espresso,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 9),
          Text(
            'Ruang aman untuk rasa',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.75,
              color: AppColors.mocha,
            ),
          ),
        ],
      ],
    );
  }
}

class _RasaFlower extends StatelessWidget {
  final double size;

  const _RasaFlower({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.314, // -18 derajat
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Kelopak 1: terracotta (kiri atas)
            Positioned(
              left: size * 0.39,
              top: size * 0.43,
              child: _Petal(
                size: size * 0.475,
                color: AppColors.terracotta,
                rotation: -30,
              ),
            ),
            // Kelopak 2: dusty rose (kanan)
            Positioned(
              left: size * 0.35,
              top: size * 0.43,
              child: _Petal(
                size: size * 0.475,
                color: AppColors.dustyRose,
                rotation: 68,
              ),
            ),
            // Kelopak 3: sage (bawah)
            Positioned(
              left: size * 0.30,
              top: size * 0.39,
              child: _Petal(
                size: size * 0.475,
                color: const Color(0xFF8FA88F),
                rotation: 182,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Petal extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;

  const _Petal({
    required this.size,
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      alignment: Alignment.bottomLeft,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size * 0.82),
            topRight: Radius.circular(size * 0.18),
            bottomLeft: Radius.circular(size * 0.82),
            bottomRight: Radius.circular(size * 0.18),
          ),
        ),
      ),
    );
  }
}