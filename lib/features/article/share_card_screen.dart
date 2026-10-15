import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../home/models/article.dart';
import 'widgets/share_card_widget.dart';

class ShareCardScreen extends ConsumerStatefulWidget {
  final Article article;
  const ShareCardScreen({super.key, required this.article});

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _templateIndex = 0;
  bool _isGenerating = false;

  final List<String> _templateNames = ['Minimal', 'Bold', 'Quote'];

  Future<void> _shareCard() async {
    setState(() => _isGenerating = true);

    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (bytes == null) throw Exception('Gagal capture');

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/rasa_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.article.title}\n\nBaca di Rasa 🌸',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadCard() async {
    setState(() => _isGenerating = true);

    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (bytes == null) throw Exception('Gagal capture');

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/rasa_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card disimpan: ${file.path.split('/').last}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal download: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
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
    final accent = AppColors.accent(isDark);

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
                        'Bagikan Cerita',
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

            // Preview Card
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ShareCardWidget(
                        article: widget.article,
                        templateIndex: _templateIndex,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Template Picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _templateNames.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _templateIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _templateIndex == i
                              ? accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _templateIndex == i
                                ? accent
                                : AppColors.dividerColor(isDark),
                          ),
                        ),
                        child: Text(
                          _templateNames[i],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: _templateIndex == i
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _templateIndex == i
                                ? accent
                                : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Download
                  Expanded(
                    child: GestureDetector(
                      onTap: _isGenerating ? null : _downloadCard,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dividerColor(isDark),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 18,
                              color: textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Download',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Share
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _isGenerating ? null : _shareCard,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _isGenerating
                              ? [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark
                                          ? AppColors.midnight
                                          : Colors.white,
                                    ),
                                  ),
                                ]
                              : [
                                  Icon(
                                    Icons.share_outlined,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.midnight
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bagikan Sekarang',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.midnight
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                        ),
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
}