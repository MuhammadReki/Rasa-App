import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../article/providers/interaction_provider.dart';
import '../article/repositories/interaction_repository.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String articleId;
  const CommentsScreen({super.key, required this.articleId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      final repo = InteractionRepository(supabase);
      await repo.addComment(
        userId: userId,
        articleId: widget.articleId,
        content: content,
      );

      _commentController.clear();
      ref.invalidate(commentsProvider(widget.articleId));
      ref.invalidate(commentCountProvider(widget.articleId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar terkirim')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
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
    final accent = AppColors.accent(isDark);
    final inputBg = isDark ? AppColors.midnightSurface : Colors.white;
    final inputBorder =
        isDark ? const Color(0xFF454562) : const Color(0xFFE9DCCF);

    final commentsAsync = ref.watch(commentsProvider(widget.articleId));

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.go('/article/${widget.articleId}'),
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
                        'Ruang Percakapan',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  commentsAsync.when(
                    loading: () => const SizedBox(width: 24),
                    error: (_, __) => const SizedBox(width: 24),
                    data: (comments) => Text(
                      '${comments.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border),
            Expanded(
              child: commentsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    'Gagal memuat komentar',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: accent.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada komentar',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Jadilah yang pertama berbagi.',
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

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 60,
                      color: border,
                    ),
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final profile = c['profiles'] as Map<String, dynamic>?;
                      return _buildComment(
                        name: profile?['full_name'] ?? 'Anonim',
                        avatarUrl: profile?['avatar_url'] ??
                            'https://i.pravatar.cc/100?img=47',
                        content: c['content'] ?? '',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accent: accent,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/100?img=47'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: inputBorder),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Tulis komentar...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isSending ? null : _sendComment,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: _isSending
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark
                                      ? AppColors.midnight
                                      : Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                size: 15,
                                color: isDark
                                    ? AppColors.midnight
                                    : Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment({
    required String name,
    required String avatarUrl,
    required String content,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Baru saja',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.5,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Balas',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}