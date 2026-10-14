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
import 'widgets/auth_google_button.dart';
import 'widgets/auth_or_divider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Email dan password wajib diisi');
      return;
    }

    final success =
        await ref.read(authControllerProvider.notifier).signIn(
              email: email,
              password: password,
            );

    if (!mounted) return;

    if (success) {
      _showSnack('Login berhasil!');
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      _showSnack('Login gagal: ${error ?? "Coba lagi"}');
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
    final subColor = AppColors.textSecondary(isDark);
    final linkColor =
        isDark ? AppColors.lavender : const Color(0xFFB4694D);
    final footerColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF927562);

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
                const SizedBox(height: 20),
                const RasaLogo(fontSize: 20, showTagline: false),
                const SizedBox(height: 60),
                Text(
                  'SENANG MELIHATMU LAGI',
                  style: GoogleFonts.dmMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.3,
                    color: eyebrowColor,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  'Selamat datang\nkembali.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.02,
                    letterSpacing: -1.8,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Masuk untuk kembali ke cerita yang kamu simpan.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.6,
                      color: subColor,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                AuthTextField(
                  label: 'Email',
                  placeholder: 'namamu@email.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: 'Kata sandi',
                  placeholder: 'Masukkan kata sandi',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Lupa kata sandi?',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: linkColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : AuthPrimaryButton(
                        label: 'Masuk',
                        icon: Icons.arrow_forward,
                        onPressed: _handleLogin,
                      ),
                const SizedBox(height: 16),
                const AuthOrDivider(),
                const SizedBox(height: 16),
                AuthGoogleButton(onPressed: () {}),
                const SizedBox(height: 40),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: footerColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Daftar',
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