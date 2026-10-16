import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // 1. Init Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  // 2. Init Supabase
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
    debugPrint('❌ Supabase init error: $e');
  }

  // 3. Init Notification Service
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await NotificationService.instance.initialize();
      debugPrint('✅ Notification service ready');
    } else {
      debugPrint('⚠️ Skip notif init — user not logged in');
    }
  } catch (e) {
    debugPrint('❌ Notification init error: $e');
  }

  runApp(const ProviderScope(child: RasaApp()));
}