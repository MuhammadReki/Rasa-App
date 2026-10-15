import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

// ⚠️ Supabase Cloud Credentials
const String supabaseUrl = 'https://gevejzhwctbszwuggavl.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdldmVqemh3Y3Ric3p3dWdnYXZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIwMzgyMzcsImV4cCI6MjEwNzYxNDIzN30.X8Q43OlOK3MEdEPCqGhg57oRCQKNIvJ_wd9UKu4_-NI';

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
    debugPrint('Supabase URL: $supabaseUrl');
    debugPrint('Session exists: ${session != null}');
    debugPrint('User: ${Supabase.instance.client.auth.currentUser?.email}');
    debugPrint('=================');
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const ProviderScope(child: RasaApp()));
}