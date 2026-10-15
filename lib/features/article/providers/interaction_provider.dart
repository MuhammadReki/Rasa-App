import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';

/// LIKE
final isLikedProvider =
    FutureProvider.family<bool, String>((ref, articleId) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;

  final data = await supabase
      .from('likes')
      .select('id')
      .eq('user_id', userId)
      .eq('article_id', articleId)
      .maybeSingle();

  return data != null;
});

final likeCountProvider =
    FutureProvider.family<int, String>((ref, articleId) async {
  final supabase = ref.watch(supabaseProvider);
  final data = await supabase
      .from('likes')
      .select('id')
      .eq('article_id', articleId);
  return (data as List).length;
});

/// BOOKMARK
final isBookmarkedProvider =
    FutureProvider.family<bool, String>((ref, articleId) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;

  final data = await supabase
      .from('bookmarks')
      .select('id')
      .eq('user_id', userId)
      .eq('article_id', articleId)
      .maybeSingle();

  return data != null;
});

/// COMMENTS
final commentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, articleId) async {
  final supabase = ref.watch(supabaseProvider);
  final data = await supabase
      .from('comments')
      .select('''
        id, content, created_at, user_id,
        profiles!comments_user_id_fkey (full_name, avatar_url)
      ''')
      .eq('article_id', articleId)
      .isFilter('parent_id', null)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data);
});

final commentCountProvider =
    FutureProvider.family<int, String>((ref, articleId) async {
  final supabase = ref.watch(supabaseProvider);
  final data = await supabase
      .from('comments')
      .select('id')
      .eq('article_id', articleId);
  return (data as List).length;
});

/// REPLIES
final commentRepliesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, parentId) async {
  final supabase = ref.watch(supabaseProvider);
  final data = await supabase
      .from('comments')
      .select('''
        id, content, created_at, user_id,
        profiles!comments_user_id_fkey (full_name, avatar_url)
      ''')
      .eq('parent_id', parentId)
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(data);
});

/// BOOKMARK KOMENTAR
final isCommentBookmarkedProvider =
    FutureProvider.family<bool, String>((ref, commentId) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;

  final data = await supabase
      .from('comment_bookmarks')
      .select('id')
      .eq('user_id', userId)
      .eq('comment_id', commentId)
      .maybeSingle();
  return data != null;
});