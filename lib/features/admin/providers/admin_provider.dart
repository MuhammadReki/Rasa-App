import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../home/models/article.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseProvider));
});

/// Cek apakah user admin — auto-refresh saat auth berubah
final isAdminProvider = FutureProvider<bool>((ref) async {
  // Watch auth state biar auto re-check pas login/logout
  ref.watch(currentUserProvider);

  return ref.watch(adminRepositoryProvider).isAdmin();
});

/// Artikel yang perlu direview
final pendingArticlesProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchPendingArticles();
});

/// Semua artikel (admin)
final allArticlesAdminProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchAllArticles();
});

/// Stats admin
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchStats();
});