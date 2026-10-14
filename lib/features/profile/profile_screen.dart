import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/models/article.dart';
import '../home/providers/article_provider.dart';
import '../home/widgets/bottom_nav.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _currentNavIndex = 3;
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final border = AppColors.dividerColor(isDark);

    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: profileAsync.when(
                  loading: () => const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SizedBox(
                    height: 400,
                    child: Center(
                      child: Text(
                        'Gagal memuat profil',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                  data: (profile) {
                    if (profile == null) {
                      return const SizedBox(
                        height: 400,
                        child: Center(child: Text('Silakan login ulang')),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: SizedBox(
                            height: 133,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFD8997D),
                                        Color(0xFFD5A596),
                                        Color(0xFF8DA28D),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 36,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => context.go('/settings'),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.settings_outlined,
                                        size: 18,
                                        color: Color(0xFF513B30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -41),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _buildAvatar(profile, isDark),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.displayName,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -1,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile.displayUsername,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      profile.displayBio,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        height: 1.55,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        _buildStat(
                                          '${profile.articleCount}',
                                          'Artikel',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                        const SizedBox(width: 19),
                                        _buildStat(
                                          '0',
                                          'Pengikut',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                        const SizedBox(width: 19),
                                        _buildStat(
                                          '0',
                                          'Mengikuti',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    GestureDetector(
                                      onTap: () async {
                                        await context.push('/edit-profile');
                                        if (context.mounted) {
                                          ref.invalidate(myProfileProvider);
                                        }
                                      },
                                      child: Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF454562)
                                                : const Color(0xFFD9BDAB),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 15,
                                              color: textPrimary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Edit profil',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    _buildProfileTab('Artikel saya', 0, isDark),
                                    const SizedBox(width: 18),
                                    _buildProfileTab('Disukai', 1, isDark),
                                    const SizedBox(width: 18),
                                    _buildProfileTab('Disimpan', 2, isDark),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: border),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          child: _buildTabContent(isDark),
                        ),
                      ],
                    );
                  },
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
                    context.go('/search');
                    break;
                  case 2:
                    context.go('/bookmarks');
                    break;
                  case 3:
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_currentTab) {
      case 0:
        return _buildArticleList(ref.watch(myArticlesProvider), isDark,
            emptyMsg: 'Belum ada cerita yang ditulis.',
            emptySubMsg: 'Mulai menulis cerita pertamamu.');
      case 1:
        return _buildArticleList(ref.watch(likedArticlesProvider), isDark,
            emptyMsg: 'Belum ada cerita yang disukai.',
            emptySubMsg: 'Tap ❤️ di artikel untuk menyukai.');
      case 2:
        return _buildArticleList(ref.watch(bookmarkedArticlesProvider), isDark,
            emptyMsg: 'Belum ada cerita yang disimpan.',
            emptySubMsg: 'Tap 🔖 di artikel untuk menyimpan.');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildArticleList(
    AsyncValue<List<Article>> articlesAsync,
    bool isDark, {
    required String emptyMsg,
    required String emptySubMsg,
  }) {
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final border = AppColors.dividerColor(isDark);

    return articlesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Gagal memuat',
            style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
          ),
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
                    Icons.edit_note,
                    size: 48,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMsg,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptySubMsg,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: articles.map((article) {
            return GestureDetector(
              onTap: () => context.go('/article/${article.id}'),
              onLongPress: _currentTab == 0
                  ? () => _showArticleOptions(article, isDark)
                  : null,
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
                        width: 60,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 54,
                          color: isDark
                              ? const Color(0xFF3A3A55)
                              : const Color(0xFFF0E4D6),
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
                              color: isDark
                                  ? const Color(0xFF2A3540)
                                  : const Color(0xFFE0E9F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.tag,
                              style: GoogleFonts.inter(
                                fontSize: 6,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFA8C0D8)
                                    : const Color(0xFF557594),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.17,
                              letterSpacing: -0.4,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${article.date} · ${article.views} views',
                            style: GoogleFonts.inter(
                              fontSize: 7,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showArticleOptions(Article article, bool isDark) {
    final textPrimary = AppColors.textPrimary(isDark);
    final surface = AppColors.surface(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: textPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: textPrimary),
              title: Text(
                'Edit cerita',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-article', extra: article);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Hapus cerita',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _confirmDelete(article);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Article article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus cerita?'),
        content: Text('Cerita "${article.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteArticle(article.id);

      ref.invalidate(myArticlesProvider);
      ref.invalidate(articlesProvider);
      ref.invalidate(myProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cerita berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: $e')),
        );
      }
    }
  }

  Widget _buildAvatar(ProfileData profile, bool isDark) {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 38,
        backgroundImage: NetworkImage(profile.avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 38,
      backgroundColor:
          isDark ? AppColors.midnightSurface : const Color(0xFFF0E4D6),
      child: Icon(
        Icons.person,
        size: 38,
        color: isDark ? AppColors.lavender : AppColors.terracotta,
      ),
    );
  }

  Widget _buildStat(String value, String label, Color textPrimary,
      Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(String label, int index, bool isDark) {
    final isActive = _currentTab == index;
    final accent = AppColors.accent(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? textPrimary : textSecondary,
          ),
        ),
      ),
    );
  }
}