import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  const GetUnreadNotificationsCountUseCase(this._repository);

  final INotificationRepository _repository;

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}
