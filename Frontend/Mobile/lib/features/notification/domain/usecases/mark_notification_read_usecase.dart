import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final INotificationRepository _repository;

  Future<void> call(int notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
