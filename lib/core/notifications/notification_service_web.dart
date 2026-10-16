import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    debugPrint('ℹ️ NotificationService: web platform — skip FCM');
  }

  Future<void> refreshToken() async {}

  Future<void> deleteToken() async {}
}