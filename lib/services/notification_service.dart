import '../models/notification.dart';

class NotificationService {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      userId: 'u1',
      title: 'Công việc mới được giao',
      message: 'Bạn được giao công việc "Thiết kế UI màn hình Đăng nhập".',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'n2',
      userId: 'u1',
      title: 'Nhắc nhở hạn chót',
      message: 'Công việc "Xây dựng cấu trúc thư mục" sắp đến hạn chót.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_notifications);
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final old = _notifications[index];
      _notifications[index] = AppNotification(
        id: old.id,
        userId: old.userId,
        title: old.title,
        message: old.message,
        isRead: true,
        createdAt: old.createdAt,
      );
    }
  }
}
