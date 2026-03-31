import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

class WalletTransactionsWidget extends StatelessWidget {
  const WalletTransactionsWidget({
    super.key,
    required this.transactions,
    required this.accentColor,
    required this.onViewAllHistory,
  });

  final List<WalletTransaction> transactions;
  final Color accentColor;
  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

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

  Widget _buildTransactionRow(BuildContext context, WalletTransaction tx) {
    final palette = context.appPalette;
    final isPositive = tx.change.startsWith('+');
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            tx.imageUrl,
            width: 44.0,
            height: 44.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.image_not_supported_outlined, size: 22.0, color: palette.textSecondary),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Center(
                  child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
                ),
              );
            },
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
              tx.change,
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
