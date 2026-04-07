import 'package:bloc/bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/data/models/notification_model.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void loadNotifications() async {
    emit(NotificationLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(NotificationLoaded(
        todayNotifications: todayNotifications,
        weekNotifications: weekNotifications,
      ));
    } catch (e) {
      emit(NotificationError("Failed to load notifications"));
    }
  }

  void markAllAsRead() {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      emit(NotificationLoaded(
        todayNotifications:
            current.todayNotifications.map((n) => n.copyWith(isRead: true)).toList(),
        weekNotifications:
            current.weekNotifications.map((n) => n.copyWith(isRead: true)).toList(),
      ));
    }
  }

    String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

}
