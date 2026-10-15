import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handler buat background message (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'rasa_default_channel';
  static const String _channelName = 'Rasa Notifications';
  static const String _channelDesc = 'Notifikasi dari Rasa';

  /// Init semua — Firebase Messaging + Local Notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Request permission (Android 13+)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 Permission: ${settings.authorizationStatus}');

      // 2. Setup local notifications (buat foreground)
      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotif.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotifTap,
      );

      // 3. Bikin channel Android
      if (Platform.isAndroid) {
        await _localNotif
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                _channelName,
                description: _channelDesc,
                importance: Importance.high,
                playSound: true,
              ),
            );
      }

      // 4. Handle background message
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      // 5. Handle foreground message
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // 6. Handle tap notif pas app kebuka dari background
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      // 7. Cek initial message (app kebuka dari terminated state)
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpened(initialMessage);
      }

      // 8. Simpen FCM token ke Supabase
      await _saveTokenToSupabase();

      // 9. Listen token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _saveTokenToSupabase(token: newToken);
      });

      _initialized = true;
      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService init error: $e');
    }
  }

  /// Handle foreground message — tampilin pake local notif
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('📩 Foreground message: ${message.messageId}');

    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle tap notif
  void _onNotifTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('❌ Tap payload error: $e');
    }
  }

  /// Handle message opened (dari background / terminated)
  void _onMessageOpened(RemoteMessage message) {
    debugPrint('👆 Message opened: ${message.data}');
    _navigateFromData(message.data);
  }

  /// Navigate berdasarkan tipe notif
  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final articleId = data['article_id'] as String?;
    final actorId = data['actor_id'] as String?;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'follow' && actorId != null) {
      Navigator.of(context).pushNamed('/user/$actorId');
    } else if (articleId != null) {
      Navigator.of(context).pushNamed('/article/$articleId');
    }
  }

  /// Simpen FCM token ke Supabase
  Future<void> _saveTokenToSupabase({String? token}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in — skip save token');
        return;
      }

      final fcmToken =
          token ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        debugPrint('⚠️ FCM token null');
        return;
      }

      await Supabase.instance.client.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': fcmToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      debugPrint('✅ FCM token saved: ${fcmToken.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ Save token error: $e');
    }
  }

  /// Public — call pas user login
  Future<void> refreshToken() => _saveTokenToSupabase();

  /// Public — hapus token pas logout
  Future<void> deleteToken() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId);

      await FirebaseMessaging.instance.deleteToken();
      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Delete token error: $e');
    }
  }
}

/// Global navigator key — biar bisa navigate dari notif handler
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();