part of 'notification_cubit.dart';

class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  final List<NotificationModel> todayNotifications;
  final List<NotificationModel> weekNotifications;

  NotificationLoaded({
    required this.todayNotifications,
    required this.weekNotifications,
  });
}

final class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}
