import 'package:tpss_ecommerce_gold_wallet/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationEntity>> getNotifications({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final remoteItems = await _remoteDataSource.getNotifications(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return remoteItems
        .map(
          (item) => NotificationEntity(
            id: item.id,
            title: item.title,
            body: item.body,
            createdAt: item.createdAtUtc.toLocal(),
            isRead: item.isRead,
          ),
        )
        .toList();
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }
}
