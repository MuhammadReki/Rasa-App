import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/models/article.dart';

class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository(this._supabase);

  /// Cek apakah user saat ini adalah admin
  Future<bool> isAdmin() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return data?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// Fetch artikel yang perlu direview (status: pending)
  Future<List<Article>> fetchPendingArticles() async {
    final data = await _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  /// Fetch semua artikel (untuk admin overview)
  Future<List<Article>> fetchAllArticles() async {
    final data = await _supabase
        .from('articles')
        .select('''
          id, author_id, title, content, preview, cover_url, tag, created_at, view_count, status,
          profiles!articles_author_id_fkey (full_name, avatar_url)
        ''')
        .order('created_at', ascending: false)
        .limit(100);

    return (data as List).map((json) => _mapToArticle(json)).toList();
  }

  /// Approve artikel (pending → published)
  Future<void> approveArticle(String articleId) async {
    await _supabase
        .from('articles')
        .update({'status': 'published'})
        .eq('id', articleId);
  }

  /// Reject artikel (pending → rejected)
  Future<void> rejectArticle(String articleId) async {
    await _supabase
        .from('articles')
        .update({'status': 'rejected'})
        .eq('id', articleId);
  }

  /// Delete artikel (admin)
  Future<void> deleteArticle(String articleId) async {
    await _supabase.from('articles').delete().eq('id', articleId);
  }

  /// Update artikel (admin) — edit title, content, tag
  Future<void> updateArticle({
    required String articleId,
    required String title,
    required String content,
    required String tag,
  }) async {
    final preview = content.length > 150
        ? '${content.substring(0, 150)}...'
        : content;

    await _supabase.from('articles').update({
      'title': title,
      'content': content,
      'preview': preview,
      'tag': tag,
    }).eq('id', articleId);
  }

  /// Stats untuk dashboard admin
  Future<Map<String, int>> fetchStats() async {
    final pending = await _supabase
        .from('articles')
        .select('id')
        .eq('status', 'pending');

    final published = await _supabase
        .from('articles')
        .select('id')
        .eq('status', 'published');

    final users = await _supabase.from('profiles').select('id');

    return {
      'pending': (pending as List).length,
      'published': (published as List).length,
      'users': (users as List).length,
    };
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