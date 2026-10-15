import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/providers/auth_provider.dart';
import '../admin/providers/admin_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(authControllerProvider.notifier).signOut();

    if (mounted) {
      context.go('/login');
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
    final dividerColor = AppColors.dividerColor(isDark);

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
                    onTap: () => context.go('/profile'),
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
                        'Pengaturan',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupLabel('PREFERENSI', textSecondary),
                    _buildToggleRow(
                      icon: Icons.nightlight_outlined,
                      label: 'Mode gelap',
                      value: isDark,
                      onChanged: (v) {
                        ref.read(themeProvider.notifier).toggleDarkMode(v);
                      },
                      textPrimary: textPrimary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    _buildToggleRow(
                      icon: Icons.notifications_none,
                      label: 'Notifikasi',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                      textPrimary: textPrimary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    _buildClickRow(
                      icon: Icons.language,
                      label: 'Bahasa',
                      trailing: 'Indonesia',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildGroupLabel('TENTANG & PRIVASI', textSecondary),
                    _buildClickRow(
                      icon: Icons.info_outline,
                      label: 'Tentang Rasa',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    _buildClickRow(
                      icon: Icons.shield_outlined,
                      label: 'Kebijakan Privasi',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    _buildClickRow(
                      icon: Icons.description_outlined,
                      label: 'Syarat & Ketentuan',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // ===================
                    // ADMIN PANEL (cuma muncul kalau admin)
                    // ===================
                    Consumer(
                      builder: (context, ref, _) {
                        final isAdminAsync = ref.watch(isAdminProvider);
                        return isAdminAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (err, _) {
                            debugPrint('🔍 SETTINGS - ERROR: $err');
                            return const SizedBox.shrink();
                          },
                          data: (isAdmin) {
                            debugPrint('🔍 SETTINGS - isAdmin = $isAdmin');
                            if (!isAdmin) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGroupLabel('ADMIN', textSecondary),
                                _buildClickRow(
                                  icon: Icons.admin_panel_settings,
                                  label: 'Admin Panel',
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  dividerColor: dividerColor,
                                  isDark: isDark,
                                  onTap: () => context.push('/admin'),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // ===================
                    // LOGOUT
                    // ===================
                    GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3E2A35)
                              : const Color(0xFFF8E7E3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 17,
                              color: isDark
                                  ? const Color(0xFFE8A99E)
                                  : const Color(0xFFBB6154),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Keluar dari akun',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFE8A99E)
                                    : const Color(0xFFBB6154),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Rasa 1.0.0 · dibuat dengan sepenuh hati',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: textSecondary,
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

  Widget _buildGroupLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 13, 0, 5),
      child: Text(
        label,
        style: GoogleFonts.dmMono(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.4,
          color: color,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textPrimary,
    required Color dividerColor,
    required bool isDark,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          _buildIconBox(icon, isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.lavender,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? const Color(0xFF4A4A6A)
                : const Color(0xFFD7C5B5),
          ),
        ],
      ),
    );
  }

  Widget _buildClickRow({
    required IconData icon,
    required String label,
    String? trailing,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            _buildIconBox(icon, isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: textSecondary,
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, bool isDark) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A2E45) : const Color(0xFFF6E8DE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 17,
        color: isDark ? AppColors.lavender : const Color(0xFFB4694D),
      ),
    );
  }
}