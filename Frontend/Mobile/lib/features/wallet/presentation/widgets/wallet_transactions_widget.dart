import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

class WalletTransactionsWidget extends StatelessWidget {
  const WalletTransactionsWidget({
    super.key,
    required this.transactions,
    required this.accentColor,
    required this.onViewAllHistory,
  });

  final List<WalletTransactionEntity> transactions;
  final Color accentColor;
  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    if (transactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: 'No Transactions Yet',
        message: 'Your transaction history will appear here when you add items to your wallet.',

      );
    }

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
                'My Transactions',
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
                  'View All ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final tx = entry.value;
            return Column(
              children: [
                _buildTransactionRow(context, tx),
                if (index < transactions.length - 1)
                  Divider(height: 20.0, thickness: 1.0, color: palette.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, WalletTransactionEntity tx) {
    final palette = context.appPalette;
    final isPositive = tx.change.startsWith('+');
    final pnlAmount = tx.marketValueAmount - tx.estimatedPurchaseValue;
    final pnlLabel = pnlAmount >= 0 ? 'Profit' : 'Loss';
    final signedPnlAmount = pnlAmount >= 0 ? '+' : '-';
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
                tx.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 2.0),
              if (AppReleaseConfig.showSellerUi) ...[
                Text(
                  'Seller: ${tx.sellerName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2.0),
              ],
              Text(tx.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tx.marketValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Live Price: \$${tx.marketPricePerGram.toStringAsFixed(2)}/g',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              '$pnlLabel: $signedPnlAmount\$${pnlAmount.abs().toStringAsFixed(2)} (${tx.change})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPositive ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
