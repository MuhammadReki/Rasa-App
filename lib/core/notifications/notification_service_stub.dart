/// Stub — dipake kalau platform gak dikenali
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {}
  Future<void> refreshToken() async {}
  Future<void> deleteToken() async {}
}