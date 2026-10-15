import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/providers/article_provider.dart';
import 'repositories/interaction_repository.dart';
import 'providers/interaction_provider.dart';
import 'widgets/article_hero.dart';
import 'widgets/article_meta.dart';
import 'widgets/article_body.dart';
import 'widgets/comment_preview.dart';
import 'widgets/article_action_bar.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  final String articleId;
  const ArticleScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  late final InteractionRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = InteractionRepository(ref.read(supabaseProvider));
  }

  Future<void> _toggleLike(bool isLiked) async {
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return;

    await _repo.toggleLike(
      userId: userId,
      articleId: widget.articleId,
      isLiked: isLiked,
    );

    ref.invalidate(isLikedProvider(widget.articleId));
    ref.invalidate(likeCountProvider(widget.articleId));
  }

  Future<void> _toggleBookmark(bool isBookmarked) async {
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return;

    await _repo.toggleBookmark(
      userId: userId,
      articleId: widget.articleId,
      isBookmarked: isBookmarked,
    );

    ref.invalidate(isBookmarkedProvider(widget.articleId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBookmarked ? 'Dihapus dari simpanan' : 'Disimpan ke koleksi',
          ),
        ),
      );
    }
  }

  Future<void> _shareArticle(String title) async {
    final url = 'https://rasa.app/article/${widget.articleId}';
    final text = '$title\n\nBaca di Rasa:\n$url';

    try {
      await Share.share(text, subject: title);
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link disalin ke clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.surface(isDark);
    final titleColor = AppColors.textPrimary(isDark);
    final commentsHeadingColor =
        isDark ? AppColors.darkText : const Color(0xFF4E382D);
    final commentsCountColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFFAD8D78);
    final linkColor = isDark ? AppColors.lavender : const Color(0xFFB4694D);
    final dividerColor = AppColors.dividerColor(isDark);
    final tagBg = isDark ? const Color(0xFF3E2A2A) : const Color(0xFFF3DDD7);
    final tagText = isDark ? const Color(0xFFE8A8A8) : const Color(0xFFAA5C5C);
    final inputBg = AppColors.surface(isDark);
    final inputBorderColor =
        isDark ? const Color(0xFF454562) : const Color(0xFFE9DCCF);
    final inputHintColor =
        isDark ? const Color(0xFF89899F) : const Color(0xFFA58A79);
    final inputIconBg = isDark ? AppColors.lavender : AppColors.terracotta;
    final inputIconColor = isDark ? AppColors.midnight : Colors.white;

    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    final isLikedAsync = ref.watch(isLikedProvider(widget.articleId));
    final likeCountAsync = ref.watch(likeCountProvider(widget.articleId));
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(widget.articleId));
    final commentCountAsync = ref.watch(commentCountProvider(widget.articleId));

    return Scaffold(
      backgroundColor: bg,
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: AppColors.textSecondary(isDark),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat cerita',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Cerita tidak ditemukan'));
          }

          return SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: ArticleHero(
                            coverUrl: article.coverUrl,
                            readTime: article.readTime.toUpperCase(),
                            onBack: () => context.go('/home'),
                            onShare: () => _shareArticle(article.title),
                            onBookmark: () async {
                              final isBookmarked =
                                  isBookmarkedAsync.valueOrNull ?? false;
                              await _toggleBookmark(isBookmarked);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 17, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tagBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  article.tag,
                                  style: GoogleFonts.inter(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w600,
                                    color: tagText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                article.title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  height: 1.04,
                                  letterSpacing: -1.4,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 11),
                              ArticleMeta(
                                authorId: article.authorId,
                                authorName: article.authorName,
                                authorAvatarUrl: article.authorAvatarUrl,
                                date: article.date,
                                readTime: article.readTime,
                                views: article.views,
                              ),
                              const SizedBox(height: 15),
                              Container(height: 1, color: dividerColor),
                              const SizedBox(height: 14),
                              const ArticleBody(),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: commentsHeadingColor,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Ruang percakapan ',
                                        ),
                                        TextSpan(
                                          text:
                                              '${commentCountAsync.valueOrNull ?? 0}',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: commentsCountColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go(
                                        '/comments/${widget.articleId}'),
                                    child: Text(
                                      'Lihat semua',
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        color: linkColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (commentCountAsync.valueOrNull != null &&
                                  (commentCountAsync.valueOrNull ?? 0) > 0)
                                Consumer(
                                  builder: (context, ref, _) {
                                    final commentsAsync = ref.watch(
                                        commentsProvider(widget.articleId));
                                    return commentsAsync.when(
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) =>
                                          const SizedBox.shrink(),
                                      data: (comments) {
                                        if (comments.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        final c = comments.first;
                                        final profile = c['profiles']
                                            as Map<String, dynamic>?;
                                        return CommentPreview(
                                          name: profile?['full_name'] ??
                                              'Anonim',
                                          avatarUrl:
                                              profile?['avatar_url'] ?? '',
                                          timeAgo: 'Baru saja',
                                          comment: c['content'] ?? '',
                                        );
                                      },
                                    );
                                  },
                                ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ArticleActionBar(
                  likes: likeCountAsync.valueOrNull ?? 0,
                  comments: commentCountAsync.valueOrNull ?? 0,
                  isLiked: isLikedAsync.valueOrNull ?? false,
                  isBookmarked: isBookmarkedAsync.valueOrNull ?? false,
                  onLike: () async {
                    final isLiked = isLikedAsync.valueOrNull ?? false;
                    await _toggleLike(isLiked);
                  },
                  onComment: () =>
                      context.go('/comments/${widget.articleId}'),
                  onShare: () => _shareArticle(article.title),
                  onBookmark: () async {
                    final isBookmarked =
                        isBookmarkedAsync.valueOrNull ?? false;
                    await _toggleBookmark(isBookmarked);
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: Container(
        color: inputBg,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => context.go('/comments/${widget.articleId}'),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: inputBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF3E2C23))
                        .withValues(alpha: 0.06),
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/100?img=47'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tulis komentar...',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: inputHintColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: inputIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      size: 13,
                      color: inputIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}