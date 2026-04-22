import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/domain/entities/notification_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/presentation/cubit/notification_cubit.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    required this.notification,
    required this.isToday,
    super.key,
  });

  final NotificationEntity notification;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final iconData = _iconForTitle(notification.title);
    final iconColor = _iconColorForTitle(notification.title);

    final createdAtLocal = notification.createdAt.toLocal();
    final now = DateTime.now();
    final isTodayDate = createdAtLocal.year == now.year &&
        createdAtLocal.month == now.month &&
        createdAtLocal.day == now.day;
    final localDateText = isTodayDate
        ? 'Today ${DateFormat.jm().format(createdAtLocal)}'
        : DateFormat.yMMMd().add_jm().format(createdAtLocal);

    return GestureDetector(
      onTap: () => context.read<NotificationCubit>().markNotificationAsRead(notification.id),
      child: Opacity(
        opacity: notification.isRead ? 0.78 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? palette.surface : palette.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.isRead ? palette.border : palette.primary.withOpacity(0.5),
              width: notification.isRead ? 1 : 1.3,
            ),
            boxShadow: isToday
                ? [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isToday ? iconColor.withOpacity(0.12) : palette.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: isToday ? Colors.transparent : palette.border),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    color: isToday ? iconColor : palette.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 14,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localDateText,
                          style: TextStyle(fontSize: 12, color: palette.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: notification.isRead ? palette.textSecondary : palette.textPrimary,
                        fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForTitle(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('security') || normalized.contains('alert')) return Icons.shield_outlined;
    if (normalized.contains('deposit') || normalized.contains('balance')) return Icons.account_balance;
    if (normalized.contains('purchase') || normalized.contains('order')) return Icons.check_circle;
    if (normalized.contains('price') || normalized.contains('surge')) return Icons.trending_up;
    return Icons.notifications_none;
  }

  Color _iconColorForTitle(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('security') || normalized.contains('alert')) return AppColors.grey;
    if (normalized.contains('deposit') || normalized.contains('balance')) return AppColors.teal;
    if (normalized.contains('purchase') || normalized.contains('order')) return AppColors.blue;
    if (normalized.contains('price') || normalized.contains('surge')) return AppColors.amber;
    return AppColors.darkGold;
  }
}
