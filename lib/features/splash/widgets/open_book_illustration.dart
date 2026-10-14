import 'package:flutter/material.dart';

class OpenBookIllustration extends StatelessWidget {
  final double width;
  final double height;

  const OpenBookIllustration({
    super.key,
    this.width = 113,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Tangkai daun
          Positioned(
            top: -30,
            left: width / 2 - 1,
            child: Transform.rotate(
              angle: 0.19,
              child: const _BookStem(),
            ),
          ),
          // Buku terbuka
          Positioned(
            top: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Halaman kiri
                Transform(
                  transform: Matrix4.skewY(0.105),
                  child: const _BookPage(isLeft: true),
                ),
                const SizedBox(width: 2),
                // Halaman kanan
                Transform(
                  transform: Matrix4.skewY(-0.105),
                  child: const _BookPage(isLeft: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookPage extends StatelessWidget {
  final bool isLeft;

  const _BookPage({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const bookColor = Color(0xFF8F644D);
    return Container(
      width: 55,
      height: 51,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        border: Border.all(
          color: bookColor.withOpacity(0.35),
          width: 1,
        ),
        borderRadius: isLeft
            ? const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(7),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(5),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 17, left: 17, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1, color: bookColor.withOpacity(0.45)),
            const SizedBox(height: 6),
            Container(height: 1, color: bookColor.withOpacity(0.35)),
            const SizedBox(height: 6),
            Container(height: 1, color: bookColor.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}

class _BookStem extends StatelessWidget {
  const _BookStem();

  @override
  Widget build(BuildContext context) {
    const stemColor = Color(0xFF8FA88F);
    return SizedBox(
      width: 12,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Batang
          Positioned(
            left: 5,
            top: 0,
            child: Container(
              width: 2,
              height: 38,
              color: stemColor,
            ),
          ),
          // Daun 1
          Positioned(
            left: -4,
            top: 8,
            child: Transform.rotate(
              angle: 0.5,
              child: _Leaf(color: stemColor),
            ),
          ),
          // Daun 2
          Positioned(
            left: 6,
            top: 19,
            child: Transform.rotate(
              angle: -0.75,
              child: _Leaf(color: stemColor),
            ),
          ),
          // Daun 3
          Positioned(
            left: -5,
            top: 27,
            child: Transform.rotate(
              angle: 0.63,
              child: _Leaf(color: stemColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  final Color color;

  const _Leaf({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(0),
        ),
      ),
    );
  }
}