import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

class WalletHoldingItemWidget extends StatelessWidget {
  final WalletTransactionEntity item;
  final VoidCallback onSell;
  final VoidCallback onGiftTransfer;
  final VoidCallback onGenerateTaxInvoice;
  final VoidCallback onPickup;

  const WalletHoldingItemWidget({
    super.key,
    required this.item,
    required this.onSell,
    required this.onGiftTransfer,
    required this.onGenerateTaxInvoice,
    required this.onPickup,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDelivered = item.isDelivered;
    final isPending = item.status.toLowerCase().startsWith('pending');
    final isActionBlocked = isDelivered || isPending;
    final status = item.status;
    final pnlAmount = item.marketValueAmount - item.estimatedPurchaseValue;
    final pnlLabel = pnlAmount >= 0 ? 'Profit' : 'Loss';
    final signedPnlAmount = pnlAmount >= 0 ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: palette.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: BorderSide(color: palette.primary.withAlpha(35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: AppServerImage(
                      imageUrl: item.imageUrl,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12.0),
                      backgroundColor: palette.surfaceMuted,
                      iconColor: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: palette.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (status.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _statusColor(status).withAlpha(80)),
                            ),
                            child: Text(
                              status,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (AppReleaseConfig.showSellerUi) ...[
                          Text('Seller: ${item.sellerName}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                        ],
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _miniTag(context, 'Qty: ${item.quantity}'),
                            _miniTag(context, 'Purity: ${item.purity}'),
                            _miniTag(context, '${item.weightInGrams.toStringAsFixed(2)} g'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(item.marketValue, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: palette.textPrimary)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.change.startsWith('+') ? AppColors.green.withAlpha(18) : AppColors.red.withAlpha(18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: item.change.startsWith('+') ? AppColors.green.withAlpha(60) : AppColors.red.withAlpha(60)),
                              ),
                              child: Text(
                                item.change,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: item.change.startsWith('+') ? AppColors.green : AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Live Price: \$${item.marketPricePerGram.toStringAsFixed(2)}/g',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$pnlLabel: $signedPnlAmount\$${pnlAmount.abs().toStringAsFixed(2)} (${item.change})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: item.change.startsWith('+') ? AppColors.green : AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _actionButton(context, label: 'Sell', icon: Icons.sell_outlined, onTap: onSell, isDisabled: isActionBlocked)),
                  const SizedBox(width: 16),
                  Expanded(child: _actionButton(context, label: 'Gift', icon: Icons.wallet_giftcard, onTap: onGiftTransfer, isDisabled: isActionBlocked)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _actionButton(context, icon: Icons.local_shipping_outlined, label: 'Pickup', onTap: onPickup, isDisabled: isActionBlocked)),
                  const SizedBox(width: 16),
                  Expanded(child: _actionButton(context, icon: Icons.file_present, label: 'Certificate', onTap: onGenerateTaxInvoice, isDisabled: isActionBlocked)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pending')) return Colors.orange.shade700;
    if (normalized.contains('delivered')) return Colors.green.shade700;
    if (normalized.contains('gift') || normalized.contains('transfer')) return Colors.blue.shade700;
    return Colors.grey.shade700;
  }

  Widget _miniTag(BuildContext context, String text) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withAlpha(40)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: palette.textPrimary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionButton(BuildContext context, {required IconData icon, required VoidCallback onTap, String label = '', Color? iconColor, bool isDisabled = false}) {
    final palette = context.appPalette;
    final actionColor = isDisabled ? palette.textSecondary : (iconColor ?? palette.primary);

    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: actionColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: actionColor),
            const SizedBox(width: 4),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: actionColor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
