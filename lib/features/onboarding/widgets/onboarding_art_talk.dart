import 'package:flutter/material.dart';

class OnboardingArtTalk extends StatelessWidget {
  const OnboardingArtTalk({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8E6D8), Color(0xFFEED5CB)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 46,
            child: Container(
              width: 215,
              height: 181,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A0A0).withValues(alpha: 0.36),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(110),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 50,
            child: _Person(
              headColor: const Color(0xFFA9654D),
              bodyColor: const Color(0xFFBB795F),
            ),
          ),
          Positioned(
            bottom: 48,
            right: 48,
            child: Transform.scale(
              scaleX: -1,
              child: const _Person(
                headColor: Color(0xFFC78466),
                bodyColor: Color(0xFF6B7D78),
              ),
            ),
          ),
          Positioned(
            top: 74,
            left: 88,
            child: _SpeechBubble(
              width: 35,
              height: 26,
              color: const Color(0xFFFFF7ED),
            ),
          ),
          Positioned(
            top: 105,
            right: 83,
            child: _SpeechBubble(
              width: 27,
              height: 20,
              color: const Color(0xFFDFAD94),
            ),
          ),
        ],
      ),
    );
  }
}

class _Person extends StatelessWidget {
  final Color headColor;
  final Color bodyColor;

  const _Person({
    required this.headColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 175,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 28,
            child: Container(
              width: 38,
              height: 43,
              decoration: BoxDecoration(
                color: headColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(18),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 92,
              height: 132,
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(49),
                  topRight: Radius.circular(49),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SpeechBubble({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 6,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 8,
            child: CustomPaint(
              size: const Size(6, 6),
              painter: _BubbleTailPainter(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;

  _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}