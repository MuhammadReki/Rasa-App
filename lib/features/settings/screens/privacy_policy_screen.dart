import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

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
                        'Kebijakan Privasi',
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
                      'Kebijakan Privasi',
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
                      '1. Informasi yang Kami Kumpulkan',
                      'Kami mengumpulkan informasi yang kamu berikan secara langsung, seperti nama, email, dan konten cerita yang kamu bagikan. Kami juga mengumpulkan data penggunaan untuk meningkatkan layanan.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '2. Bagaimana Kami Menggunakan Informasi',
                      'Informasi kamu digunakan untuk:\n• Menyediakan layanan Rasa\n• Meningkatkan pengalaman pengguna\n• Mengirim notifikasi terkait aktivitas\n• Menjaga keamanan platform',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '3. Berbagi Informasi',
                      'Kami tidak menjual data kamu ke pihak ketiga. Kami hanya membagikan informasi jika diwajibkan oleh hukum atau untuk melindungi hak dan keamanan pengguna.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '4. Keamanan Data',
                      'Kami menggunakan enkripsi dan praktik keamanan standar industri untuk melindungi data kamu. Namun, tidak ada metode transmisi internet yang 100% aman.',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '5. Hak Kamu',
                      'Kamu berhak untuk:\n• Mengakses data pribadimu\n• Memperbaiki data yang tidak akurat\n• Menghapus akun dan datamu\n• Menarik persetujuan kapan saja',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildSection(
                      '6. Hubungi Kami',
                      'Jika ada pertanyaan tentang kebijakan privasi ini, hubungi kami di:\n📧 privacy@rasa.app',
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