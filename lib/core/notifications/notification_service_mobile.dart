import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'navigator_key.dart';

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

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 Permission: ${settings.authorizationStatus}');

      const androidInit =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotif.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotifTap,
      );

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

      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpened(initialMessage);
      }

      await _saveTokenToSupabase();

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _saveTokenToSupabase(token: newToken);
      });

      _initialized = true;
      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService init error: $e');
    }
  }

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

  void _onNotifTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('❌ Tap payload error: $e');
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    debugPrint('👆 Message opened: ${message.data}');
    _navigateFromData(message.data);
  }

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

  Future<void> _saveTokenToSupabase({String? token}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

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

  Future<void> refreshToken() => _saveTokenToSupabase();

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