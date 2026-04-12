import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    int pageNumber = 1,
    int pageSize = 50,
  });

  Future<void> markAsRead(int notificationId);
}
