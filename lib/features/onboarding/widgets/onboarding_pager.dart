import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPager extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const OnboardingPager({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 5),
          width: isActive ? 19 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.terracotta : const Color(0xFFE8CABC),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}