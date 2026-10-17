import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);

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
                        Icons.arrow_back,
                        size: 17,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Syarat & Ketentuan',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Syarat & Ketentuan',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terakhir diperbarui: 17 Oktober 2026',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '1. Penerimaan Syarat',
                      'Dengan menggunakan Rasa, kamu menyetujui syarat dan ketentuan ini. Jika tidak setuju, mohon untuk tidak menggunakan layanan kami.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '2. Akun Pengguna',
                      'Kamu bertanggung jawab untuk:\n• Menjaga kerahasiaan password\n• Semua aktivitas di akunmu\n• Memberikan informasi yang akurat\n• Tidak menggunakan akun untuk hal ilegal',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '3. Konten Pengguna',
                      'Kamu mempertahankan hak atas konten yang kamu bagikan. Namun, kamu memberi kami lisensi untuk menampilkan konten tersebut di platform Rasa.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '4. Konten yang Dilarang',
                      'Dilarang membagikan konten yang:\n• Mengandung kebencian\n• Bersifat SARA\n• Mengancam atau melecehkan\n• Melanggar hak cipta\n• Mengandung spam',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '5. Moderasi Konten',
                      'Kami berhak untuk menghapus konten yang melanggar aturan tanpa pemberitahuan. Pelanggaran berulang dapat menyebabkan pemblokiran akun.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '6. Penghentian Layanan',
                      'Kami berhak untuk menghentikan atau mengubah layanan kapan saja, dengan atau tanpa pemberitahuan.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '7. Hubungi Kami',
                      'Jika ada pertanyaan tentang syarat ini, hubungi kami di:\n📧 legal@rasa.app',
                      textPrimary,
                      textSecondary,
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

  Widget _buildSection(
    String title,
    String content,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.7,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}