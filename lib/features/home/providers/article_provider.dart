import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/article.dart';
import '../repositories/article_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.watch(supabaseProvider));
});

final selectedTagProvider = StateProvider<String>((ref) => 'Untukmu');

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  final tag = ref.watch(selectedTagProvider);
  return repo.fetchPublishedArticles(tag: tag);
});

final articleDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.fetchArticleById(id);
});

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results
final searchResultsProvider = FutureProvider<List<Article>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(articleRepositoryProvider);
  return repo.searchArticles(query);
});

/// Trending tags
final trendingTagsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.fetchTrendingTags();
});

// ⚠️ myArticlesProvider DIHAPUS dari sini.
// Sudah dipindahin ke lib/features/profile/providers/profile_provider.dart
// Biar gak konflik nama.