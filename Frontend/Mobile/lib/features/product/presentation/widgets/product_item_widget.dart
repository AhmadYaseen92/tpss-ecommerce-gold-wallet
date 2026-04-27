import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/grams_hint_label.dart';

class ProductItemWidget extends StatelessWidget {
  final Object cubit;
  final ProductEntity product;
  const ProductItemWidget({
    super.key,
    required this.cubit,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final hasOffer = product.isHasOffer;
    final inactivePrice = _inactivePrice(product);
    final showPurity = _showPurity(product);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: palette.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildProductImage(product.imageUrl, palette),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _metaChip(context, product.productFormLabel),
                        if (AppReleaseConfig.showWeightInGrams &&
                            product.weight.trim().isNotEmpty)
                          _metaChip(
                            context,
                            'W: ${GramsConverter.fromWeightText(product.weight)} g',
                          ),
                        if (showPurity && product.purity.trim().isNotEmpty)
                          _metaChip(context, 'P: ${product.purity}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (AppReleaseConfig.showSellerUi)
                      Text(
                        'Seller: ${product.sellerName}',
                        style: TextStyle(fontSize: 12, color: palette.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (hasOffer) ...[
                      Text(
                        product.offerType.toLowerCase().contains('percent')
                            ? '${product.offerPercent.toStringAsFixed(0)}% OFF'
                            : 'Special Offer',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasOffer && inactivePrice != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '\$${inactivePrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        Text(
                          '\$${product.sellPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showPurity(ProductEntity product) =>
      product.materialTypeLabel.toLowerCase() == 'gold';

  Widget _metaChip(BuildContext context, String label) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: palette.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double? _inactivePrice(ProductEntity product) {
    final candidates = <double>[
      product.baseMarketPrice,
      product.offerNewPrice,
      product.pricingModeLabel.toLowerCase().contains('auto')
          ? product.autoPrice
          : product.fixedPrice,
    ];

    final price = candidates.firstWhere(
      (value) => value > 0 && value > product.sellPrice,
      orElse: () => 0,
    );
    return price > 0 ? price : null;
  }

  Widget _buildProductImage(String imageUrl, dynamic palette) {
    return AppServerImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      backgroundColor: palette.surfaceMuted,
      iconColor: palette.textSecondary,
    );
  }
}
