import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/notification_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/notification_cubit/notification_cubit.dart';


class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final bool isToday;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = notification.icon.color ?? AppColors.grey;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: isToday
          ? BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.greyBorder, width: 1),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isToday ? iconColor.withOpacity(0.12) : AppColors.greysShade2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday
                    ? AppColors.transparent
                    : AppColors.greyBorderLight,
              ),
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: isToday ? iconColor : AppColors.greyShade500,
                  size: 20,
                ),
                child: notification.icon,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isToday ? AppColors.black : AppColors.greyShade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BlocProvider.of<NotificationCubit>(context).formatTime(notification.dateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? AppColors.grey : AppColors.greyShade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isToday ? AppColors.darkGrey : AppColors.greyShade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
