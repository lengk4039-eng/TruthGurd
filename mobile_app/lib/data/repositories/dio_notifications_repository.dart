import '../../core/models/app_notification.dart';
import '../../core/network/api_client.dart';
import 'notifications_repository.dart';

class DioNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> getNotifications() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/notifications/me');
      return (response.data as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> markAsRead(String id) {
    return unwrapDioErrors(
      () => ApiClient.instance.post('/notifications/$id/read'),
    );
  }
}
