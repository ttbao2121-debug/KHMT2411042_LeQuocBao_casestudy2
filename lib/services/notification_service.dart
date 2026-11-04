import '../models/notification.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  String? get _token => _authService.token;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final res = await _apiClient.get('/notifications', token: _token);
      final rawList = (res['data'] ?? res) as List<dynamic>;
      return rawList.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch('/notifications/$notificationId/read', {}, token: _token);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/notifications/read-all', {}, token: _token);
    } catch (_) {}
  }
}
