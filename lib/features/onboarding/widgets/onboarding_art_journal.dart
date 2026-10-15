import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingArtJournal extends StatelessWidget {
  const OnboardingArtJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8EADA), Color(0xFFF4D8C3)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 52,
            left: 46,
            child: Container(
              width: 77,
              height: 77,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEFBF9D).withOpacity(0.75),
              ),
            ),
          ),
          Positioned(
            top: 125,
            left: 135,
            child: Transform.rotate(
              angle: -0.087,
              child: Container(
                width: 100,
                height: 108,
                decoration: const BoxDecoration(
                  color: Color(0xFFC47B60),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 87,
            left: 157,
            child: SizedBox(
              width: 45,
              height: 55,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Transform.rotate(
                      angle: 0.17,
                      child: Container(
                        width: 45,
                        height: 27,
                        decoration: const BoxDecoration(
                          color: AppColors.espresso,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 8,
                    child: Container(
                      width: 37,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBC7658),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(17),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 40,
            right: 10,
            child: Transform.rotate(
              angle: -0.035,
              child: Container(
                height: 17,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B624D),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            top: 201,
            left: 145,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 72,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9EC),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF583624).withOpacity(0.13),
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 35,
                      top: 0,
                      child: Container(
                        width: 1,
                        height: 43,
                        color: const Color(0xFFE6CDBB),
                      ),
                    ),
                    Positioned(
                      top: 11,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 1,
                        color: const Color(0xFFD9B19C),
                      ),
                    ),
                    Positioned(
                      top: 17,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 1,
                        color: const Color(0xFFD9B19C),
                      ),
                    ),
                    Positioned(
                      top: 23,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 1,
                        color: const Color(0xFFD9B19C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 62,
            right: 44,
            child: Transform.rotate(
              angle: 0.33,
              child: SizedBox(
                width: 25,
                height: 90,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 12,
                      top: 0,
                      child: Container(
                        width: 2,
                        height: 85,
                        color: const Color(0xFF849B75),
                      ),
                    ),
                    Positioned(
                      top: 11,
                      left: -4,
                      child: Transform.rotate(
                        angle: -0.45,
                        child: const _Leaf(),
                      ),
                    ),
                    Positioned(
                      top: 35,
                      left: 12,
                      child: Transform.rotate(
                        angle: 0.73,
                        child: const _Leaf(),
                      ),
                    ),
                    Positioned(
                      top: 56,
                      left: -2,
                      child: Transform.rotate(
                        angle: -0.38,
                        child: const _Leaf(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFF8FA88F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(2),
        ),
      ),
    );
  }
}