import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_icon_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_status_badge_widget.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Row(
                children: [
                  TransactionIcon(type: transaction.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: palette.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        if (AppReleaseConfig.showSellerUi) ...[
                          Text('Seller: ${transaction.sellerName}', style: TextStyle(fontSize: 11, color: palette.primary)),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(transaction.date),
                          style: TextStyle(fontSize: 12, color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        transaction.amount,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: transaction.amount.startsWith('+') ? AppColors.green : AppColors.red,
                        ),
                      ),
                      if (transaction.secondaryAmount != null)
                        Text(transaction.secondaryAmount!, style: TextStyle(fontSize: 12, color: palette.textPrimary)),
                    ],
                  ),
                ],
              ),
              Divider(height: 20, thickness: 0.8, color: palette.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ID: #${transaction.id}', style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                  StatusBadge(status: transaction.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
