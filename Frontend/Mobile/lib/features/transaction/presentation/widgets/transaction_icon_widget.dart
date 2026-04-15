import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';

class TransactionIcon extends StatelessWidget {
  final String type;
  final String? status;

  const TransactionIcon({super.key, required this.type, this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.help_outline;
    Color bgColor = AppColors.white;

    switch (type) {
      case 'buy':
        icon = Icons.shopping_bag_outlined;
        bgColor = AppColors.lightOrange;
        break;
      case 'deposit':
        icon = Icons.account_balance_wallet_outlined;
        bgColor = AppColors.lightOrange;
        break;
      case 'sell':
        icon = Icons.currency_exchange;
        bgColor = AppColors.lightOrange;
        break;
      case 'withdraw':
        icon = Icons.arrow_upward;
        bgColor = AppColors.lightOrange;
        break;
      default:
        icon = Icons.help_outline;
        bgColor = AppColors.white;
    }

    final normalizedStatus = (status ?? '').toLowerCase();
    final statusIcon = switch (normalizedStatus) {
      'approved' => Icons.check_circle,
      'pending' => Icons.schedule,
      'rejected' => Icons.cancel,
      _ => null,
    };
    final statusColor = switch (normalizedStatus) {
      'approved' => AppColors.green,
      'pending' => AppColors.pendingOrange,
      'rejected' => AppColors.red,
      _ => AppColors.grey,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkGold, size: 22),
        ),
        if (statusIcon != null)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 14, color: statusColor),
            ),
          ),
      ],
    );
  }
}
