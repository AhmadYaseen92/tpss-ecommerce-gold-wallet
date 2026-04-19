import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class RecentTransactionViewModel {
  const RecentTransactionViewModel({
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.isPositive,
    this.imageUrl = '',
    this.secondaryText,
  });

  final String title;
  final String subtitle;
  final String amountText;
  final bool isPositive;
  final String imageUrl;
  final String? secondaryText;
}

class RecentTransactionsCommonWidget extends StatelessWidget {
  const RecentTransactionsCommonWidget({
    super.key,
    required this.title,
    required this.transactions,
    required this.onViewAllHistory,
    this.maxItems = 3,
    this.viewAllColor,
  });

  final String title;
  final List<RecentTransactionViewModel> transactions;
  final VoidCallback onViewAllHistory;
  final int maxItems;
  final Color? viewAllColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final visibleItems = transactions.take(maxItems).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
                    color: viewAllColor ?? palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          if (visibleItems.isEmpty)
            Table(
              border: TableBorder.all(color: palette.border),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No transactions found.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            ...visibleItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildTransactionRow(context, item),
                  if (index < visibleItems.length - 1)
                    Divider(height: 20.0, thickness: 1.0, color: palette.border),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, RecentTransactionViewModel tx) {
    final palette = context.appPalette;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: AppServerImage(
            imageUrl: tx.imageUrl,
            width: 44.0,
            height: 44.0,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10.0),
            backgroundColor: palette.surfaceMuted,
            iconColor: palette.textSecondary,
            placeholderIconSize: 22,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                tx.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((tx.secondaryText ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 2.0),
                Text(
                  tx.secondaryText!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          tx.amountText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: tx.isPositive ? AppColors.green : AppColors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
