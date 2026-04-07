import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class SummaryTransactionWidget extends StatelessWidget {
  const SummaryTransactionWidget({super.key, required this.onViewAllHistory});

  final VoidCallback onViewAllHistory;

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
          _buildTransactionItem(context, 'Buy Gold', '+ \$500'),
          Divider(height: 20.0, thickness: 1.0, color: palette.border),
          _buildTransactionItem(context, 'Sell Gold', '- \$200'),
          Divider(height: 20.0, thickness: 1.0, color: palette.border),
          _buildTransactionItem(context, 'Transfer to Omar', '- \$100'),
          Divider(height: 20.0, thickness: 1.0, color: palette.border),
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
          color: amount.startsWith('-') ? AppColors.red : AppColors.green,
        ),
        const SizedBox(width: 8.0),
        Text(title, style: TextStyle(color: context.appPalette.textSecondary)),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('-') ? AppColors.red : AppColors.green,
          ),
        ),
      ],
    );
  }
}
