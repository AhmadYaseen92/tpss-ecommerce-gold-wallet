import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final INotificationRepository _repository;

  Future<List<NotificationEntity>> call({
    int pageNumber = 1,
    int pageSize = 50,
  }) {
    return _repository.getNotifications(pageNumber: pageNumber, pageSize: pageSize);
  }
}
