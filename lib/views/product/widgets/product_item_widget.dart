import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';

class ProductItemWidget extends StatelessWidget {
  final Cubit cubit;
  final ProductItemModel product;
  const ProductItemWidget({super.key, required this.cubit, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: AppColors.white,
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
                    Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Seller: ${product.sellerName}', style: const TextStyle(fontSize: 12, color: AppColors.darkGold)),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  BlocProvider.of<ProductCubit>(context).toggleFavorite(product.id);
                },
                icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: AppColors.darkGold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
