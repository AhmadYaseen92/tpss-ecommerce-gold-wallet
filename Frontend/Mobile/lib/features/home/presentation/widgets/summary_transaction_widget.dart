import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

class SummaryTransactionWidget extends StatelessWidget {
  const SummaryTransactionWidget({super.key, required this.onViewAllHistory, required this.transactions});

  final VoidCallback onViewAllHistory;
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: palette.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Transaction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(0.0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onViewAllHistory,
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          ...transactions.map((tx) => Column(
            children: [
              _buildTransactionItem(context, tx),
              if (tx != transactions.last)
                Divider(height: 20.0, thickness: 1.0, color: palette.border),
            ],
          )),
          if (transactions.isEmpty)
            Text('No recent transactions', style: TextStyle(color: palette.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx) {
    final isNegative = tx.amount < 0;
    final amountStr = (isNegative ? '- ' : '+ ') + '\$${tx.amount.abs().toStringAsFixed(2)}';
    return Row(
      children: [
        Icon(
          isNegative ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
          color: isNegative ? AppColors.red : AppColors.green,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            tx.transactionType + (tx.investorName.isNotEmpty ? ' (${tx.investorName})' : ''),
            style: TextStyle(color: context.appPalette.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Text(
          amountStr,
          style: TextStyle(
            color: isNegative ? AppColors.red : AppColors.green,
          ),
        ),
      ],
    );
  }
}
