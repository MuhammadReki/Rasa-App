import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../article/repositories/interaction_repository.dart';
import '../home/models/article.dart';
import 'providers/profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    final supabase = ref.read(supabaseProvider);
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    final repo = ref.read(profileRepositoryProvider);
    final isFollowing = await repo.isFollowing(
      followerId: currentUserId,
      followingId: widget.userId,
    );

    if (mounted) {
      setState(() => _isFollowing = isFollowing);
    }
  }

  Future<void> _toggleFollow() async {
    final supabase = ref.read(supabaseProvider);
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => _isLoadingFollow = true);

    try {
      final repo = ref.read(profileRepositoryProvider);

      if (_isFollowing) {
        await repo.unfollow(
          followerId: currentUserId,
          followingId: widget.userId,
        );
      } else {
        await repo.follow(
          followerId: currentUserId,
          followingId: widget.userId,
        );
      }

      ref.invalidate(followersCountProvider(widget.userId));
      ref.invalidate(followingCountProvider(widget.userId));

      if (!mounted) return;

      setState(() {
        _isFollowing = !_isFollowing;
        _isLoadingFollow = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'Mengikuti' : 'Berhenti mengikuti'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFollow = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  Future<void> _confirmBlock() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blokir user ini?'),
        content: const Text(
          'Kamu tidak akan melihat artikel & komentar dari user ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Blokir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = InteractionRepository(ref.read(supabaseProvider));
      final currentUserId =
          ref.read(supabaseProvider).auth.currentUser?.id;
      if (currentUserId == null) return;

      await repo.blockUser(
        blockerId: currentUserId,
        blockedId: widget.userId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User diblokir')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal blokir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final border = AppColors.dividerColor(isDark);
    final accent = AppColors.accent(isDark);

    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final articlesAsync = ref.watch(userArticlesProvider(widget.userId));
    final followersAsync = ref.watch(followersCountProvider(widget.userId));
    final followingAsync = ref.watch(followingCountProvider(widget.userId));

    final currentUserId = ref.read(supabaseProvider).auth.currentUser?.id;
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
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
                        child: Center(child: Text('User tidak ditemukan')),
                      );
                    }

                    final displayName =
                        profile['full_name'] as String? ?? 'Pengguna';
                    final username =
                        profile['username'] as String? ?? '@username';
                    final bio = profile['bio'] as String? ?? 'Bio belum diisi.';
                    final avatarUrl = profile['avatar_url'] as String?;

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
                                  left: 16,
                                  child: GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        size: 17,
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
                                  child: _buildAvatar(avatarUrl, isDark),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -1,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      username,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      bio,
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
                                          '${articlesAsync.valueOrNull?.length ?? 0}',
                                          'Artikel',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                        const SizedBox(width: 19),
                                        _buildStat(
                                          '${followersAsync.valueOrNull ?? 0}',
                                          'Pengikut',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                        const SizedBox(width: 19),
                                        _buildStat(
                                          '${followingAsync.valueOrNull ?? 0}',
                                          'Mengikuti',
                                          textPrimary,
                                          textSecondary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    if (!isOwnProfile) ...[
                                      GestureDetector(
                                        onTap: _isLoadingFollow
                                            ? null
                                            : _toggleFollow,
                                        child: Container(
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: _isFollowing
                                                ? Colors.transparent
                                                : accent,
                                            border: Border.all(
                                              color: _isFollowing
                                                  ? (isDark
                                                      ? const Color(0xFF454562)
                                                      : const Color(0xFFD9BDAB))
                                                  : accent,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (_isLoadingFollow)
                                                SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: _isFollowing
                                                        ? textPrimary
                                                        : (isDark
                                                            ? AppColors.midnight
                                                            : Colors.white),
                                                  ),
                                                )
                                              else ...[
                                                Icon(
                                                  _isFollowing
                                                      ? Icons.check
                                                      : Icons.person_add,
                                                  size: 15,
                                                  color: _isFollowing
                                                      ? textPrimary
                                                      : (isDark
                                                          ? AppColors.midnight
                                                          : Colors.white),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _isFollowing
                                                      ? 'Mengikuti'
                                                      : 'Ikuti',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: _isFollowing
                                                        ? textPrimary
                                                        : (isDark
                                                            ? AppColors.midnight
                                                            : Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _confirmBlock,
                                        child: Container(
                                          height: 36,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red
                                                  .withValues(alpha: 0.5),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.block,
                                                size: 15,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Blokir',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Artikel',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Divider(height: 1, color: border),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          child: articlesAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(40),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (articles) {
                              if (articles.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Center(
                                    child: Text(
                                      'Belum ada artikel',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: articles
                                    .map((article) => _buildArticleItem(
                                          article,
                                          textPrimary,
                                          textSecondary,
                                          border,
                                          isDark,
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(
    Article article,
    Color textPrimary,
    Color textSecondary,
    Color border,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => context.push('/article/${article.id}'),
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
  }

  Widget _buildAvatar(String? avatarUrl, bool isDark) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 38,
        backgroundImage: NetworkImage(avatarUrl),
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
}