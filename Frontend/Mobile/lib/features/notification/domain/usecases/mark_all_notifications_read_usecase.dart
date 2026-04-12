import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final INotificationRepository _repository;

  Future<void> call(List<NotificationEntity> notifications) async {
    final unread = notifications.where((item) => !item.isRead);
    for (final notification in unread) {
      await _repository.markAsRead(notification.id);
    }
  }
}
