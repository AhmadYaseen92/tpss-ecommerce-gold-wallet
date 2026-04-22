import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/grams_hint_label.dart';

class ProductItemWidget extends StatelessWidget {
  final Cubit cubit;
  final ProductEntity product;
  const ProductItemWidget({super.key, required this.cubit, required this.product});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final hasOffer = product.offerType.toLowerCase() != 'none';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: palette.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildProductImage(product.imageUrl, palette),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: palette.textPrimary)),
                    Text(product.materialTypeLabel, style: TextStyle(fontSize: 12, color: palette.primary, fontWeight: FontWeight.w700)),
                    if (AppReleaseConfig.showWeightInGrams && product.weight.trim().isNotEmpty)
                      GramsHintLabel(grams: GramsConverter.fromWeightText(product.weight), prefix: 'Weight:'),
                    if (product.purity.trim().isNotEmpty)
                      Text(
                        'Purity: ${product.purity}',
                        style: TextStyle(fontSize: 12, color: palette.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    Text(product.pricingModeLabel, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                    if (AppReleaseConfig.showSellerUi)
                      Text('Seller: ${product.sellerName}', style: TextStyle(fontSize: 12, color: palette.primary)),
                    const SizedBox(height: 6),
                    if (hasOffer)
                      Text(
                        '\$${_sourcePrice(product).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '\$${product.sellPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.textPrimary),
                    ),
                    if (hasOffer)
                      Text(
                        product.offerType.toLowerCase().contains('percent')
                            ? '${product.offerPercent.toStringAsFixed(0)}% OFF'
                            : 'Offer • Now \$${product.sellPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: palette.primary, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  BlocProvider.of<ProductCubit>(context).toggleFavorite(product.id);
                },
                icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: palette.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _sourcePrice(ProductEntity product) {
    final isAuto = product.pricingModeLabel.toLowerCase().contains('auto');
    return isAuto ? product.autoPrice : product.fixedPrice;
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
