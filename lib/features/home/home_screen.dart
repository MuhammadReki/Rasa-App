import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import 'providers/article_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_tag_rail.dart';
import 'widgets/home_section_title.dart';
import 'widgets/article_card.dart';
import 'widgets/featured_article_card.dart';
import 'widgets/bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedTag = 'Untukmu';

  final List<String> _tags = [
    'Untukmu',
    '#patahhati',
    '#selflove',
    '#relationship',
    '#random',
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final bg = AppColors.background(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => context.go('/submit-story'),
          backgroundColor: AppColors.accent(isDark),
          child: Icon(
            Icons.edit_outlined,
            color: isDark ? AppColors.midnight : Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 20),
                    HomeSearchBar(
                      onTap: () => context.go('/search'),
                    ),
                    const SizedBox(height: 14),
                    HomeTagRail(
                      tags: _tags,
                      selectedTag: _selectedTag,
                      onTagSelected: (tag) {
                        setState(() => _selectedTag = tag);
                        ref.read(selectedTagProvider.notifier).state = tag;
                      },
                    ),
                    const SizedBox(height: 17),
                    HomeSectionTitle(
                      eyebrow: 'PILIHAN HARI INI',
                      title: 'Untukmu',
                      actionText: 'Lihat semua',
                      onAction: () {},
                    ),
                    const SizedBox(height: 10),
                    articlesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 48,
                              color: textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum bisa terhubung',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cek koneksi internet kamu, lalu coba lagi.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      data: (articles) {
                        if (articles.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    size: 48,
                                    color:
                                        textSecondary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada cerita',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Jadilah yang pertama menulis.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final featured = articles.first;
                        final rest = articles.skip(1).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RepaintBoundary(
                              child: FeaturedArticleCard(
                                article: featured,
                                onTap: () {
                                  context.go('/article/${featured.id}');
                                },
                              ),
                            ),
                            if (rest.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              HomeSectionTitle(
                                title: 'Cerita terbaru',
                                trailing: Icon(
                                  Icons.more_horiz,
                                  size: 20,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...rest.map(
                                (article) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 14),
                                  child: RepaintBoundary(
                                    child: ArticleCard(
                                      article: article,
                                      onTap: () {
                                        context
                                            .go('/article/${article.id}');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            BottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                switch (index) {
                  case 0:
                    break;
                  case 1:
                    context.go('/search');
                    break;
                  case 2:
                    context.go('/bookmarks');
                    break;
                  case 3:
                    context.go('/profile');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}