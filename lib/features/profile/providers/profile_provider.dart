import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../home/models/article.dart';
import '../repositories/profile_repository.dart';

class ProfileData {
  final String id;
  final String? fullName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final int articleCount;

  const ProfileData({
    required this.id,
    this.fullName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.articleCount = 0,
  });

  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : 'Pengguna Baru';

  String get displayUsername =>
      (username != null && username!.isNotEmpty) ? username! : '@username';

  String get displayBio =>
      (bio != null && bio!.isNotEmpty) ? bio! : 'Bio belum diisi.';
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

final myProfileProvider = FutureProvider<ProfileData?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return null;

  final data = await supabase
      .from('profiles')
      .select('id, full_name, username, bio, avatar_url')
      .eq('id', userId)
      .maybeSingle();

  if (data == null) {
    return ProfileData(id: userId);
  }

  final articles = await supabase
      .from('articles')
      .select('id')
      .eq('author_id', userId);

  return ProfileData(
    id: userId,
    fullName: data['full_name'] as String?,
    username: data['username'] as String?,
    bio: data['bio'] as String?,
    avatarUrl: data['avatar_url'] as String?,
    articleCount: (articles as List).length,
  );
});

final myArticlesProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchMyArticles();
});

final likedArticlesProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchLikedArticles();
});

final bookmarkedArticlesProvider = FutureProvider<List<Article>>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchBookmarkedArticles();
});