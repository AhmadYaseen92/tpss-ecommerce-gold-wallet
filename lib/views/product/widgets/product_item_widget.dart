import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/grams_hint_label.dart';

class ProductItemWidget extends StatelessWidget {
  final Cubit cubit;
  final ProductItemModel product;
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
              CachedNetworkImage(imageUrl: product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
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
}
