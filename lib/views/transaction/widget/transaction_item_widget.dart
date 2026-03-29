import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_icon_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_status_badge_widget.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: AppColors.white,
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Seller: ${transaction.sellerName}',
                          style: const TextStyle(fontSize: 11, color: AppColors.darkGold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(transaction.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
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
                          color: transaction.amount.startsWith('+')
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                      if (transaction.secondaryAmount != null)
                        Text(
                          transaction.secondaryAmount!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: #${transaction.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
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
