import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/models/notification_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/notification_cubit/notification_cubit.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final bool isToday;

  const NotificationItemWidget({super.key, required this.notification, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final iconColor = notification.icon.color ?? palette.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: isToday ? null : Border.all(color: palette.border, width: 1),
        boxShadow: isToday ? [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))] : null,
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
              child: IconTheme(data: IconThemeData(color: isToday ? iconColor : palette.textSecondary, size: 20), child: notification.icon),
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
                      child: Text(notification.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: palette.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BlocProvider.of<NotificationCubit>(context).formatTime(notification.dateTime),
                      style: TextStyle(fontSize: 12, color: palette.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.description, style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
