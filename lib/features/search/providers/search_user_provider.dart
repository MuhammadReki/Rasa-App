import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../home/models/user_profile.dart';
import '../../home/providers/article_provider.dart';

/// Query user by full_name atau username
final searchUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final supabase = ref.watch(supabaseProvider);

  final data = await supabase
      .from('profiles')
      .select('id, full_name, username, avatar_url, bio')
      .or('full_name.ilike.%$query%,username.ilike.%$query%')
      .limit(30);

  return (data as List)
      .map((json) => UserProfile.fromJson(json as Map<String, dynamic>))
      .toList();
});

/// Tab search: 0 = Artikel, 1 = User
final searchTabProvider = StateProvider<int>((ref) => 0);