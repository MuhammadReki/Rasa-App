import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/supabase/supabase_client.dart';

/// Current user (reactive)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => ref.watch(supabaseProvider).auth.currentUser,
    error: (_, __) => null,
  );
});

/// Auth state changes stream
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

/// Auth controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.data(null));

  SupabaseClient get _supabase => ref.read(supabaseProvider);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // ✅ Init + simpen FCM token ke Supabase
      try {
        await NotificationService.instance.initialize();
        await NotificationService.instance.refreshToken();
      } catch (e) {
        print('⚠️ Notification init error: $e');
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': '@${fullName.toLowerCase().replaceAll(' ', '')}',
        },
      );

      // ✅ Init + simpen FCM token ke Supabase (kalau udah ada session)
      try {
        if (_supabase.auth.currentUser != null) {
          await NotificationService.instance.initialize();
          await NotificationService.instance.refreshToken();
        }
      } catch (e) {
        print('⚠️ Notification init error: $e');
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    // ✅ Hapus FCM token dari Supabase sebelum logout
    try {
      await NotificationService.instance.deleteToken();
    } catch (e) {
      print('⚠️ Delete token error: $e');
    }

    await _supabase.auth.signOut();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});