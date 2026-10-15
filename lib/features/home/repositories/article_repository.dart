import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';

class ArticleRepository {
  final SupabaseClient _supabase;

  ArticleRepository(this._supabase);

  Future<List<Article>> fetchPublishedArticles({String? tag}) async {
    var query = _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('status', 'published');

    if (tag != null && tag != 'Untukmu') {
      query = query.eq('tag', tag);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  Future<Article?> fetchArticleById(String id) async {
    final data = await _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    try {
      await _supabase.rpc('increment_view_count',
          params: {'article_id': id});
    } catch (_) {}

    return _mapToArticle(data);
  }

  Future<List<Article>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];

    final data = await _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('status', 'published')
        .or('title.ilike.%$query%,preview.ilike.%$query%,content.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTrendingTags() async {
    final data = await _supabase
        .from('articles')
        .select('tag')
        .eq('status', 'published');

    final counts = <String, int>{};
    for (final row in (data as List)) {
      final tag = row['tag'] as String? ?? '#random';
      counts[tag] = (counts[tag] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(3)
        .map((e) => {'tag': e.key, 'count': e.value})
        .toList();
  }

  Future<String?> submitArticle({
    required String title,
    required String content,
    required String tag,
    String? coverUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    final preview = content.length > 150
        ? '${content.substring(0, 150)}...'
        : content;

    final result = await _supabase.from('articles').insert({
      'author_id': userId,
      'title': title,
      'content': content,
      'preview': preview,
      'cover_url': coverUrl ?? _randomCover(),
      'tag': tag,
      'status': 'pending',
    }).select('id').single();

    return result['id'] as String?;
  }

  Future<List<Article>> fetchMyArticles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  Article _mapToArticle(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final content = json['content'] as String? ?? '';
    final wordCount =
        content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final readMinutes = (wordCount / 200).ceil();

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
      readTime: '${readMinutes < 1 ? 1 : readMinutes} min',
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

  String _randomCover() {
    const covers = [
      'https://images.pexels.com/photos/8924253/pexels-photo-8924253.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/5426883/pexels-photo-5426883.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/6788788/pexels-photo-6788788.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/13735945/pexels-photo-13735945.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/4639031/pexels-photo-4639031.jpeg?auto=compress&cs=tinysrgb&w=800',
    ];
    return covers[DateTime.now().millisecond % covers.length];
  }
}