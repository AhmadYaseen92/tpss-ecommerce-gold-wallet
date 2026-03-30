import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

class WalletHoldingItemWidget extends StatelessWidget {
  final WalletTransaction item;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: AppColors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: BorderSide(color: AppColors.primaryColor.withAlpha(35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              /// Top content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 78,
                        height: 78,
                        color: AppColors.luxuryIvory,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 78,
                        height: 78,
                        color: AppColors.luxuryIvory,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: ClipRRect(
                            //     borderRadius: BorderRadius.circular(6.0),
                            //     child: Image.asset(
                            //       'assets/certificate_icon.png',
                            //       fit: BoxFit.cover,
                            //       width: 35,
                            //       height: 35,
                            //     ),
                            //   ),
                            // ),
                            // _actionButton(
                            //   context,
                            //   label: 'Certificate',
                            //   icon: Icons.file_present,
                            //   onTap: onGenerateTaxInvoice,
                            // ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        Text(
                          item.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.darkGrey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (AppReleaseConfig.showSellerUi) ...[
                          Text(
                            'Seller: ${item.sellerName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.darkGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _miniTag(context, 'Qty: ${item.quantity}'),
                            _miniTag(context, 'Purity: ${item.purity}'),
                            _miniTag(
                              context,
                              '${item.weightInGrams.toStringAsFixed(2)} g',
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text(
                              item.marketValue,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: item.change.startsWith('+')
                                    ? AppColors.green.withAlpha(18)
                                    : AppColors.red.withAlpha(18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: item.change.startsWith('+')
                                      ? AppColors.green.withAlpha(60)
                                      : AppColors.red.withAlpha(60),
                                ),
                              ),
                              child: Text(
                                item.change,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: item.change.startsWith('+')
                                          ? AppColors.green
                                          : AppColors.red,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      label: 'Sell',
                      icon: Icons.sell_outlined,
                      onTap: onSell,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _actionButton(
                      context,
                      label: 'Gift',
                      icon: Icons.wallet_giftcard,
                      onTap: onGiftTransfer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.local_shipping_outlined,
                      label: 'Pickup',
                      onTap: onPickup,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.file_present,
                      label: 'Cirtificate',
                      onTap: onPickup,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.luxuryIvory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withAlpha(40)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    String label = '',
    Color iconColor = AppColors.primaryColor,
  }) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: iconColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.darkGold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
