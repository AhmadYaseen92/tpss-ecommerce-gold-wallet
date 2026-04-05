import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';

class TransactionIcon extends StatelessWidget {
  final String type;

  const TransactionIcon({super.key, required this.type});

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

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.darkGold, size: 22),
    );
  }
}
