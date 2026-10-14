import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../splash/widgets/rasa_logo.dart';
import 'widgets/onboarding_art_journal.dart';
import 'widgets/onboarding_art_talk.dart';
import 'widgets/onboarding_art_heart.dart';
import 'widgets/onboarding_pager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_SlideData> _slides = [
    _SlideData(
      title: 'Tulis rasamu',
      description: 'Tak perlu sempurna. Ceritamu pantas punya ruang.',
      artworkBuilder: _buildJournalArt,
    ),
    _SlideData(
      title: 'Baca cerita orang lain',
      description: 'Temukan kata yang mengerti isi kepalamu.',
      artworkBuilder: _buildTalkArt,
    ),
    _SlideData(
      title: 'Temukan ruang amanmu',
      description: 'Datang apa adanya. Pulang dengan lebih lega.',
      artworkBuilder: _buildHeartArt,
    ),
  ];

  static Widget _buildJournalArt() => const OnboardingArtJournal();
  static Widget _buildTalkArt() => const OnboardingArtTalk();
  static Widget _buildHeartArt() => const OnboardingArtHeart();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RasaLogo(
                    fontSize: 20,
                    showTagline: false,
                  ),
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.inter(
                        color: AppColors.mocha,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingSlideContent(
                    currentSlide: index + 1,
                    totalSlides: _slides.length,
                    title: slide.title,
                    description: slide.description,
                    artwork: slide.artworkBuilder(),
                  );
                },
              ),
            ),
            // Bottom bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 31),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingPager(
                    totalPages: _slides.length,
                    currentPage: _currentPage,
                  ),
                  _NextButton(onPressed: _nextPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String description;
  final Widget Function() artworkBuilder;

  const _SlideData({
    required this.title,
    required this.description,
    required this.artworkBuilder,
  });
}

class _OnboardingSlideContent extends StatefulWidget {
  final int currentSlide;
  final int totalSlides;
  final String title;
  final String description;
  final Widget artwork;

  const _OnboardingSlideContent({
    required this.currentSlide,
    required this.totalSlides,
    required this.title,
    required this.description,
    required this.artwork,
  });

  @override
  State<_OnboardingSlideContent> createState() =>
      _OnboardingSlideContentState();
}

class _OnboardingSlideContentState extends State<_OnboardingSlideContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 19),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 307,
          child: widget.artwork,
        ),
        const SizedBox(height: 29),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '0${widget.currentSlide} / 0${widget.totalSlides}',
                style: GoogleFonts.dmMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                  color: const Color(0xFFB4694D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 31,
                  fontWeight: FontWeight.w600,
                  height: 1.01,
                  letterSpacing: -1.7,
                  color: AppColors.espresso,
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: 240,
                child: Text(
                  widget.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.65,
                    color: AppColors.mocha,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NextButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}