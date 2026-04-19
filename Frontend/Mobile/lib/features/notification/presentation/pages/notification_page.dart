import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/presentation/widgets/notification_item_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = NotificationCubit(
          getNotificationsUseCase: InjectionContainer.getNotificationsUseCase(),
          markNotificationReadUseCase: InjectionContainer.markNotificationReadUseCase(),
          markAllNotificationsReadUseCase: InjectionContainer.markAllNotificationsReadUseCase(),
        );
        cubit.loadNotifications();
        return cubit;
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final palette = context.appPalette;
          Widget body;

          if (state is NotificationLoading) {
            body = const Center(
              child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.darkGold),
            );
          } else if (state is NotificationError) {
            body = Center(child: Text(state.message, style: TextStyle(color: palette.textSecondary)));
          } else if (state is NotificationLoaded) {
            final hasAny = state.todayNotifications.isNotEmpty || state.weekNotifications.isNotEmpty;
            if (!hasAny) {
              body = Center(child: Text('No notifications found.', style: TextStyle(color: palette.textSecondary)));
            } else {
              body = RefreshIndicator(
                onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
                child: ListView(
                  children: [
                    if (state.todayNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 4),
                        child: Text('TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: palette.textSecondary)),
                      ),
                      ...state.todayNotifications.map((n) => NotificationItemWidget(notification: n, isToday: true)),
                    ],
                    if (state.weekNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 4),
                        child: Text('THIS WEEK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: palette.textSecondary)),
                      ),
                      ...state.weekNotifications.map((n) => NotificationItemWidget(notification: n, isToday: false)),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
          } else {
            body = const SizedBox.shrink();
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
                ),
              ),
              actions: [
                if (state is NotificationLoaded)
                  TextButton(
                    onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
                    child: const Text('Mark all'),
                  ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}
