import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/providers/article_provider.dart';
import '../profile/providers/profile_provider.dart';

class SubmitStoryScreen extends ConsumerStatefulWidget {
  const SubmitStoryScreen({super.key});

  @override
  ConsumerState<SubmitStoryScreen> createState() => _SubmitStoryScreenState();
}

class _SubmitStoryScreenState extends ConsumerState<SubmitStoryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTag = '#patahhati';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _isUploadingCover = false;
  File? _pickedCover;
  String? _coverUrl;

  final List<String> _tags = [
    '#patahhati',
    '#selflove',
    '#relationship',
    '#random',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _pickedCover = File(picked.path);
        _isUploadingCover = true;
      });

      await _uploadCover();
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingCover = false);
        _showSnack('Gagal pilih gambar: $e');
      }
    }
  }

  Future<void> _uploadCover() async {
    if (_pickedCover == null) return;

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      final fileExt = _pickedCover!.path.split('.').last;
      final fileName =
          '$userId/cover_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      debugPrint('=== UPLOAD COVER ===');
      debugPrint('File: $fileName');

      await supabase.storage.from('covers').upload(
            fileName,
            _pickedCover!,
          );

      final publicUrl =
          supabase.storage.from('covers').getPublicUrl(fileName);

      debugPrint('Public URL: $publicUrl');

      if (!mounted) return;

      setState(() {
        _coverUrl = publicUrl;
        _isUploadingCover = false;
      });

      _showSnack('Cover berhasil di-upload');
    } catch (e) {
      debugPrint('=== ERROR UPLOAD COVER: $e ===');
      if (mounted) {
        setState(() {
          _isUploadingCover = false;
          _pickedCover = null;
        });
        _showSnack('Gagal upload cover: $e');
      }
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showSnack('Judul wajib diisi');
      return;
    }

    if (content.isEmpty) {
      _showSnack('Isi cerita wajib diisi');
      return;
    }

    if (content.length < 50) {
      _showSnack('Cerita minimal 50 karakter');
      return;
    }

    if (_isUploadingCover) {
      _showSnack('Tunggu upload cover selesai');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(articleRepositoryProvider);
      await repo.submitArticle(
        title: title,
        content: content,
        tag: _selectedTag,
        coverUrl: _coverUrl,
      );

      ref.invalidate(articlesProvider);
      ref.invalidate(myArticlesProvider);
      ref.invalidate(myProfileProvider);

      if (!mounted) return;

      _showSnack('Ceritamu sudah dikirim! Menunggu kurasi.');
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack('Gagal mengirim: $e');
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
            // Header
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
                        Icons.close,
                        size: 17,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Tulis Cerita',
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
                    onTap: (_isSubmitting || _isUploadingCover)
                        ? null
                        : _handleSubmit,
                    child: _isSubmitting
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
                              'Kirim',
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
                    // COVER PICKER
                    GestureDetector(
                      onTap: _isUploadingCover ? null : _pickCover,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: inputBorder),
                          image: _pickedCover != null
                              ? DecorationImage(
                                  image: FileImage(_pickedCover!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _pickedCover == null
                            ? _buildCoverPlaceholder(
                                isDark, textSecondary, accent)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedCover == null
                          ? 'Ketuk untuk pilih cover'
                          : (_isUploadingCover
                              ? 'Mengunggah cover...'
                              : 'Ketuk untuk ganti cover'),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Judul
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
                    // Tag
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
                          onTap: () =>
                              setState(() => _selectedTag = tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color:
                                    isSelected ? accent : inputBorder,
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
                    // Content
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
                        maxLines: 12,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.6,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText:
                              'Ceritakan apa yang ingin kamu bagi...\n\nTak perlu sempurna. Ceritamu pantas punya ruang.',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 11,
                            height: 1.6,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Anonymous toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: inputBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 18,
                            color: accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kirim sebagai anonim',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Namamu tidak akan muncul di cerita ini',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAnonymous,
                            onChanged: (v) =>
                                setState(() => _isAnonymous = v),
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.lavender,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: isDark
                                ? const Color(0xFF4A4A6A)
                                : const Color(0xFFD7C5B5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2535)
                            : const Color(0xFFF7EADB),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ceritamu akan melalui proses kurasi sebelum dipublikasikan. Kami menjaga ruang ini tetap aman dan hangat.',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                height: 1.5,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildCoverPlaceholder(
      bool isDark, Color textSecondary, Color accent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 24,
            color: accent,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pilih Cover',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gambar 16:9 atau 3:2',
          style: GoogleFonts.inter(
            fontSize: 9,
            color: textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}