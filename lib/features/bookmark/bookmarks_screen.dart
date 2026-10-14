import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/widgets/bottom_nav.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  int _currentNavIndex = 2;
  int _currentTab = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookmarks());
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _bookmarks = [];
        });
        return;
      }

      final data = await supabase
          .from('bookmarks')
          .select('''
            id, created_at,
            articles!bookmarks_article_id_fkey (
              id, title, preview, cover_url, tag, created_at,
              profiles!articles_author_id_fkey (full_name)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _bookmarks = [];
      });
    }
  }

  Future<void> _removeBookmark(String bookmarkId) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('bookmarks').delete().eq('id', bookmarkId);

      setState(() {
        _bookmarks.removeWhere((b) => b['id'] == bookmarkId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari simpanan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final border = AppColors.dividerColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 17,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Disimpan',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 240,
                  child: Text(
                    'Sudut kecil untuk cerita yang ingin kamu simpan lebih lama.',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 1.5,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab(
                    'Artikel',
                    0,
                    count: _bookmarks.length,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 19),
                  _buildTab('Komentar', 1, count: 0, isDark: isDark),
                ],
              ),
            ),
            Divider(height: 1, color: border),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentTab == 0
                      ? _buildBookmarksList(isDark)
                      : _buildEmptyState(isDark),
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
                    context.go('/search');
                    break;
                  case 2:
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

  Widget _buildTab(String label, int index,
      {required int count, required bool isDark}) {
    final isActive = _currentTab == index;
    final activeColor = AppColors.accent(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? textPrimary : textSecondary,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 8,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(bool isDark) {
    if (_bookmarks.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final accent = AppColors.accent(isDark);
    final border = AppColors.dividerColor(isDark);

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      color: accent,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(17, 9, 17, 100),
        itemCount: _bookmarks.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: border),
        itemBuilder: (context, index) {
          final bookmark = _bookmarks[index];
          final article = bookmark['articles'] as Map<String, dynamic>?;
          if (article == null) return const SizedBox.shrink();

          final profile =
              article['profiles'] as Map<String, dynamic>?;
          final authorName = profile?['full_name'] as String? ?? 'Anonim';
          final title = article['title'] as String? ?? '';
          final coverUrl = article['cover_url'] as String? ?? '';
          final tag = article['tag'] as String? ?? '#random';
          final articleId = article['id'] as String? ?? '';

          return GestureDetector(
            onTap: () => context.go('/article/$articleId'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCover(coverUrl, isDark),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTag(tag, isDark),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.4,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$authorName · 5 min read',
                          style: GoogleFonts.inter(
                            fontSize: 7,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeBookmark(bookmark['id']),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.bookmark,
                        size: 18,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCover(String url, bool isDark) {
    if (url.isEmpty) {
      return Container(
        width: 67,
        height: 59,
        color: isDark ? const Color(0xFF3A3A55) : const Color(0xFFF0E4D6),
      );
    }
    return Image.network(
      url,
      width: 67,
      height: 59,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 67,
        height: 59,
        color: isDark ? const Color(0xFF3A3A55) : const Color(0xFFF0E4D6),
      ),
    );
  }

  Widget _buildTag(String tag, bool isDark) {
    Color bgColor;
    Color textColor;

    if (isDark) {
      bgColor = const Color(0xFF2E3A2E);
      textColor = const Color(0xFFA8C8A8);
    } else {
      bgColor = const Color(0xFFE0E9DF);
      textColor = const Color(0xFF587458);
    }

    if (tag == '#patahhati') {
      bgColor = isDark ? const Color(0xFF3E2A2A) : const Color(0xFFF3DDD7);
      textColor = isDark ? const Color(0xFFE8A8A8) : const Color(0xFFAA5C5C);
    } else if (tag == '#relationship') {
      bgColor = isDark ? const Color(0xFF3E2E2E) : const Color(0xFFF2DDDD);
      textColor = isDark ? const Color(0xFFE8B0B0) : const Color(0xFF9F6666);
    } else if (tag == '#random') {
      bgColor = isDark ? const Color(0xFF2A3540) : const Color(0xFFE0E9F1);
      textColor = isDark ? const Color(0xFFA8C0D8) : const Color(0xFF557594);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 6,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final accent = AppColors.accent(isDark);

    final message = _currentTab == 0
        ? 'Belum ada cerita tersimpan'
        : 'Belum ada komentar tersimpan';

    final subMessage = _currentTab == 0
        ? 'Simpan cerita yang ingin kamu baca lagi.'
        : 'Simpan komentar yang ingin kamu ingat.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentTab == 0
                    ? Icons.bookmark_border
                    : Icons.chat_bubble_outline,
                size: 48,
                color: accent.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}