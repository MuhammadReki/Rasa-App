import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../splash/widgets/rasa_logo.dart';
import 'providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Semua field wajib diisi');
      return;
    }

    if (password != confirm) {
      _showSnack('Password tidak sama');
      return;
    }

    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter');
      return;
    }

    if (!_agreedToTerms) {
      _showSnack('Setujui Syarat & Ketentuan dulu');
      return;
    }

    final success =
        await ref.read(authControllerProvider.notifier).signUp(
              email: email,
              password: password,
              fullName: name,
            );

    if (!mounted) return;

    if (success) {
      _showSnack('Registrasi sukses! Selamat datang.');
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      _showSnack('Registrasi gagal: ${error ?? "Coba lagi"}');
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
    final isLoading = ref.watch(authControllerProvider).isLoading;

    final bgColors = isDark
        ? const [
            AppColors.midnight,
            Color(0xFF1F1F35),
            Color(0xFF2A2040),
          ]
        : const [
            Color(0xFFFAF3E0),
            Color(0xFFFCF8F0),
            Color(0xFFF8E8DF),
          ];

    final eyebrowColor =
        isDark ? AppColors.lavender : const Color(0xFFB4694D);
    final titleColor = AppColors.textPrimary(isDark);
    final linkColor =
        isDark ? AppColors.lavender : const Color(0xFFB4694D);
    final footerColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF927562);
    final counterColor = isDark
        ? const Color(0xFF89899F)
        : const Color(0xFFA88977);
    final agreementColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF8C7060);
    final checkboxBorderColor = isDark
        ? const Color(0xFF454562)
        : const Color(0xFFD5BFB0);
    final checkboxActiveColor =
        isDark ? AppColors.lavender : AppColors.terracotta;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const RasaLogo(fontSize: 20, showTagline: false),
                    Text(
                      '1 dari 1',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: counterColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Text(
                  'MARI MULAI PERLAHAN',
                  style: GoogleFonts.dmMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.3,
                    color: eyebrowColor,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  'Buat ruangmu\ndi sini.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.02,
                    letterSpacing: -1.8,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 26),
                AuthTextField(
                  label: 'Nama',
                  placeholder: 'Namamu',
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 11),
                AuthTextField(
                  label: 'Email',
                  placeholder: 'namamu@email.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 11),
                AuthTextField(
                  label: 'Kata sandi',
                  placeholder: 'Minimal 6 karakter',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 11),
                AuthTextField(
                  label: 'Konfirmasi kata sandi',
                  placeholder: 'Ulangi kata sandi',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmController,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                          () => _agreedToTerms = !_agreedToTerms),
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? checkboxActiveColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _agreedToTerms
                                ? checkboxActiveColor
                                : checkboxBorderColor,
                            width: 1,
                          ),
                        ),
                        child: _agreedToTerms
                            ? Icon(
                                Icons.check,
                                size: 11,
                                color: isDark
                                    ? AppColors.midnight
                                    : Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Saya setuju dengan ',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: agreementColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Syarat & Ketentuan',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: linkColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : AuthPrimaryButton(
                        label: 'Daftar',
                        icon: Icons.arrow_forward,
                        onPressed: _handleRegister,
                      ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: footerColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Masuk',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: linkColor,
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
      ),
    );
  }
}