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

  String? _replyingToId;
  String? _replyingToName;
  final _replyController = TextEditingController();
  bool _isSendingReply = false;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
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

  Future<void> _sendReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty || _replyingToId == null) return;

    setState(() => _isSendingReply = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      final repo = InteractionRepository(supabase);
      await repo.addReply(
        userId: userId,
        articleId: widget.articleId,
        parentId: _replyingToId!,
        content: content,
      );

      _replyController.clear();
      final parentId = _replyingToId!;

      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });

      ref.invalidate(commentRepliesProvider(parentId));
      ref.invalidate(commentsProvider(widget.articleId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balasan terkirim')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReply = false);
    }
  }

  void _startReply(String commentId, String name) {
    setState(() {
      _replyingToId = commentId;
      _replyingToName = name;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
      _replyController.clear();
    });
  }

  Future<void> _showEditDialog(String commentId, String currentContent) async {
    final controller = TextEditingController(text: currentContent);
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit Komentar',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 11, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Tulis komentar...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final repo = InteractionRepository(ref.read(supabaseProvider));
      await repo.updateComment(
        commentId: commentId,
        content: result,
      );

      ref.invalidate(commentsProvider(widget.articleId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar diupdate')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(String commentId) async {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus Komentar?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Text(
          'Komentar ini akan dihapus permanen.',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary(isDark),
          ),
        ),
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
      final repo = InteractionRepository(ref.read(supabaseProvider));
      await repo.deleteComment(commentId);

      ref.invalidate(commentsProvider(widget.articleId));
      ref.invalidate(commentCountProvider(widget.articleId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar dihapus')),
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

  Future<void> _toggleBookmark(String commentId, bool isBookmarked) async {
    try {
      final userId = ref.read(supabaseProvider).auth.currentUser?.id;
      if (userId == null) return;

      final repo = InteractionRepository(ref.read(supabaseProvider));
      await repo.toggleCommentBookmark(
        userId: userId,
        commentId: commentId,
        isBookmarked: isBookmarked,
      );

      ref.invalidate(isCommentBookmarkedProvider(commentId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isBookmarked ? 'Bookmark dihapus' : 'Komentar disimpan'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  void _showCommentOptions({
    required String commentId,
    required String content,
    required String name,
    required bool isOwn,
    required bool isDark,
  }) {
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final bookmarkAsync = ref.read(isCommentBookmarkedProvider(commentId));
    final isBookmarked = bookmarkAsync.valueOrNull ?? false;

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
            if (isOwn) ...[
              ListTile(
                leading: Icon(Icons.edit_outlined, color: textPrimary),
                title: Text('Edit komentar',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(commentId, content);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Hapus komentar',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(commentId);
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.reply, color: textPrimary),
                title: Text('Balas komentar',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _startReply(commentId, name);
                },
              ),
              ListTile(
                leading: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: textPrimary,
                ),
                title: Text(
                  isBookmarked ? 'Hapus bookmark' : 'Simpan komentar',
                  style: GoogleFonts.inter(fontSize: 12, color: textPrimary),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _toggleBookmark(commentId, isBookmarked);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.flag_outlined, color: Colors.orange),
                title: Text('Laporkan',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.orange)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/report', extra: {'commentId': commentId});
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
    final currentUserId = ref.read(supabaseProvider).auth.currentUser?.id;

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
                      final profile =
                          c['profiles'] as Map<String, dynamic>?;
                      final commentId = c['id'] as String;
                      final authorName = profile?['full_name'] ?? 'Anonim';
                      final isOwn = c['user_id'] == currentUserId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildComment(
                            commentId: commentId,
                            name: authorName,
                            avatarUrl: profile?['avatar_url'] ?? '',
                            content: c['content'] ?? '',
                            isOwn: isOwn,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accent: accent,
                            isDark: isDark,
                          ),
                          _buildReplies(
                            commentId: commentId,
                            currentUserId: currentUserId,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accent: accent,
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_replyingToId != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                color: isDark
                    ? const Color(0xFF2A2535)
                    : const Color(0xFFF7EADB),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Membalas $_replyingToName',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: textSecondary,
                      ),
                    ),
                  ],
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
                          controller: _replyingToId != null
                              ? _replyController
                              : _commentController,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: _replyingToId != null
                                ? 'Tulis balasan...'
                                : 'Tulis komentar...',
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
                      onTap: _replyingToId != null
                          ? (_isSendingReply ? null : _sendReply)
                          : (_isSending ? null : _sendComment),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: (_isSending || _isSendingReply)
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
    required String commentId,
    required String name,
    required String avatarUrl,
    required String content,
    required bool isOwn,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required bool isDark,
  }) {
    return GestureDetector(
      onLongPress: () => _showCommentOptions(
        commentId: commentId,
        content: content,
        name: name,
        isOwn: isOwn,
        isDark: isDark,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: isDark
                  ? const Color(0xFF3A3A55)
                  : const Color(0xFFF0E4D6),
              child: avatarUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 18,
                      color: isDark
                          ? const Color(0xFFA084CA)
                          : const Color(0xFFC97B5A),
                    )
                  : null,
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
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(kamu)',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            color: accent,
                          ),
                        ),
                      ],
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
                  GestureDetector(
                    onTap: () => _startReply(commentId, name),
                    child: Text(
                      'Balas',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
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

  Widget _buildReplies({
    required String commentId,
    required String? currentUserId,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required bool isDark,
  }) {
    final repliesAsync = ref.watch(commentRepliesProvider(commentId));

    return repliesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (replies) {
        if (replies.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(left: 60, right: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: replies.map((r) {
              final profile = r['profiles'] as Map<String, dynamic>?;
              final avatarUrl = profile?['avatar_url'] ?? '';
              final name = profile?['full_name'] ?? 'Anonim';
              final replyId = r['id'] as String;
              final isOwn = r['user_id'] == currentUserId;

              return GestureDetector(
                onLongPress: () => _showCommentOptions(
                  commentId: replyId,
                  content: r['content'] ?? '',
                  name: name,
                  isOwn: isOwn,
                  isDark: isDark,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        backgroundColor: isDark
                            ? const Color(0xFF3A3A55)
                            : const Color(0xFFF0E4D6),
                        child: avatarUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 12,
                                color: isDark
                                    ? const Color(0xFFA084CA)
                                    : const Color(0xFFC97B5A),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                if (isOwn) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(kamu)',
                                    style: GoogleFonts.inter(
                                      fontSize: 7,
                                      fontStyle: FontStyle.italic,
                                      color: accent,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 5),
                                Text(
                                  'Baru saja',
                                  style: GoogleFonts.inter(
                                    fontSize: 7,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['content'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                height: 1.5,
                                color: textPrimary,
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
          ),
        );
      },
    );
  }
}