import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    if (AppReleaseConfig.showWeightInGrams)
                      GramsHintLabel(grams: GramsConverter.fromWeightText(product.weight), prefix: 'Weight:'),
                    if (AppReleaseConfig.showSellerUi)
                      Text('Seller: ${product.sellerName}', style: TextStyle(fontSize: 12, color: palette.primary)),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: TextStyle(fontSize: 13, color: palette.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.textPrimary),
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

  Widget _buildProductImage(String imageUrl, dynamic palette) {
    final parsed = Uri.tryParse(imageUrl.trim());
    final validNetworkUrl = parsed != null && (parsed.scheme == 'http' || parsed.scheme == 'https') && parsed.host.isNotEmpty;
    if (!validNetworkUrl) {
      return Container(
        width: 80,
        height: 80,
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: palette.textSecondary),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(
        width: 80,
        height: 80,
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: palette.textSecondary),
      ),
    );
  }
}
