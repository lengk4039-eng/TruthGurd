import '../../core/models/app_notification.dart';
import '../mock_data.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String id);
}

class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = [...MockData.notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = MockData.notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final n = MockData.notifications[index];
    MockData.notifications[index] = AppNotification(
      id: n.id,
      type: n.type,
      title: n.title,
      body: n.body,
      createdAt: n.createdAt,
      isRead: true,
    );
  }
}
