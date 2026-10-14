import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Seseorang menyukai ceritamu',
      'subtitle': '"Kita tidak harus kuat setiap hari"',
      'time': '2 jam lalu',
      'icon': Icons.favorite,
      'color': Color(0xFFC97B7B),
      'read': false,
    },
    {
      'title': 'Komentar baru',
      'subtitle': 'Nadine: "Terima kasih sudah menulis ini."',
      'time': '4 jam lalu',
      'icon': Icons.chat_bubble,
      'color': Color(0xFF8FA88F),
      'read': false,
    },
    {
      'title': 'Pengguna baru mengikuti kamu',
      'subtitle': 'Rani Maharani mulai mengikuti',
      'time': '1 hari lalu',
      'icon': Icons.person_add,
      'color': Color(0xFFA084CA),
      'read': true,
    },
    {
      'title': 'Cerita baru untuk kamu',
      'subtitle': '"Ritual kecil untuk mencintai diri sendiri"',
      'time': '2 hari lalu',
      'icon': Icons.auto_stories,
      'color': Color(0xFFB4694D),
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimary(isDark);
    final textSecondary = AppColors.textSecondary(isDark);
    final border = AppColors.dividerColor(isDark);

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
                    onTap: () => context.go('/home'),
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
                        'Notifikasi',
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
              child: _notifications.isEmpty
                  ? _buildEmptyState(textPrimary, textSecondary)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: border),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _buildItem(
                          notif,
                          textPrimary,
                          textSecondary,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    Map<String, dynamic> notif,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isRead = notif['read'] as bool;
    final color = notif['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notif['icon'] as IconData,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC97B5A),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif['subtitle'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif['time'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 48,
              color: textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini.',
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
}