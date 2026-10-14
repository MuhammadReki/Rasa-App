import 'package:supabase_flutter/supabase_flutter.dart';

class InteractionRepository {
  final SupabaseClient _supabase;

  InteractionRepository(this._supabase);

  // LIKE
  Future<void> toggleLike({
    required String userId,
    required String articleId,
    required bool isLiked,
  }) async {
    if (isLiked) {
      await _supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('article_id', articleId);
    } else {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'article_id': articleId,
      });
    }
  }

  // BOOKMARK
  Future<void> toggleBookmark({
    required String userId,
    required String articleId,
    required bool isBookmarked,
  }) async {
    if (isBookmarked) {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('article_id', articleId);
    } else {
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'article_id': articleId,
      });
    }
  }

  // COMMENT
  Future<void> addComment({
    required String userId,
    required String articleId,
    required String content,
  }) async {
    await _supabase.from('comments').insert({
      'user_id': userId,
      'article_id': articleId,
      'content': content,
    });
  }
}