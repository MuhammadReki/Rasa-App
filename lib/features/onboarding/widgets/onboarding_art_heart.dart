import 'package:flutter/material.dart';

class OnboardingArtHeart extends StatelessWidget {
  const OnboardingArtHeart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.6,
          colors: [Color(0xFFF7DFD6), Color(0xFFFAF3E0)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.49,
            child: Container(
              width: 210,
              height: 125,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFB96568).withValues(alpha: 0.37),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.73,
            child: Container(
              width: 157,
              height: 208,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFB96568).withValues(alpha: 0.37),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          const Icon(
            Icons.favorite,
            size: 103,
            color: Color(0xFFB96568),
          ),
          const Positioned(
            top: 73,
            left: 89,
            child: _Sparkle(size: 4),
          ),
          const Positioned(
            top: 132,
            right: 75,
            child: _Sparkle(size: 7),
          ),
          const Positioned(
            bottom: 64,
            left: 103,
            child: _Sparkle(size: 6),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFC97B5A),
      ),
    );
  }
}