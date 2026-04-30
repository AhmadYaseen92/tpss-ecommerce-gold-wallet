import 'package:bloc/bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/usecases/mark_notification_read_usecase.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markNotificationReadUseCase = markNotificationReadUseCase,
       _markAllNotificationsReadUseCase = markAllNotificationsReadUseCase,
       super(NotificationInitial());

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;

  List<NotificationEntity> _allNotifications = [];

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      _allNotifications = await _getNotificationsUseCase(pageNumber: 1, pageSize: 100);
      _emitLoaded();
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${ApiErrorParser.friendlyFromAny(e)}'));
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final hasUnread = _allNotifications.any((item) => item.id == notificationId && !item.isRead);
    if (!hasUnread) {
      return;
    }

    try {
      await _markNotificationReadUseCase(notificationId);
      _allNotifications = _allNotifications
          .map((item) => item.id == notificationId ? item.copyWith(isRead: true) : item)
          .toList();
      _emitLoaded();
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: ${ApiErrorParser.friendlyFromAny(e)}'));
      _emitLoaded();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _markAllNotificationsReadUseCase(_allNotifications);
      _allNotifications = _allNotifications.map((item) => item.copyWith(isRead: true)).toList();
      _emitLoaded();
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: ${ApiErrorParser.friendlyFromAny(e)}'));
      _emitLoaded();
    }
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _emitLoaded() {
    final now = DateTime.now();
    final todayNotifications = <NotificationEntity>[];
    final weekNotifications = <NotificationEntity>[];

    for (final notification in _allNotifications) {
      if (_isSameDay(notification.createdAt, now)) {
        todayNotifications.add(notification);
      } else {
        weekNotifications.add(notification);
      }
    }

    emit(
      NotificationLoaded(
        todayNotifications: todayNotifications,
        weekNotifications: weekNotifications,
      ),
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month && left.day == right.day;
  }
}
