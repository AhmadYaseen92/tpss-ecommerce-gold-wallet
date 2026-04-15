import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_icon_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_status_badge_widget.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItemWidget({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  children: [
                    TransactionIcon(type: transaction.transactionType),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.transactionType.toUpperCase(),
                            style: TextStyle(fontSize: 12, color: palette.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(transaction.displayDate.toLocal())}',
                            style: TextStyle(fontSize: 12, color: palette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                        ),
                        Text(
                          '${transaction.weight.toStringAsFixed(3)} ${transaction.unit}',
                          style: TextStyle(fontSize: 12, color: palette.textSecondary),
                        ),
                        Text(
                          'Qty: ${transaction.quantity}',
                          style: TextStyle(fontSize: 12, color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(height: 20, thickness: 0.8, color: palette.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: #${transaction.id}',
                      style: TextStyle(fontSize: 12, color: palette.textSecondary),
                    ),
                    StatusBadge(status: transaction.status.toLowerCase()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
