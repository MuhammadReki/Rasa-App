import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import 'providers/profile_provider.dart';  // ← TAMBAHAN

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  String? _avatarUrl;
  File? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    try {
      final supabase = ref.read(supabaseProvider);
      final currentUser = supabase.auth.currentUser;
      final session = supabase.auth.currentSession;

      debugPrint('========== DEBUG AUTH ==========');
      debugPrint('User ID: ${currentUser?.id}');
      debugPrint('Email: ${currentUser?.email}');
      debugPrint('Session exists: ${session != null}');
      debugPrint('=================================');

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _errorMessage = 'User tidak login. Silakan logout & login ulang.';
          });
        }
        return;
      }

      final data = await supabase
          .from('profiles')
          .select('full_name, username, bio, avatar_url')
          .eq('id', currentUser.id)
          .maybeSingle();

      debugPrint('Data profile: $data');

      if (!mounted) return;

      setState(() {
        _nameController.text = (data?['full_name'] as String?) ?? '';
        _usernameController.text = (data?['username'] as String?) ?? '';
        _bioController.text = (data?['bio'] as String?) ?? '';
        _avatarUrl = data?['avatar_url'] as String?;
        _isInitialized = true;
      });
    } catch (e, st) {
      debugPrint('Error load profile: $e');
      debugPrint('StackTrace: $st');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _pickedImage = File(picked.path);
        _isUploadingImage = true;
      });

      await _uploadAvatar();
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal pilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (_pickedImage == null) return;

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      final fileExt = _pickedImage!.path.split('.').last;
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      debugPrint('=== UPLOAD AVATAR ===');
      debugPrint('File: $fileName');

      await supabase.storage.from('avatars').upload(
            fileName,
            _pickedImage!,
          );

      final publicUrl =
          supabase.storage.from('avatars').getPublicUrl(fileName);

      debugPrint('Public URL: $publicUrl');

      final existing = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'avatar_url': publicUrl,
        });
      } else {
        await supabase.from('profiles').update({
          'avatar_url': publicUrl,
        }).eq('id', userId);
      }

      // ← TAMBAHAN: refresh profile provider
      ref.invalidate(myProfileProvider);

      if (!mounted) return;

      setState(() {
        _avatarUrl = publicUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diubah')),
      );
    } catch (e) {
      debugPrint('=== ERROR UPLOAD: $e ===');
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _pickedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      final usernameClean =
          username.startsWith('@') ? username : '@$username';

      final existing = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'full_name': name,
          'username': usernameClean,
          'bio': bio,
          'avatar_url': _avatarUrl,
        });
      } else {
        await supabase.from('profiles').update({
          'full_name': name,
          'username': usernameClean,
          'bio': bio,
        }).eq('id', userId);
      }

      // ← TAMBAHAN: refresh profile provider
      ref.invalidate(myProfileProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan')),
      );
      context.go('/profile');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
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
                        'Edit Profil',
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
                    onTap: (_isLoading ||
                            !_isInitialized ||
                            _isUploadingImage)
                        ? null
                        : _handleSave,
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Text(
                            'Simpan',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isInitialized
                                  ? accent
                                  : textSecondary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !_isInitialized
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: accent),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat profil...',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF3E2A35)
                                    : const Color(0xFFF5E3DF),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: Color(0xFFC96961),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: const Color(0xFFC96961),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          GestureDetector(
                            onTap: _isUploadingImage ? null : _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _buildAvatar(isDark),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: bg, width: 2),
                                    ),
                                    child: _isUploadingImage
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.all(7),
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: isDark
                                                  ? AppColors.midnight
                                                  : Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt,
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
                          const SizedBox(height: 10),
                          Text(
                            _isUploadingImage
                                ? 'Mengunggah foto...'
                                : 'Ketuk untuk ganti foto',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildLabel('Nama', textPrimary),
                          const SizedBox(height: 7),
                          _buildField(
                            controller: _nameController,
                            placeholder: 'Namamu',
                            icon: Icons.person_outline,
                            inputBg: inputBg,
                            inputBorder: inputBorder,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Username', textPrimary),
                          const SizedBox(height: 7),
                          _buildField(
                            controller: _usernameController,
                            placeholder: '@username',
                            icon: Icons.alternate_email,
                            inputBg: inputBg,
                            inputBorder: inputBorder,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Bio', textPrimary),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: inputBorder),
                            ),
                            child: TextField(
                              controller: _bioController,
                              maxLines: 4,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Ceritakan tentang dirimu...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: textSecondary,
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

  Widget _buildAvatar(bool isDark) {
    if (_pickedImage != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_pickedImage!),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor:
          isDark ? AppColors.midnightSurface : const Color(0xFFF0E4D6),
      child: Icon(
        Icons.person,
        size: 50,
        color: isDark ? AppColors.lavender : AppColors.terracotta,
      ),
    );
  }

  Widget _buildLabel(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required Color inputBg,
    required Color inputBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: inputBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(fontSize: 11, color: textPrimary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: GoogleFonts.inter(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}