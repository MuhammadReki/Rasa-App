import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/supabase/supabase_client.dart';
import '../admin/providers/admin_provider.dart';
import '../home/models/article.dart';
import '../home/providers/article_provider.dart';
import '../profile/providers/profile_provider.dart';

class EditArticleScreen extends ConsumerStatefulWidget {
  final Article article;
  const EditArticleScreen({super.key, required this.article});

  @override
  ConsumerState<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends ConsumerState<EditArticleScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedTag;
  bool _isSaving = false;

  final List<String> _tags = [
    '#patahhati',
    '#selflove',
    '#relationship',
    '#random',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _contentController = TextEditingController(text: widget.article.preview);
    _selectedTag = _tags.contains(widget.article.tag)
        ? widget.article.tag
        : '#random';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      _showSnack('Judul dan isi wajib diisi');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUserId =
          ref.read(supabaseProvider).auth.currentUser?.id;
      final isOwner = currentUserId == widget.article.authorId;

      if (isOwner) {
        // Owner — pakai profile repository
        final repo = ref.read(profileRepositoryProvider);
        await repo.updateArticle(
          articleId: widget.article.id,
          title: title,
          content: content,
          tag: _selectedTag,
        );
        ref.invalidate(myArticlesProvider);
      } else {
        // Admin — pakai admin repository (bypass owner check)
        final adminRepo = ref.read(adminRepositoryProvider);
        await adminRepo.updateArticle(
          articleId: widget.article.id,
          title: title,
          content: content,
          tag: _selectedTag,
        );
        ref.invalidate(pendingArticlesProvider);
        ref.invalidate(allArticlesAdminProvider);
        ref.invalidate(adminStatsProvider);
      }

      ref.invalidate(articlesProvider);

      if (!mounted) return;

      _showSnack('Artikel berhasil di-update');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Gagal update: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
    final accent = AppColors.accent(isDark);
    final inputBg = isDark
        ? AppColors.midnightSurface
        : Colors.white.withValues(alpha: 0.68);
    final inputBorder = isDark
        ? const Color(0xFF454562)
        : const Color(0xFFEADBCA);

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
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 17,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Edit Cerita',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              'Simpan',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.midnight
                                    : Colors.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    TextField(
                      controller: _titleController,
                      maxLines: null,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: -0.8,
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Judul ceritamu...',
                        hintStyle: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          letterSpacing: -0.8,
                          color: textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: AppColors.dividerColor(isDark)),
                    const SizedBox(height: 8),
                    Text(
                      'PILIH TAG',
                      style: GoogleFonts.dmMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _tags.map((tag) {
                        final isSelected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTag = tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? accent : inputBorder,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.midnight
                                        : Colors.white)
                                    : textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ISI CERITA',
                      style: GoogleFonts.dmMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: inputBorder),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 15,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.6,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Isi cerita...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 11,
                            height: 1.6,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}