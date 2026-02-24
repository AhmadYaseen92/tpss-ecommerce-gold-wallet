import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';

class SummaryTransactionWidget extends StatelessWidget {
  const SummaryTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildTransactionItem(context, 'Buy Gold', '+ \$500'),
          Divider(height: 20.0, thickness: 1.0, color: AppColors.greysShade2),
          _buildTransactionItem(context, 'Sell Gold', '- \$200'),
          Divider(height: 20.0, thickness: 1.0, color: AppColors.greysShade2),
          _buildTransactionItem(context, 'Transfer to Omar', '- \$100'),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String amount,
  ) {
    return Row(
      children: [
        Icon(
          amount.startsWith('-')
              ? CupertinoIcons.arrow_down
              : CupertinoIcons.arrow_up,
          color: amount.startsWith('-') ? Colors.red : Colors.green,
        ),
        const SizedBox(width: 8.0),
        Text(title),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('-') ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
}
