import 'package:supabase_flutter/supabase_flutter.dart';

class InteractionRepository {
  final SupabaseClient _supabase;

  InteractionRepository(this._supabase);

  // ===================
  // LIKE
  // ===================
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

  // ===================
  // BOOKMARK ARTIKEL
  // ===================
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

  // ===================
  // COMMENT
  // ===================
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

  Future<void> addReply({
    required String userId,
    required String articleId,
    required String parentId,
    required String content,
  }) async {
    await _supabase.from('comments').insert({
      'user_id': userId,
      'article_id': articleId,
      'parent_id': parentId,
      'content': content,
    });
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    await _supabase
        .from('comments')
        .update({'content': content})
        .eq('id', commentId)
        .eq('user_id', userId);
  }

  Future<void> deleteComment(String commentId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    await _supabase
        .from('comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', userId);
  }

  // ===================
  // BOOKMARK KOMENTAR
  // ===================
  Future<bool> isCommentBookmarked({
    required String userId,
    required String commentId,
  }) async {
    final data = await _supabase
        .from('comment_bookmarks')
        .select('id')
        .eq('user_id', userId)
        .eq('comment_id', commentId)
        .maybeSingle();
    return data != null;
  }

  Future<void> toggleCommentBookmark({
    required String userId,
    required String commentId,
    required bool isBookmarked,
  }) async {
    if (isBookmarked) {
      await _supabase
          .from('comment_bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('comment_id', commentId);
    } else {
      await _supabase.from('comment_bookmarks').insert({
        'user_id': userId,
        'comment_id': commentId,
      });
    }
  }

  // ===================
  // REPORT
  // ===================
  Future<void> submitReport({
    required String reporterId,
    String? articleId,
    String? commentId,
    required String reason,
  }) async {
    await _supabase.from('reports').insert({
      'reporter_id': reporterId,
      if (articleId != null) 'article_id': articleId,
      if (commentId != null) 'comment_id': commentId,
      'reason': reason,
    });
  }

  // ===================
  // BLOCK
  // ===================
  Future<bool> isBlocked({
    required String blockerId,
    required String blockedId,
  }) async {
    final data = await _supabase
        .from('blocks')
        .select('id')
        .eq('blocker_id', blockerId)
        .eq('blocked_id', blockedId)
        .maybeSingle();
    return data != null;
  }

  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    await _supabase.from('blocks').insert({
      'blocker_id': blockerId,
      'blocked_id': blockedId,
    });
  }

  Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    await _supabase
        .from('blocks')
        .delete()
        .eq('blocker_id', blockerId)
        .eq('blocked_id', blockedId);
  }

  Future<List<String>> fetchBlockedUserIds(String blockerId) async {
    final data = await _supabase
        .from('blocks')
        .select('blocked_id')
        .eq('blocker_id', blockerId);
    return (data as List)
        .map((row) => row['blocked_id'] as String)
        .toList();
  }
}