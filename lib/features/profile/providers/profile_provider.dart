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

// ===================
// FOLLOW SYSTEM PROVIDERS
// ===================
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, followingId) async {
  final supabase = ref.watch(supabaseProvider);
  final currentUserId = supabase.auth.currentUser?.id;
  if (currentUserId == null) return false;
  if (currentUserId == followingId) return false;

  final repo = ref.watch(profileRepositoryProvider);
  return repo.isFollowing(
    followerId: currentUserId,
    followingId: followingId,
  );
});

final followersCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.countFollowers(userId);
});

final followingCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.countFollowing(userId);
});

final userProfileProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfileById(userId);
});

final userArticlesProvider =
    FutureProvider.family<List<Article>, String>((ref, userId) async {
  final supabase = ref.watch(supabaseProvider);
  final data = await supabase
      .from('articles')
      .select('''
        id, author_id, title, preview, cover_url, tag, created_at, view_count,
        profiles!articles_author_id_fkey (full_name, avatar_url)
      ''')
      .eq('author_id', userId)
      .eq('status', 'published')
      .order('created_at', ascending: false);

  return (data as List).map((json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Article(
      id: json['id'] as String,
      authorId: json['author_id'] as String? ?? '',
      title: json['title'] as String,
      preview: json['preview'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      tag: json['tag'] as String? ?? '#random',
      authorName: profile?['full_name'] as String? ?? 'Anonim',
      authorAvatarUrl: profile?['avatar_url'] as String? ?? '',
      date: _formatDate(json['created_at'] as String),
      readTime: '5 min',
      views: json['view_count'] as int? ?? 0,
    );
  }).toList();
});

String _formatDate(String iso) {
  final dt = DateTime.parse(iso);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}