import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';

class WalletAssetSummaryCard extends StatelessWidget {
  final WalletTransactionEntity asset;

  const WalletAssetSummaryCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ActionSectionCard(
      title: 'Asset Summary',
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppServerImage(
                  imageUrl: asset.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: palette.surfaceMuted,
                  iconColor: palette.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                    const SizedBox(height: 4),
                    Text(asset.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ReadonlyInfoRow(label: 'Purity', value: asset.purity),
          if (asset.status.toLowerCase().startsWith('pending'))
            ReadonlyInfoRow(label: 'Status', value: asset.status),
          ReadonlyInfoRow(label: 'Quantity', value: '${asset.quantity}'),
          ReadonlyInfoRow(label: 'Weight', value: '${asset.weightInGrams.toStringAsFixed(2)} g'),
          ReadonlyInfoRow(label: 'Market Value', value: asset.marketValue),
        ],
      ),
    );
  }
}
