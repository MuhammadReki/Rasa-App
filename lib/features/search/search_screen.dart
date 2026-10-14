import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/models/article.dart';
import '../home/providers/article_provider.dart';
import '../home/widgets/bottom_nav.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  int _currentNavIndex = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final accent = AppColors.accent(isDark);
    final inputBorder = isDark
        ? const Color(0xFF454562)
        : const Color(0xFFEADACA);
    final inputBg = isDark
        ? AppColors.midnightSurface
        : const Color(0xFFFFFAF4);

    final searchResults = ref.watch(searchResultsProvider);
    final trendingAsync = ref.watch(trendingTagsProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Container(
                            height: 40,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: accent, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 17,
                                  color: accent,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearch,
                                    onSubmitted: _onSearch,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Cari cerita...',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _onSearch('');
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color: textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Trending tags
                    if (_searchController.text.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tag yang ramai dibaca',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      trendingAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (trends) {
                          if (trends.isEmpty) {
                            return Text(
                              'Belum ada tag trending',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: textSecondary,
                              ),
                            );
                          }

                          return Row(
                            children: [
                              for (var i = 0; i < trends.length; i++) ...[
                                if (i > 0) const SizedBox(width: 6),
                                Expanded(
                                  child: _buildTrendCard(
                                    '${(i + 1).toString().padLeft(2, '0')}',
                                    trends[i]['tag'],
                                    '${trends[i]['count']} cerita',
                                    textPrimary,
                                    textSecondary,
                                    accent,
                                    inputBg,
                                    inputBorder,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Hasil pencarian
                    if (_searchController.text.isNotEmpty) ...[
                      Text(
                        'Hasil untuk "${_searchController.text}"',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 11),
                      searchResults.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Center(
                          child: Text(
                            'Error: $e',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        data: (results) {
                          if (results.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color:
                                          textSecondary.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada hasil',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Coba kata kunci lain.',
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

                          return Column(
                            children: [
                              for (final article in results)
                                _buildCompactStory(
                                  article,
                                  textPrimary,
                                  textSecondary,
                                  AppColors.dividerColor(isDark),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
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
                    context.go('/home');
                    break;
                  case 1:
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

  Widget _buildTrendCard(
    String rank,
    String tag,
    String count,
    Color textPrimary,
    Color textSecondary,
    Color accent,
    Color bg,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rank,
            style: GoogleFonts.dmMono(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 7,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStory(
    Article article,
    Color textPrimary,
    Color textSecondary,
    Color border,
  ) {
    return GestureDetector(
      onTap: () => context.go('/article/${article.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.coverUrl,
                width: 64,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 55,
                  color: const Color(0xFF3A3A55),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2A2A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.tag,
                      style: GoogleFonts.inter(
                        fontSize: 6,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8A8A8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.17,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${article.authorName} · ${article.date} · ${article.readTime}',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.bookmark_border,
              size: 17,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}