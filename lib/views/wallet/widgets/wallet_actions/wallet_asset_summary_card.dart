import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/readonly_info_row.dart';

class WalletAssetSummaryCard extends StatelessWidget {
  final WalletTransaction asset;

  const WalletAssetSummaryCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return ActionSectionCard(
      title: 'Asset Summary',
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: asset.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ReadonlyInfoRow(label: 'Purity', value: asset.purity),
          ReadonlyInfoRow(label: 'Quantity', value: '${asset.quantity}'),
          ReadonlyInfoRow(
            label: 'Weight',
            value: '${asset.weightInGrams.toStringAsFixed(2)} g',
          ),
          ReadonlyInfoRow(label: 'Market Value', value: asset.marketValue),
        ],
      ),
    );
  }
}
