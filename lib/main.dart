import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

const String supabaseUrl = 'http://localhost:54321';
const String supabaseAnonKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('=== MAIN INIT ===');
    debugPrint('Session exists: ${session != null}');
    debugPrint('User: ${Supabase.instance.client.auth.currentUser?.email}');
    debugPrint('=================');
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const ProviderScope(child: RasaApp()));
}