import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/models/article.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<List<Article>> fetchMyArticles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('articles')
        .select('''
          id, title, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  Future<List<Article>> fetchLikedArticles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('likes')
        .select('''
          article_id,
          articles!likes_article_id_fkey (
            id, title, preview, cover_url, tag, created_at, view_count,
            profiles!articles_author_id_fkey (full_name, avatar_url)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((row) {
      final article = row['articles'] as Map<String, dynamic>;
      return _mapToArticle(article);
    }).toList();
  }

  Future<List<Article>> fetchBookmarkedArticles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('bookmarks')
        .select('''
          article_id,
          articles!bookmarks_article_id_fkey (
            id, title, preview, cover_url, tag, created_at, view_count,
            profiles!articles_author_id_fkey (full_name, avatar_url)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((row) {
      final article = row['articles'] as Map<String, dynamic>;
      return _mapToArticle(article);
    }).toList();
  }

  Future<void> deleteArticle(String articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    await _supabase
        .from('articles')
        .delete()
        .eq('id', articleId)
        .eq('author_id', userId);
  }

  Future<void> updateArticle({
    required String articleId,
    required String title,
    required String content,
    required String tag,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    final preview = content.length > 150
        ? '${content.substring(0, 150)}...'
        : content;

    await _supabase
        .from('articles')
        .update({
          'title': title,
          'content': content,
          'preview': preview,
          'tag': tag,
        })
        .eq('id', articleId)
        .eq('author_id', userId);
  }

  Article _mapToArticle(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      tag: json['tag'] as String? ?? '#random',
      authorName: profile?['full_name'] as String? ?? 'Anonim',
      authorAvatarUrl: profile?['avatar_url'] as String? ?? '',
      date: _formatDate(json['created_at'] as String),
      readTime: '5 min',
      likes: 0,
      comments: 0,
      views: json['view_count'] as int? ?? 0,
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}