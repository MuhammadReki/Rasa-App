import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final int currentSlide;
  final int totalSlides;
  final String title;
  final String description;
  final Widget artwork;
  final VoidCallback onNext;
  final String nextLabel;

  const OnboardingPage({
    super.key,
    required this.currentSlide,
    required this.totalSlides,
    required this.title,
    required this.description,
    required this.artwork,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 31),
          // Ilustrasi (extend ke samping)
          Transform.translate(
            offset: const Offset(20, 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 307,
              child: artwork,
            ),
          ),
          const SizedBox(height: 29),
          // Progress text
          Text(
            '0$currentSlide / 0$totalSlides',
            style: AppTextStyles.eyebrow.copyWith(
              color: const Color(0xFFB4694D),
            ),
          ),
          const SizedBox(height: 10),
          // Judul
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 31,
              height: 1.01,
              letterSpacing: -1.7,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 11),
          // Deskripsi
          SizedBox(
            width: 220,
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                height: 1.65,
                color: AppColors.mocha,
              ),
            ),
          ),
        ],
      ),
    );
  }
}