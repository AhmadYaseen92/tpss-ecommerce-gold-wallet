part of 'notification_cubit.dart';

sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  NotificationLoaded({
    required this.todayNotifications,
    required this.weekNotifications,
  });

  final List<NotificationEntity> todayNotifications;
  final List<NotificationEntity> weekNotifications;
}

final class NotificationError extends NotificationState {
  NotificationError(this.message);

  final String message;
}
